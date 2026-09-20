const mongoose = require('mongoose');

const MONGO_URI = 'mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/?appName=EmbedCraft';

async function main() {
    await mongoose.connect(MONGO_URI);
    const adminDb = mongoose.connection.db.admin();
    
    // List all databases
    const dbs = await adminDb.listDatabases();
    console.log('📋 All databases:');
    for (const db of dbs.databases) {
        if (db.name.startsWith('tenant_')) {
            console.log(`   🏢 ${db.name} (${(db.sizeOnDisk / 1024 / 1024).toFixed(1)}MB)`);
        }
    }
    
    // Now check the tenant DB that contains nudges for our org
    // Try the default db first
    const defaultDb = mongoose.connection.db;
    
    // Search across all tenant databases for the Spin The Wheel campaign
    for (const db of dbs.databases) {
        if (!db.name.startsWith('tenant_')) continue;
        
        const tenantDb = mongoose.connection.client.db(db.name);
        const collections = await tenantDb.listCollections().toArray();
        const hasNudges = collections.some(c => c.name === 'nudges');
        
        if (hasNudges) {
            const nudges = tenantDb.collection('nudges');
            const spinWheel = await nudges.findOne({ title: { $regex: /spin/i } });
            if (spinWheel) {
                console.log(`\n🎰 FOUND "Spin The Wheel" in database: ${db.name}`);
                console.log(`   _id: ${spinWheel._id}`);
                console.log(`   title: ${spinWheel.title}`);
                console.log(`   status: ${spinWheel.status}`);
                console.log(`   organization_id: ${spinWheel.organization_id}`);
                console.log(`   trigger_event: ${spinWheel.trigger_event}`);
            }
            
            // Also list all active campaigns in this DB
            const allActive = await nudges.find({ status: 'active' }).project({ 
                title: 1, name: 1, trigger_event: 1, organization_id: 1, nudge_id: 1 
            }).toArray();
            
            if (allActive.length > 0) {
                console.log(`\n📋 Active campaigns in ${db.name}: ${allActive.length}`);
                for (const c of allActive) {
                    console.log(`   - ${c.title || c.name} | org=${c.organization_id} | trigger=${c.trigger_event}`);
                }
            }
        }
    }
    
    await mongoose.disconnect();
}

main().catch(err => {
    console.error('Fatal:', err);
    process.exit(1);
});
