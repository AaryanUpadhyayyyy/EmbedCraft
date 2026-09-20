const mongoose = require('mongoose');

const MONGO_URI = 'mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/tenant_692ea4db3d70137fcfc1ed13?appName=EmbedCraft';
const USER_ID = 'PJ0N8JoyJ9WeANogCYwvcNcM3xt2';
const ANON_ID = '1781382578782_anon_hjg3uxgzsj';
const ORG_ID = '692ea4db3d70137fcfc1ed13';

async function main() {
    await mongoose.connect(MONGO_URI);
    const db = mongoose.connection.db;
    console.log('✅ Connected\n');

    const nudges = db.collection('nudges');
    
    // List ALL campaigns in this tenant DB (no org filter)
    const all = await nudges.find({}).toArray();
    console.log(`Total campaigns in DB: ${all.length}\n`);
    
    if (all.length === 0) {
        // Check what collections exist
        const collections = await db.listCollections().toArray();
        console.log('Collections:', collections.map(c => c.name).join(', '));
        await mongoose.disconnect();
        return;
    }

    // Find the Spin The Wheel campaign
    let stw = null;
    
    for (const c of all) {
        // Find ALL possible name-like fields
        const allKeys = Object.keys(c);
        const nameFields = {};
        for (const k of allKeys) {
            if (typeof c[k] === 'string') {
                nameFields[k] = c[k].substring(0, 80);
            }
        }
        
        console.log('='.repeat(60));
        console.log(`_id: ${c._id} (type: ${typeof c._id})`);
        console.log(`organization_id: ${c.organization_id} (type: ${typeof c.organization_id})`);
        console.log(`status: ${c.status}`);
        console.log(`trigger_event: ${c.trigger_event}`);
        console.log(`trigger_screens: ${JSON.stringify(c.trigger_screens)}`);
        console.log('String fields:', JSON.stringify(nameFields, null, 2));
        
        if (c.trigger_event === 'profile_viewed' && c.status === 'active') {
            stw = c;
        }
        console.log('');
    }

    if (!stw) {
        console.log('\n❌ No campaign with trigger_event=profile_viewed found');
        console.log('Looking for any campaign with "spin" in any field...');
        for (const c of all) {
            const json = JSON.stringify(c).toLowerCase();
            if (json.includes('spin')) {
                console.log(`Found "spin" in campaign ${c._id}`);
                stw = c;
                break;
            }
        }
    }

    if (!stw) {
        console.log('❌ No Spin The Wheel campaign found at all!');
        await mongoose.disconnect();
        return;
    }

    console.log('\n' + '='.repeat(80));
    console.log('🎰 SPIN THE WHEEL CAMPAIGN - FULL DETAILS');
    console.log('='.repeat(80));
    
    console.log('\n📋 display_rules:');
    console.log(JSON.stringify(stw.display_rules, null, 2));
    
    console.log('\n🎯 targeting:');
    console.log(JSON.stringify(stw.targeting, null, 2));
    
    console.log('\n📆 schedule:');
    console.log(JSON.stringify(stw.schedule, null, 2));
    
    console.log('\n🎲 goal:');
    console.log(JSON.stringify(stw.goal, null, 2));
    
    console.log('\n📌 segments:');
    console.log(JSON.stringify(stw.segments, null, 2));
    
    console.log('\n📌 target_audience:');
    console.log(JSON.stringify(stw.target_audience, null, 2));

    // ====== SIMULATE FULL FILTER PIPELINE ======
    console.log('\n' + '='.repeat(80));
    console.log('🔍 SIMULATING nudgeController.js FILTER PIPELINE');
    console.log('='.repeat(80));

    const nudgeId = stw.nudge_id || stw._id.toString();
    const nudgeIds = [nudgeId, stw._id.toString()];
    // Try both string and ObjectId for user queries
    const userMatchQuery = [{ user_id: USER_ID }, { anonymous_id: ANON_ID }];
    const eventLogs = db.collection('eventlogs');

    // STEP A: Platform
    console.log('\n--- A. Platform Check ---');
    const targetPlatforms = stw.display_rules?.platforms || stw.target_audience;
    if (targetPlatforms && targetPlatforms.length > 0) {
        const lp = 'android';
        const lt = targetPlatforms.map(p => p.toLowerCase());
        console.log(`   Targets: ${JSON.stringify(lt)}, request: "${lp}" → ${lt.includes(lp) ? '✅' : '❌'}`);
    } else {
        console.log('   No platform filter → ✅');
    }

    // STEP A.0.5: Rollout
    console.log('\n--- A.0.5. Rollout Check ---');
    if (stw.goal?.rolloutPercentage !== undefined && stw.goal.rolloutPercentage < 100) {
        const crypto = require('crypto');
        const hash = crypto.createHash('md5').update(`${USER_ID}-${nudgeId}`).digest('hex');
        const bucket = parseInt(hash.substring(0, 8), 16) % 100;
        console.log(`   Rollout: ${stw.goal.rolloutPercentage}%, bucket: ${bucket} → ${bucket < stw.goal.rolloutPercentage ? '✅' : '❌ FILTERED OUT!'}`);
    } else {
        console.log('   No rollout → ✅');
    }

    // STEP A.0: Schedule
    console.log('\n--- A.0. Schedule Check ---');
    if (stw.schedule) {
        const now = new Date();
        const end = stw.schedule.end_date ? new Date(stw.schedule.end_date) : null;
        const start = stw.schedule.start_date ? new Date(stw.schedule.start_date) : null;
        console.log(`   Now: ${now.toISOString()}`);
        console.log(`   Start: ${start?.toISOString() || 'none'}`);
        console.log(`   End: ${end?.toISOString() || 'none'}`);
        if (start && now < start) console.log('   ❌ NOT STARTED YET');
        else if (end && now > end) console.log('   ❌ ENDED!');
        else console.log('   ✅ Within schedule');
    } else {
        console.log('   No schedule → ✅');
    }

    // STEP A.2: Segments
    console.log('\n--- A.2. Segments Check ---');
    if (stw.segments && stw.segments.length > 0) {
        console.log(`   Required segments: ${JSON.stringify(stw.segments)}`);
        console.log('   ⚠️ Need to check user profile');
    } else {
        console.log('   No segments → ✅');
    }

    // STEP A.3: Frequency Capping
    console.log('\n--- A.3. Frequency Capping ---');
    
    const [impStats, lastSess] = await Promise.all([
        eventLogs.aggregate([
            { $match: { organization_id: ORG_ID, $or: userMatchQuery, nudge_id: { $in: nudgeIds }, event_type: { $in: ['impression', 'campaign_impression', 'NINJA_EXPERIENCE_OPEN'] } } },
            { $facet: {
                total: [{ $group: { _id: null, count: { $sum: 1 } } }],
                daily: [{ $match: { timestamp: { $gte: new Date(Date.now() - 86400000) } } }, { $group: { _id: null, count: { $sum: 1 } } }],
                weekly: [{ $match: { timestamp: { $gte: new Date(Date.now() - 604800000) } } }, { $group: { _id: null, count: { $sum: 1 } } }]
            }}
        ]).toArray(),
        eventLogs.findOne({ organization_id: ORG_ID, $or: userMatchQuery, event_type: 'session_start' }, { sort: { timestamp: -1 } })
    ]);

    const totalI = impStats[0]?.total[0]?.count || 0;
    const dailyI = impStats[0]?.daily[0]?.count || 0;
    const sessStart = lastSess?.timestamp || new Date(Date.now() - 1800000);
    console.log(`   Total: ${totalI}, Daily: ${dailyI}`);
    console.log(`   Session start: ${lastSess ? lastSess.timestamp.toISOString() : 'NONE'}`);

    const sessI = (await eventLogs.aggregate([
        { $match: { organization_id: ORG_ID, $or: userMatchQuery, nudge_id: { $in: nudgeIds }, event_type: { $in: ['impression', 'campaign_impression', 'NINJA_EXPERIENCE_OPEN'] }, timestamp: { $gte: sessStart } } },
        { $group: { _id: null, count: { $sum: 1 } } }
    ]).toArray())[0]?.count || 0;
    console.log(`   Session impressions: ${sessI}`);

    const dr = stw.display_rules || {};
    
    if (dr.frequency_cap) console.log(`   frequency_cap(${dr.frequency_cap}) vs total(${totalI}) → ${totalI < dr.frequency_cap ? '✅' : '❌ BLOCKED'}`);
    if (dr.interactionLimit) {
        console.log(`   interactionLimit: ${JSON.stringify(dr.interactionLimit)}`);
        if (dr.interactionLimit.type === 'limited') { const v = dr.interactionLimit.value || 1; console.log(`     limited(${v}) vs ${totalI} → ${totalI < v ? '✅' : '❌ BLOCKED'}`); }
        if (dr.interactionLimit.type === 'custom' && dr.interactionLimit.limit) console.log(`     custom(${dr.interactionLimit.limit}) vs ${totalI} → ${totalI < dr.interactionLimit.limit ? '✅' : '❌ BLOCKED'}`);
    }
    if (dr.frequency) {
        console.log(`   frequency: ${JSON.stringify(dr.frequency)}`);
        const ft = dr.frequency.type;
        const fv = dr.frequency.value || 1;
        if (ft === 'custom') console.log(`     custom(${fv}) vs ${totalI} → ${totalI < fv ? '✅' : '❌ BLOCKED'}`);
        if (ft === 'daily') console.log(`     daily(${fv}) vs ${dailyI} → ${dailyI < fv ? '✅' : '❌ BLOCKED'}`);
        if (ft === 'once_per_session') console.log(`     once_per_session vs ${sessI} → ${sessI < 1 ? '✅' : '❌ BLOCKED'}`);
    }
    if (dr.session_cap) console.log(`   session_cap(${dr.session_cap}) vs ${sessI} → ${sessI < dr.session_cap ? '✅' : '❌ BLOCKED'}`);
    if (dr.sessionLimit?.enabled) {
        const v = dr.sessionLimit.value || dr.sessionLimit.limit || 1;
        console.log(`   sessionLimit(${v}) vs ${sessI} → ${sessI < v ? '✅' : '❌ BLOCKED'}`);
    }

    // STEP B: Targeting
    console.log('\n--- B. Targeting Rules ---');
    if (stw.targeting && stw.targeting.length > 0) {
        let allPass = true;
        for (const rule of stw.targeting) {
            if (rule.type === 'group') continue;
            console.log(`\n   Rule: ${JSON.stringify(rule)}`);
            if (rule.type === 'event') {
                const evt = rule.event || rule.property || rule.field;
                const cnt = await eventLogs.countDocuments({ organization_id: ORG_ID, $or: userMatchQuery, event_type: evt });
                const tv = Number(rule.count || rule.value || 1);
                const op = rule.countOperator || rule.operator || 'greater_than_or_equal';
                let pass;
                switch (op) {
                    case 'greater_than_or_equal': pass = cnt >= tv; break;
                    case 'greater_than': pass = cnt > tv; break;
                    case 'equals': pass = cnt == tv; break;
                    default: pass = cnt >= tv;
                }
                console.log(`   Event "${evt}": count=${cnt}, target=${tv}, op=${op} → ${pass ? '✅' : '❌'}`);
                if (!pass) allPass = false;
            }
        }
        console.log(`\n   Overall targeting: ${allPass ? '✅ ALL PASS' : '❌ FAILED'}`);
    } else {
        console.log('   No targeting → ✅');
    }

    // STEP C: ⚠️ hasTriggerPropertyRule CHECK (THE SUSPECT!)
    console.log('\n--- C. ⚠️⚠️⚠️ hasTriggerPropertyRule CHECK (Line 583-592) ---');
    
    let effectiveTrigger = stw.trigger_event;
    if (effectiveTrigger === 'session_start' || effectiveTrigger === 'all') {
        if (stw.targeting) {
            const first = stw.targeting.find(r => r.type === 'event');
            if (first?.event) {
                console.log(`   trigger_event "${effectiveTrigger}" overridden → "${first.event}"`);
                effectiveTrigger = first.event;
            }
        }
    }
    console.log(`   Effective trigger_event: "${effectiveTrigger}"`);
    
    if (stw.targeting && Array.isArray(stw.targeting)) {
        const result = stw.targeting.some(r => {
            const match = r.type === 'event' && 
                (r.event === effectiveTrigger || effectiveTrigger === 'all' || effectiveTrigger === 'session_start') &&
                (r.properties?.length > 0 || r.field);
            if (match) {
                console.log(`   🔴 MATCHING RULE FOUND:`);
                console.log(`      type=${r.type}, event=${r.event}`);
                console.log(`      properties=${JSON.stringify(r.properties)}`);
                console.log(`      field=${r.field}`);
            }
            return match;
        });
        
        if (result) {
            console.log(`\n   ❌❌❌ hasTriggerPropertyRule = TRUE`);
            console.log(`   THE CAMPAIGN IS BEING SKIPPED BY LINE 589-591!`);
            console.log(`   This is the ROOT CAUSE!`);
        } else {
            console.log(`   ✅ hasTriggerPropertyRule = false`);
        }
    }

    await mongoose.disconnect();
    console.log('\n✅ Done');
}

main().catch(err => { console.error('Fatal:', err); process.exit(1); });
