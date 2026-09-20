/**
 * Verify: Does Mongoose auto-cast organization_id for EventLog queries?
 * Tests both aggregate (no cast) and countDocuments (auto-cast)
 */
const mongoose = require('mongoose');

const MONGO_URI = 'mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/?appName=EmbedCraft';
const ORG_ID = '692ea4db3d70137fcfc1ed13';
const USER_ID = 'PJ0N8JoyJ9WeANogCYwvcNcM3xt2';

async function main() {
    await mongoose.connect(MONGO_URI);
    
    // Simulate what the controller does: use the tenant connection
    const tenantConn = mongoose.connection.useDb('tenant_692ea4db3d70137fcfc1ed13', { useCache: true });
    
    // Compile EventLog model on tenant connection
    const EventLogSchema = require('./src/models/EventLog').schema || new mongoose.Schema({
        organization_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization', required: true },
        user_id: String,
        anonymous_id: String,
        event_type: String,
        nudge_id: String,
        timestamp: Date,
        metadata: Object
    });

    // Get the EventLog model directly from the module
    const EventLog = require('./src/models/EventLog');
    
    // But use it through the tenant connection like the proxy does
    const TenantEventLog = tenantConn.models['EventLog'] || tenantConn.model('EventLog', EventLogSchema);

    console.log('=== TEST 1: Mongoose model.countDocuments (auto-casts) ===');
    try {
        const count1 = await TenantEventLog.countDocuments({
            organization_id: ORG_ID,  // String - should auto-cast to ObjectId
            user_id: USER_ID,
            event_type: 'profile_viewed'
        });
        console.log(`countDocuments with STRING org_id: ${count1}`);
    } catch (e) {
        console.log(`countDocuments error: ${e.message}`);
    }

    console.log('\n=== TEST 2: Mongoose model.countDocuments with ObjectId ===');
    try {
        const count2 = await TenantEventLog.countDocuments({
            organization_id: new mongoose.Types.ObjectId(ORG_ID),
            user_id: USER_ID,
            event_type: 'profile_viewed'
        });
        console.log(`countDocuments with ObjectId org_id: ${count2}`);
    } catch (e) {
        console.log(`countDocuments error: ${e.message}`);
    }

    console.log('\n=== TEST 3: Mongoose model.aggregate (NO auto-cast!) ===');
    try {
        const result3 = await TenantEventLog.aggregate([
            {
                $match: {
                    organization_id: ORG_ID,  // String - will NOT auto-cast in aggregate!
                    user_id: USER_ID,
                    event_type: 'profile_viewed'
                }
            },
            { $count: 'total' }
        ]);
        console.log(`aggregate with STRING org_id: ${result3[0]?.total || 0}`);
    } catch (e) {
        console.log(`aggregate error: ${e.message}`);
    }

    console.log('\n=== TEST 4: Mongoose model.aggregate with ObjectId ===');
    try {
        const result4 = await TenantEventLog.aggregate([
            {
                $match: {
                    organization_id: new mongoose.Types.ObjectId(ORG_ID),
                    user_id: USER_ID,
                    event_type: 'profile_viewed'
                }
            },
            { $count: 'total' }
        ]);
        console.log(`aggregate with ObjectId org_id: ${result4[0]?.total || 0}`);
    } catch (e) {
        console.log(`aggregate error: ${e.message}`);
    }

    await mongoose.disconnect();
    console.log('\nDone');
}

main().catch(err => { console.error(err); process.exit(1); });
