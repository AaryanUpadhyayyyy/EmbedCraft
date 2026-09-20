const mongoose = require('mongoose');
mongoose.connect('mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/?appName=EmbedCraft')
  .then(async () => {
    const UserLedger = mongoose.model('UserLedger', new mongoose.Schema({}, {strict: false}), 'userledgers');
    const counts = await UserLedger.aggregate([
      { $match: { campaign_id: '69da1691ccfe74b2f6d95c67' } },
      { $group: { _id: '$metadata.slice_id', count: { $sum: 1 } } }
    ]);
    console.log(counts);
    process.exit(0);
  })
  .catch(console.error);
