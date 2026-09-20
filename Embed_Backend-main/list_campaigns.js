const mongoose = require('mongoose');

const MONGO_URI = 'mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/tenant_692ea4db3d70137fcfc1ed13?appName=EmbedCraft';
const ORG_ID = '692ea4db3d70137fcfc1ed13';

async function main() {
    await mongoose.connect(MONGO_URI);
    const db = mongoose.connection.db;

    const nudges = db.collection('nudges');
    
    // Get ALL campaigns for this org
    const all = await nudges.find({ organization_id: ORG_ID }).toArray();
    console.log(`Total campaigns: ${all.length}\n`);
    
    for (const c of all) {
        console.log('='.repeat(60));
        console.log(`_id: ${c._id}`);
        console.log(`nudge_id: ${c.nudge_id}`);
        console.log(`status: ${c.status}`);
        console.log(`trigger_event: ${c.trigger_event}`);
        console.log(`trigger_screens: ${JSON.stringify(c.trigger_screens)}`);
        // Print ALL string fields to find the name
        for (const [k, v] of Object.entries(c)) {
            if (typeof v === 'string' && k !== '_id' && k !== 'nudge_id' && k !== 'status' && 
                k !== 'trigger_event' && k !== 'organization_id') {
                console.log(`${k}: ${v.substring(0, 100)}`);
            }
        }
        console.log('');
    }
    
    await mongoose.disconnect();
}

main().catch(err => { console.error(err); process.exit(1); });
