const mongoose = require('mongoose');

async function checkOrg() {
    const mongoUri = 'mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/nudge_db?appName=EmbedCraft';
    await mongoose.connect(mongoUri);

    const OrganizationSchema = new mongoose.Schema({}, { strict: false });
    // Use the model on default connection
    const Organization = mongoose.model('Organization', OrganizationSchema);

    const apiKey = 'nk_live_bcecb88d32c3a9353e5e765f45e03055';
    console.log('Searching for organization with API key:', apiKey);

    const org = await Organization.findOne({
        $or: [
            { api_key: apiKey },
            { staging_api_key: apiKey }
        ]
    }).lean();

    if (org) {
        console.log('Found Organization:');
        console.log(JSON.stringify(org, null, 2));
    } else {
        console.log('Organization not found!');
    }

    await mongoose.disconnect();
}

checkOrg().catch(console.error);
