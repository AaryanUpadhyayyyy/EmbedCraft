const mongoose = require('mongoose');

const MONGO_URI = 'mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/?appName=EmbedCraft';
const ORG_ID = '692ea4db3d70137fcfc1ed13';

async function main() {
    await mongoose.connect(MONGO_URI);
    const db = mongoose.connection.useDb('embedcraft', { useCache: true }); // Default DB for main org collection
    const orgs = db.collection('organizations');
    
    const org = await orgs.findOne({ _id: new mongoose.Types.ObjectId(ORG_ID) });
    if (org) {
        console.log(`API Key: ${org.api_key}`);
        console.log(`Staging Key: ${org.staging_api_key}`);
    } else {
        console.log('Org not found in default DB.');
    }
    await mongoose.disconnect();
}

main().catch(err => { console.error(err); process.exit(1); });
