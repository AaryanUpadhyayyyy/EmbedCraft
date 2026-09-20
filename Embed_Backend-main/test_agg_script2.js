const mongoose = require('mongoose');
mongoose.connect('mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/?appName=EmbedCraft')
.then(async () => {
    const EventLog = mongoose.model('EventLog', new mongoose.Schema({}, { strict: false }));
    try {
        const aggregatedStats = await EventLog.aggregate([
            { $limit: 10 },
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
                    }
                ]
            }}
        ]);
        console.log('SUCCESS');
    } catch(e) {
        require('fs').writeFileSync('mongo_err.txt', e.toString());
    }
    process.exit(0);
});
