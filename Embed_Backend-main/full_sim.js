/**
 * EXACT SIMULATION of fetchNudge pipeline with full tracing
 */
const mongoose = require('mongoose');
const crypto = require('crypto');

const MONGO_URI = 'mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/?appName=EmbedCraft';
const ORG_ID = '692ea4db3d70137fcfc1ed13';
const USER_ID = 'PJ0N8JoyJ9WeANogCYwvcNcM3xt2';
const ANON_ID = '1781382578782_anon_hjg3uxgzsj';
const PLATFORM = 'android';
const SCREEN_NAME = 'all';

async function main() {
    await mongoose.connect(MONGO_URI);
    const { tenantStorage } = require('./src/services/tenantConnectionManager');
    const connection = mongoose.connection.useDb(`tenant_${ORG_ID}`, { useCache: true });
    
    await tenantStorage.run({ connection }, async () => {
        const EventLog = require('./src/models/EventLog');
        const Nudge = require('./src/models/Nudge');
        const EndUser = require('./src/models/EndUser');
        
        // Step 1: Fetch nudges from DB (EXACT query from line 116-126)
        const nudges = await Nudge.find({
            organization_id: ORG_ID,
            status: 'active',
            $or: [
                { 'display_rules.pages': { $in: [SCREEN_NAME] } },
                { 'display_rules.pages': { $size: 0 } },
                { 'display_rules.pages': { $exists: false } },
                { trigger_screens: 'all' },
                { trigger_screens: SCREEN_NAME }
            ]
        }).sort({ priority: -1 }).lean();

        console.log(`\n📋 Step 1: DB query returned ${nudges.length} nudges`);
        for (const n of nudges) {
            console.log(`   - ${n.campaign_name} (${n._id}) trigger=${n.trigger_event} status=${n.status}`);
        }

        // Filter active only
        const activeNudges = nudges.filter(n => n.status === 'active');
        console.log(`\n📋 Step 1.5: Active filter: ${activeNudges.length} remain`);

        // Get user profile
        let userProfile = await EndUser.findOne({ organization_id: ORG_ID, user_id: USER_ID }).lean();
        if (!userProfile) {
            userProfile = await EndUser.findOne({ organization_id: ORG_ID, anonymous_id: ANON_ID }).lean();
        }
        console.log(`\n👤 User profile found: ${!!userProfile}`);

        // Build nudge IDs
        const nudgeIds = [];
        activeNudges.forEach(n => {
            if (n.nudge_id) nudgeIds.push(n.nudge_id);
            if (n._id) nudgeIds.push(n._id.toString());
        });

        const userMatchQuery = [{ user_id: USER_ID }, { anonymous_id: ANON_ID }];

        // Batch queries (lines 173-244)
        // NOTE: Using STRING orgId in aggregates (like the real backend does - NO auto-cast!)
        
        const [impressionStats, lastSession] = await Promise.all([
            EventLog.aggregate([
                { $match: { organization_id: ORG_ID, $or: userMatchQuery, nudge_id: { $in: nudgeIds }, event_type: { $in: ['impression', 'campaign_impression', 'NINJA_EXPERIENCE_OPEN'] } } },
                { $facet: {
                    total: [{ $group: { _id: '$nudge_id', count: { $sum: 1 } } }],
                    daily: [{ $match: { timestamp: { $gte: new Date(Date.now() - 86400000) } } }, { $group: { _id: '$nudge_id', count: { $sum: 1 } } }],
                    weekly: [{ $match: { timestamp: { $gte: new Date(Date.now() - 604800000) } } }, { $group: { _id: '$nudge_id', count: { $sum: 1 } } }]
                }}
            ]),
            EventLog.findOne({ organization_id: ORG_ID, $or: userMatchQuery, event_type: 'session_start' }).sort({ timestamp: -1 }).lean()
        ]);

        const totalMap = new Map((impressionStats[0]?.total || []).map(s => [s._id, s.count]));
        const dailyMap = new Map((impressionStats[0]?.daily || []).map(s => [s._id, s.count]));
        const weeklyMap = new Map((impressionStats[0]?.weekly || []).map(s => [s._id, s.count]));
        const sessionStartTime = lastSession?.timestamp || new Date(Date.now() - 30 * 60 * 1000);
        
        console.log(`\n⏱️ Session start: ${lastSession ? lastSession.timestamp.toISOString() : 'NONE (30min fallback)'}`);
        console.log(`   totalMap entries: ${totalMap.size}`);
        for (const [k, v] of totalMap) console.log(`      ${k}: ${v}`);

        const sessionImpressions = await EventLog.aggregate([
            { $match: { organization_id: ORG_ID, $or: userMatchQuery, nudge_id: { $in: nudgeIds }, event_type: { $in: ['impression', 'campaign_impression', 'NINJA_EXPERIENCE_OPEN'] }, timestamp: { $gte: sessionStartTime } } },
            { $group: { _id: '$nudge_id', count: { $sum: 1 } } }
        ]);
        const sessionMap = new Map(sessionImpressions.map(s => [s._id, s.count]));

        // Now iterate
        const matchedNudges = [];
        const invalidNudges = [];

        for (const nudge of activeNudges) {
            const nid = nudge.nudge_id || nudge._id?.toString();
            const totalImpressions = (totalMap.get(nudge.nudge_id) || 0) + (totalMap.get(nudge._id?.toString()) || 0);
            const dailyImpressions = (dailyMap.get(nudge.nudge_id) || 0) + (dailyMap.get(nudge._id?.toString()) || 0);
            const weeklyImpressions = (weeklyMap.get(nudge.nudge_id) || 0) + (weeklyMap.get(nudge._id?.toString()) || 0);
            const sessImpressions = (sessionMap.get(nudge.nudge_id) || 0) + (sessionMap.get(nudge._id?.toString()) || 0);

            console.log(`\n🔍 Checking: "${nudge.campaign_name}" (${nid})`);
            console.log(`   impressions: total=${totalImpressions}, daily=${dailyImpressions}, session=${sessImpressions}`);

            // A. Platform
            const targetPlatforms = nudge.display_rules?.platforms || nudge.target_audience;
            if (targetPlatforms && targetPlatforms.length > 0) {
                const lp = PLATFORM.toLowerCase();
                const lt = targetPlatforms.map(p => p.toLowerCase());
                const match = lt.includes(lp);
                if (!match) { console.log('   ❌ Platform mismatch'); invalidNudges.push(nudge); continue; }
                console.log('   ✅ Platform OK');
            }

            // A.0.5 Rollout
            if (nudge.goal?.rolloutPercentage !== undefined && nudge.goal.rolloutPercentage < 100) {
                const targetingId = USER_ID || ANON_ID;
                const hash = crypto.createHash('md5').update(`${targetingId}-${nid}`).digest('hex');
                const bucket = parseInt(hash.substring(0, 8), 16) % 100;
                if (bucket >= nudge.goal.rolloutPercentage) {
                    console.log(`   ❌ Rollout: bucket=${bucket} >= ${nudge.goal.rolloutPercentage}%`);
                    continue;
                }
                console.log(`   ✅ Rollout OK: bucket=${bucket} < ${nudge.goal.rolloutPercentage}%`);
            }

            // A.0 Schedule
            if (nudge.schedule) {
                const now = new Date();
                const start = nudge.schedule.start_date ? new Date(nudge.schedule.start_date) : null;
                const end = nudge.schedule.end_date ? new Date(nudge.schedule.end_date) : null;
                if (start && now < start) { console.log('   ❌ Schedule: not started'); continue; }
                if (end && now > end) { console.log('   ❌ Schedule: ended'); invalidNudges.push(nudge); continue; }
                console.log('   ✅ Schedule OK');
            }

            // A.2 Segments
            if (nudge.segments && nudge.segments.length > 0) {
                const userSegments = userProfile?.segments || [];
                const hasMatch = nudge.segments.some(seg => userSegments.includes(seg));
                if (!hasMatch) { console.log('   ❌ Segment mismatch'); invalidNudges.push(nudge); continue; }
                console.log('   ✅ Segments OK');
            }

            // A.3 Frequency
            const dr = nudge.display_rules || {};
            let freqBlocked = false;
            
            if (dr.frequency_cap && totalImpressions >= dr.frequency_cap) {
                console.log(`   ❌ frequency_cap: ${totalImpressions} >= ${dr.frequency_cap}`);
                invalidNudges.push(nudge); continue;
            }
            if (dr.interactionLimit) {
                if (dr.interactionLimit.type === 'limited') {
                    const v = dr.interactionLimit.value || 1;
                    if (totalImpressions >= v) { console.log(`   ❌ interactionLimit limited: ${totalImpressions} >= ${v}`); invalidNudges.push(nudge); continue; }
                }
                if (dr.interactionLimit.type === 'custom' && dr.interactionLimit.limit) {
                    if (totalImpressions >= dr.interactionLimit.limit) { console.log(`   ❌ interactionLimit custom`); invalidNudges.push(nudge); continue; }
                }
            }
            if (dr.frequency && dr.frequency.type !== 'every_time') {
                const fv = dr.frequency.value || 1;
                if (dr.frequency.type === 'custom' && totalImpressions >= fv) { console.log(`   ❌ custom freq`); invalidNudges.push(nudge); continue; }
                if (dr.frequency.type === 'daily' && dailyImpressions >= fv) { console.log(`   ❌ daily freq`); continue; }
                if (dr.frequency.type === 'weekly' && weeklyImpressions >= fv) { console.log(`   ❌ weekly freq`); continue; }
            }

            // A.4 Session capping
            if (dr.session_cap && sessImpressions >= dr.session_cap) { console.log(`   ❌ session_cap`); invalidNudges.push(nudge); continue; }
            if (dr.sessionLimit?.enabled) {
                const v = dr.sessionLimit.value || 1;
                if (sessImpressions >= v) { console.log(`   ❌ sessionLimit value: ${sessImpressions} >= ${v}`); continue; }
                if (dr.sessionLimit.limit && sessImpressions >= dr.sessionLimit.limit) { console.log(`   ❌ sessionLimit limit`); invalidNudges.push(nudge); continue; }
            }
            if (dr.frequency?.type === 'once_per_session') {
                if (sessImpressions >= 1) { console.log(`   ❌ once_per_session: ${sessImpressions} >= 1`); continue; }
                console.log(`   ✅ once_per_session: ${sessImpressions} < 1`);
            }

            // B. Targeting
            if (nudge.targeting && nudge.targeting.length > 0) {
                let allPass = true;
                for (const rule of nudge.targeting) {
                    if (rule.type === 'group') continue;
                    if (rule.type === 'event') {
                        const eventName = rule.event || rule.property || rule.field;
                        const eventQuery = {
                            organization_id: ORG_ID,
                            $or: userMatchQuery,
                            event_type: eventName
                        };
                        const count = await EventLog.countDocuments(eventQuery);
                        const tv = Number(rule.count || rule.value || 1);
                        const op = rule.countOperator || rule.operator || 'greater_than_or_equal';
                        let pass;
                        switch (op) {
                            case 'greater_than_or_equal': pass = count >= tv; break;
                            case 'greater_than': pass = count > tv; break;
                            case 'equals': pass = count == tv; break;
                            default: pass = count >= tv;
                        }
                        console.log(`   Targeting event "${eventName}": count=${count}, target=${tv}, op=${op} → ${pass ? '✅' : '❌'}`);
                        if (!pass) { allPass = false; break; }
                    }
                }
                if (!allPass) { console.log('   ❌ Targeting FAILED'); invalidNudges.push(nudge); continue; }
                console.log('   ✅ Targeting PASSED');
            }

            // C. hasTriggerPropertyRule (lines 583-592)
            // First do trigger_event override (lines 568-575)
            let effectiveTrigger = nudge.trigger_event;
            if (effectiveTrigger === 'session_start' || effectiveTrigger === 'all') {
                if (nudge.targeting) {
                    const first = nudge.targeting.find(r => r.type === 'event');
                    if (first?.event) effectiveTrigger = first.event;
                }
            }

            const hasTriggerPropertyRule = nudge.targeting?.some(r =>
                r.type === 'event' &&
                (r.event === effectiveTrigger || effectiveTrigger === 'all' || effectiveTrigger === 'session_start') &&
                (r.properties?.length > 0 || r.field)
            ) || false;
            
            if (hasTriggerPropertyRule) {
                console.log(`   ❌ hasTriggerPropertyRule! Skipping.`);
                invalidNudges.push(nudge);
                continue;
            }

            console.log(`   ✅✅✅ ALL CHECKS PASSED - Campaign added to response`);
            matchedNudges.push(nudge);
        }

        console.log('\n' + '='.repeat(80));
        console.log(`FINAL RESULT: ${matchedNudges.length} matched, ${invalidNudges.length} invalid`);
        console.log('Matched:');
        matchedNudges.forEach(n => console.log(`   ✅ ${n.campaign_name}`));
        console.log('Invalid:');
        invalidNudges.forEach(n => console.log(`   ❌ ${n.campaign_name} (reason: ${n.debug_reason || 'see above'})`));
    });

    await mongoose.disconnect();
}

main().catch(err => { console.error(err); process.exit(1); });
