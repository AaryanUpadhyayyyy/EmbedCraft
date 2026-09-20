const mongoose = require('mongoose');

const MONGO_URI = 'mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/tenant_692ea4db3d70137fcfc1ed13?appName=EmbedCraft';
const USER_ID = 'PJ0N8JoyJ9WeANogCYwvcNcM3xt2';
const ANON_ID = '1781382578782_anon_hjg3uxgzsj';
const ORG_ID = '692ea4db3d70137fcfc1ed13';

async function main() {
    await mongoose.connect(MONGO_URI);
    const db = mongoose.connection.db;

    const eventLogs = db.collection('eventlogs');
    
    // 1. Count ALL events for this user (any match)
    const totalNoOrg = await eventLogs.countDocuments({
        $or: [{ user_id: USER_ID }, { anonymous_id: ANON_ID }]
    });
    console.log(`Total events for user (no org filter): ${totalNoOrg}`);
    
    const totalWithOrg = await eventLogs.countDocuments({
        organization_id: ORG_ID,
        $or: [{ user_id: USER_ID }, { anonymous_id: ANON_ID }]
    });
    console.log(`Total events for user (with org=${ORG_ID}): ${totalWithOrg}`);

    // 2. Check org_id type - maybe it's ObjectId not string
    const sample = await eventLogs.findOne({
        $or: [{ user_id: USER_ID }, { anonymous_id: ANON_ID }]
    });
    if (sample) {
        console.log(`\nSample event organization_id: "${sample.organization_id}" (type: ${typeof sample.organization_id})`);
        console.log(`Sample event_type: "${sample.event_type}"`);
        console.log(`Sample user_id: "${sample.user_id}"`);
        console.log(`Sample anonymous_id: "${sample.anonymous_id}"`);
    } else {
        console.log('\n❌ No events found for this user at all!');
    }

    // 3. Try with ObjectId for org
    const totalObjId = await eventLogs.countDocuments({
        organization_id: new mongoose.Types.ObjectId(ORG_ID),
        $or: [{ user_id: USER_ID }, { anonymous_id: ANON_ID }]
    });
    console.log(`Total events (org as ObjectId): ${totalObjId}`);

    // 4. Find ALL distinct event_types for this user
    const distinctEvents = await eventLogs.distinct('event_type', {
        $or: [{ user_id: USER_ID }, { anonymous_id: ANON_ID }]
    });
    console.log(`\nDistinct event_types for user: ${JSON.stringify(distinctEvents)}`);

    // 5. Specifically look for profile_viewed events
    const profileViewed = await eventLogs.countDocuments({
        $or: [{ user_id: USER_ID }, { anonymous_id: ANON_ID }],
        event_type: 'profile_viewed'
    });
    console.log(`\nprofile_viewed events: ${profileViewed}`);

    // 6. Look for any events with "profile" in the type
    const profileRelated = await eventLogs.find({
        $or: [{ user_id: USER_ID }, { anonymous_id: ANON_ID }],
        event_type: { $regex: /profile/i }
    }).sort({ timestamp: -1 }).limit(5).toArray();
    console.log(`\nProfile-related events: ${profileRelated.length}`);
    profileRelated.forEach(e => {
        console.log(`   ${e.timestamp?.toISOString()} | type=${e.event_type} | org=${e.organization_id}`);
    });

    // 7. Show last 30 events for this user
    const recent = await eventLogs.find({
        $or: [{ user_id: USER_ID }, { anonymous_id: ANON_ID }]
    }).sort({ timestamp: -1 }).limit(30).toArray();
    console.log(`\nLast 30 events:`);
    recent.forEach(e => {
        console.log(`   ${e.timestamp?.toISOString()} | type=${e.event_type} | nudge=${e.nudge_id || '-'} | org=${e.organization_id}`);
    });

    await mongoose.disconnect();
}

main().catch(err => { console.error(err); process.exit(1); });
