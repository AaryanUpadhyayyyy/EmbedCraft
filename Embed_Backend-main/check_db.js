const mongoose = require('mongoose');

async function checkCampaigns() {
    await mongoose.connect('mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/?appName=EmbedCraft');
    const adminDb = mongoose.connection.db.admin();
    const dbs = await adminDb.listDatabases();
    const NudgeSchema = new mongoose.Schema({}, { strict: false });

    for (const dbInfo of dbs.databases) {
        if (dbInfo.name.startsWith('tenant_')) {
            const db = mongoose.connection.useDb(dbInfo.name);
            const Nudge = db.model('Nudge', NudgeSchema);
            const nudges = await Nudge.find({ _id: new mongoose.Types.ObjectId('6a2bee5c578d99c58a1b4986') }).lean();
            if (nudges.length > 0) {
                console.log(`Found in ${dbInfo.name}`);
                nudges.forEach(n => {
                    console.log(`\n========================================`);
                    console.log(`Campaign ID: ${n.nudge_id || n._id}`);
                    console.log(`Title: ${n.campaign_name}`);
                    console.log(`Trigger: ${n.trigger_event}`);
                    console.log(`Targeting: ${JSON.stringify(n.targeting, null, 2)}`);
                    console.log(`Triggers: ${JSON.stringify(n.triggers, null, 2)}`);
                });
            }
            
            // Or if it's the nudge_id:
            const nudges2 = await Nudge.find({ nudge_id: '6a2bee5c578d99c58a1b4986' }).lean();
            if (nudges2.length > 0) {
                 console.log(`Found by nudge_id in ${dbInfo.name}`);
                 nudges2.forEach(n => {
                    console.log(`\n========================================`);
                    console.log(`Campaign ID: ${n.nudge_id || n._id}`);
                    console.log(`Title: ${n.campaign_name}`);
                    console.log(`Trigger: ${n.trigger_event}`);
                    console.log(`Targeting: ${JSON.stringify(n.targeting, null, 2)}`);
                    console.log(`Triggers: ${JSON.stringify(n.triggers, null, 2)}`);
                });
            }
        }
    }
    
    mongoose.disconnect();
}

checkCampaigns().catch(console.error);
