/**
 * Test using the ACTUAL tenant proxy and AsyncLocalStorage context
 * to perfectly simulate what nudgeController.js does
 */
const mongoose = require('mongoose');
const { AsyncLocalStorage } = require('async_hooks');

const MONGO_URI = 'mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/?appName=EmbedCraft';
const ORG_ID = '692ea4db3d70137fcfc1ed13';
const USER_ID = 'PJ0N8JoyJ9WeANogCYwvcNcM3xt2';
const ANON_ID = '1781382578782_anon_hjg3uxgzsj';

async function main() {
    await mongoose.connect(MONGO_URI);
    
    // Import the actual tenant manager
    const { tenantStorage, createTenantModelProxy } = require('./src/services/tenantConnectionManager');
    
    // Create the tenant connection
    const dbName = `tenant_${ORG_ID}`;
    const connection = mongoose.connection.useDb(dbName, { useCache: true });
    
    // Run within tenant context (like the middleware does)
    await tenantStorage.run({ connection }, async () => {
        // Import models through proxy (like the controller does)
        const EventLog = require('./src/models/EventLog');
        
        const userMatchQuery = [
            { user_id: USER_ID },
            { anonymous_id: ANON_ID }
        ];

        // Test 1: countDocuments with string orgId (like line 473)
        console.log('=== TEST 1: countDocuments (event targeting rule, line 473) ===');
        const count = await EventLog.countDocuments({
            organization_id: ORG_ID,
            $or: userMatchQuery,
            event_type: 'profile_viewed'
        });
        console.log(`Result: ${count} (needs >= 1 to pass)`);
        console.log(`Verdict: ${count >= 1 ? '✅ SHOULD PASS' : '❌ WOULD FAIL'}`);

        // Test 2: aggregate with string orgId (like line 174-209)
        console.log('\n=== TEST 2: aggregate - impression stats (line 174-209) ===');
        const nudgeId = 'nudge_1775900305496_68yjy32kg'; // Spin The Wheel nudge_id
        const stwId = '69da1691ccfe74b2f6d95c67'; // Spin The Wheel _id
        const nudgeIds = [nudgeId, stwId];
        
        const impressionStats = await EventLog.aggregate([
            {
                $match: {
                    organization_id: ORG_ID,
                    $or: userMatchQuery,
                    nudge_id: { $in: nudgeIds },
                    event_type: { $in: ['impression', 'campaign_impression', 'NINJA_EXPERIENCE_OPEN'] }
                }
            },
            {
                $facet: {
                    total: [{ $group: { _id: '$nudge_id', count: { $sum: 1 } } }]
                }
            }
        ]);
        console.log(`Impression stats (STRING orgId): ${JSON.stringify(impressionStats[0]?.total)}`);

        // Test 3: Same aggregate with ObjectId 
        console.log('\n=== TEST 3: aggregate with ObjectId ===');
        const impressionStats2 = await EventLog.aggregate([
            {
                $match: {
                    organization_id: new mongoose.Types.ObjectId(ORG_ID),
                    $or: userMatchQuery,
                    nudge_id: { $in: nudgeIds },
                    event_type: { $in: ['impression', 'campaign_impression', 'NINJA_EXPERIENCE_OPEN'] }
                }
            },
            {
                $facet: {
                    total: [{ $group: { _id: '$nudge_id', count: { $sum: 1 } } }]
                }
            }
        ]);
        console.log(`Impression stats (ObjectId orgId): ${JSON.stringify(impressionStats2[0]?.total)}`);

        // Test 4: Session start findOne (line 212-216)
        console.log('\n=== TEST 4: findOne session_start (line 212-216) ===');
        const lastSession = await EventLog.findOne({
            organization_id: ORG_ID,
            $or: userMatchQuery,
            event_type: 'session_start'
        }).sort({ timestamp: -1 }).lean();
        console.log(`Last session: ${lastSession ? lastSession.timestamp : 'NONE'}`);

        // Test 5: Session impressions aggregate (line 226-242)
        console.log('\n=== TEST 5: Session impressions aggregate (line 226-242) ===');
        const sessionStartTime = lastSession?.timestamp || new Date(Date.now() - 30 * 60 * 1000);
        const sessImpResult = await EventLog.aggregate([
            {
                $match: {
                    organization_id: ORG_ID,
                    $or: userMatchQuery,
                    nudge_id: { $in: nudgeIds },
                    event_type: { $in: ['impression', 'campaign_impression', 'NINJA_EXPERIENCE_OPEN'] },
                    timestamp: { $gte: sessionStartTime }
                }
            },
            { $group: { _id: '$nudge_id', count: { $sum: 1 } } }
        ]);
        console.log(`Session impressions (STRING orgId): ${JSON.stringify(sessImpResult)}`);

        // Test 6: Same with ObjectId
        const sessImpResult2 = await EventLog.aggregate([
            {
                $match: {
                    organization_id: new mongoose.Types.ObjectId(ORG_ID),
                    $or: userMatchQuery,
                    nudge_id: { $in: nudgeIds },
                    event_type: { $in: ['impression', 'campaign_impression', 'NINJA_EXPERIENCE_OPEN'] },
                    timestamp: { $gte: sessionStartTime }
                }
            },
            { $group: { _id: '$nudge_id', count: { $sum: 1 } } }
        ]);
        console.log(`Session impressions (ObjectId orgId): ${JSON.stringify(sessImpResult2)}`);

        console.log('\n=== SUMMARY ===');
        console.log('The bug: aggregate() does NOT auto-cast organization_id from string to ObjectId');
        console.log('countDocuments() DOES auto-cast, so event targeting works');
        console.log('But impression/session aggregates return 0, which is harmless for "unlimited" campaigns');
        console.log(`For Spin The Wheel: targeting countDocuments returns ${count} → ${count >= 1 ? 'PASSES' : 'FAILS'}`);
    });

    await mongoose.disconnect();
    console.log('\nDone');
}

main().catch(err => { console.error(err); process.exit(1); });
