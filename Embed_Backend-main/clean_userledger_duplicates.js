const mongoose = require('mongoose');

async function run() {
    const uri = 'mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/?appName=EmbedCraft';
    await mongoose.connect(uri);
    
    const dbsToClean = ['test', 'tenant_692ea4db3d70137fcfc1ed13', 'tenant_6a2baa7a38002e1f2eab9f77'];
    
    for (const dbName of dbsToClean) {
        console.log(`\n--- Cleaning DB: ${dbName} ---`);
        const db = mongoose.connection.client.db(dbName);
        
        const duplicates = await db.collection('userledgers').aggregate([
            {
                $group: {
                    _id: {
                        organization_id: "$organization_id",
                        end_user_id: "$end_user_id",
                        campaign_id: "$campaign_id",
                        reward_id: "$reward_id",
                        claim_source: "$claim_source",
                        slice_id: "$metadata.slice_id",
                        slice_name: "$metadata.slice_name",
                        coupon_code: "$metadata.coupon_code"
                    },
                    count: { $sum: 1 },
                    ids: { $push: "$_id" }
                }
            },
            {
                $match: { count: { $gt: 1 } }
            }
        ]).toArray();
        
        console.log(`Found ${duplicates.length} sets of duplicates in ${dbName}.`);
        
        let totalDeleted = 0;
        for (const group of duplicates) {
            // Keep the last one, delete the rest
            const idsToDelete = group.ids.slice(0, group.ids.length - 1);
            const result = await db.collection('userledgers').deleteMany({
                _id: { $in: idsToDelete }
            });
            totalDeleted += result.deletedCount;
        }
        console.log(`Deleted ${totalDeleted} duplicate ledger entries from ${dbName}!`);
    }
    
    await mongoose.disconnect();
    console.log("\nDone.");
}

run().catch(console.error);
