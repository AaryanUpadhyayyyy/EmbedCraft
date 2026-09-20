const mongoose = require('mongoose');
mongoose.connect('mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/?appName=EmbedCraft')
  .then(async () => {
    const Nudge = mongoose.model('Nudge', new mongoose.Schema({}, {strict: false}), 'nudges');
    await Nudge.updateOne(
      { _id: '69da1691ccfe74b2f6d95c67' },
      { $set: { 'config.spinTheWheelConfig.sections.0.quantity': 9999, 'config.spinTheWheelConfig.sections.1.quantity': 9999 } }
    );
    console.log('Quantities updated to 9999');
    process.exit(0);
  })
  .catch(console.error);
