const mongoose = require('mongoose');
mongoose.connect('mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/?appName=EmbedCraft')
.then(async () => {
    const EventLog = mongoose.model('EventLog', new mongoose.Schema({}, { strict: false }));
    try {
        const aggregatedStats = await EventLog.aggregate([
            { $match: { event_type: { $exists: true } } },
            { $limit: 100 },
            { $facet: {
                audience: [
                    { $match: { metadata: { $exists: true, $type: 'object' } } },
                    { $project: { kv: { $objectToArray: '$metadata' } } },
                    { $unwind: '$kv' },
                    { 
                        $match: { 
                            $or: [
                                { 'kv.v': { $type: 'string' } },
                                { 'kv.v': { $type: 'number' } },
                                { 'kv.v': { $type: 'boolean' } }
                            ]
                        } 
                    },
                    { $group: { _id: { key: '$kv.k', value: '$kv.v' }, count: { $sum: 1 } } }
                ]
            }}
        ]);
        console.log('Agg:', JSON.stringify(aggregatedStats));
    } catch(e) {
        console.log('MONGO_ERROR:', e.stack);
    }
    process.exit(0);
});
