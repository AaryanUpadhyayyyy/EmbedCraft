const mongoose = require('mongoose');

async function listCollections() {
    const mongoUri = 'mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/?appName=EmbedCraft';
    await mongoose.connect(mongoUri);

    console.log('Connected to MongoDB. Databases:');
    const adminDb = mongoose.connection.db.admin();
    const dbs = await adminDb.listDatabases();
    dbs.databases.forEach(db => {
        if (db.name.startsWith('tenant_')) {
            console.log(`- ${db.name}`);
        }
    });

    const tenantDbName = 'tenant_692ea4db3d70137fcfc1ed13';
    console.log(`\nCollections in ${tenantDbName}:`);
    const db = mongoose.connection.useDb(tenantDbName);
    const collections = await db.db.listCollections().toArray();
    collections.forEach(c => {
        console.log(`- ${c.name}`);
    });

    await mongoose.disconnect();
}

listCollections().catch(console.error);
