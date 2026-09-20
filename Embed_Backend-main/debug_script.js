const mongoose = require('mongoose');
mongoose.connect('mongodb://localhost:27017/embedfin_core').then(async () => {
    const Nudge = require('./src/models/Nudge.js');
    const campaigns = await Nudge.find({ status: { $ne: 'archived' } }).sort({createdAt: -1}).limit(2);
    console.log(JSON.stringify(campaigns, null, 2));
    process.exit(0);
}).catch(e => { console.error(e); process.exit(1); });
