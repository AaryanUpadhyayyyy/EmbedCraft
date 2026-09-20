require('dotenv').config();
const mongoose = require('mongoose');
const Nudge = require('./src/models/Nudge');

async function debugCampaign() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected!');

        const campaignId = '694abbb4d4aade4c794e221c';
        console.log(`Fetching Campaign ID: ${campaignId}`);

        const campaign = await Nudge.findById(campaignId).lean();

        if (!campaign) {
            console.log('❌ Campaign NOT FOUND in Database.');
        } else {
            console.log('✅ Campaign FOUND:');
            console.log(JSON.stringify(campaign, null, 2));
        }

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await mongoose.disconnect();
        process.exit();
    }
}

debugCampaign();
