const mongoose = require('mongoose');

const mongoUri = 'mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/?appName=EmbedCraft';

async function checkAssets() {
    try {
        console.log('🔌 Connecting to MongoDB...');
        await mongoose.connect(mongoUri);
        console.log('✅ Connected.');

        // Get admin interface
        const admin = mongoose.connection.db.admin();
        const dbsResult = await admin.listDatabases();
        
        console.log('\n--- Databases List ---');
        const dbNames = dbsResult.databases.map(d => d.name);
        console.log(dbNames);

        for (const dbName of dbNames) {
            if (dbName.startsWith('tenant_') || dbName === 'test') {
                const db = mongoose.connection.useDb(dbName);
                const collections = await db.db.listCollections().toArray();
                const collectionNames = collections.map(c => c.name);
                
                if (collectionNames.includes('assets')) {
                    const count = await db.collection('assets').countDocuments();
                    console.log(`\n📦 DB: ${dbName} -> assets count: ${count}`);
                    if (count > 0) {
                        const docs = await db.collection('assets').find().sort({ createdAt: -1 }).limit(5).toArray();
                        console.log('Latest 5 assets:');
                        docs.forEach(doc => {
                            console.log(` - ID: ${doc._id}, Name: ${doc.name}, Type: ${doc.type}, OrgID: ${doc.organization_id}, URL: ${doc.url}, CreatedAt: ${doc.createdAt}`);
                        });
                    }
                }
            }
        }

    } catch (err) {
        console.error('Error:', err);
    } finally {
        await mongoose.disconnect();
        console.log('\n🔌 Disconnected.');
    }
}

checkAssets();
