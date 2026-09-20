const mongoose = require('mongoose');

async function traceEvents() {
    const mongoUri = 'mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/?appName=EmbedCraft';
    await mongoose.connect(mongoUri);

    const tenantDbName = 'tenant_692ea4db3d70137fcfc1ed13';
    const db = mongoose.connection.useDb(tenantDbName);

    const EventLogSchema = new mongoose.Schema({}, { strict: false });
    const EventLog = db.model('EventLog', EventLogSchema);

    const userId = 'PJ0N8JoyJ9WeANogCYwvcNcM3xt2';
    const anonymousId = '1781382578782_anon_hjg3uxgzsj';
    const userMatchQuery = [{ user_id: userId }, { anonymous_id: anonymousId }];

    console.log('Tracing session_start and impression events for user:', userId);

    const sessionStarts = await EventLog.find({
        organization_id: '692ea4db3d70137fcfc1ed13',
        $or: userMatchQuery,
        event_type: 'session_start'
    }).sort({ timestamp: -1 }).limit(5).lean();

    console.log('\n--- Recent session_start events in DB ---');
    sessionStarts.forEach((s, idx) => {
        console.log(`[${idx}] Timestamp: ${s.timestamp} (${new Date(s.timestamp).toLocaleString()})`);
    });

    const spinWheelNudgeId = '69da1691ccfe74b2f6d95c67';
    const impressions = await EventLog.find({
        organization_id: '692ea4db3d70137fcfc1ed13',
        $or: userMatchQuery,
        nudge_id: { $in: [spinWheelNudgeId, 'nudge_1775906806085_spin_wheel'] },
        event_type: { $in: ['impression', 'campaign_impression', 'NINJA_EXPERIENCE_OPEN'] }
    }).sort({ timestamp: -1 }).limit(5).lean();

    console.log('\n--- Recent Spin The Wheel impressions in DB ---');
    impressions.forEach((imp, idx) => {
        console.log(`[${idx}] Timestamp: ${imp.timestamp} (${new Date(imp.timestamp).toLocaleString()})`);
    });

    if (sessionStarts.length > 0) {
        const lastSessionStart = sessionStarts[0].timestamp;
        console.log(`\nLast session_start: ${lastSessionStart}`);
        const sessImpressions = impressions.filter(imp => new Date(imp.timestamp) >= new Date(lastSessionStart));
        console.log(`Impressions since last session_start: ${sessImpressions.length}`);
        sessImpressions.forEach((imp) => {
            console.log(`  - Impression at ${imp.timestamp}`);
        });
    }

    await mongoose.disconnect();
}

traceEvents().catch(console.error);
