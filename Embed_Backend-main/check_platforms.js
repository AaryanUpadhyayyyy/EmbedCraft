const mongoose = require('mongoose');
const Nudge = require('./src/models/Nudge.js');

mongoose.connect('mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/test?appName=EmbedCraft')
  .then(async () => {
    const nudges = await Nudge.find().sort({createdAt:-1}).limit(1);
    console.log("LATEST CAMPAIGN:", nudges[0].campaign_name);
    console.log("PLATFORMS:", nudges[0].display_rules?.platforms || nudges[0].target_audience);
    process.exit(0);
  });
