const mongoose = require('mongoose');

const MONGO_URI = 'mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/?appName=EmbedCraft';
const ORG_ID = '692ea4db3d70137fcfc1ed13';
const USER_ID = 'PJ0N8JoyJ9WeANogCYwvcNcM3xt2';
const ANON_ID = '1781382578782_anon_hjg3uxgzsj';

async function main() {
    await mongoose.connect(MONGO_URI);
    
    // Import controller and models
    const nudgeController = require('./src/controllers/nudgeController');
    const { tenantStorage } = require('./src/services/tenantConnectionManager');
    
    const dbName = `tenant_${ORG_ID}`;
    const connection = mongoose.connection.useDb(dbName, { useCache: true });
    
    // WE NEED TO MONKEY-PATCH THE NUDGE CONTROLLER'S OR MODEL'S LOGIC?
    // Actually, I just want to find out what Spin The Wheel evaluates to.
    
    await tenantStorage.run({ connection }, async () => {
        const req = {
            query: {
                userId: USER_ID,
                anonymousId: ANON_ID,
                screenName: 'all',
                platform: 'android'
            },
            headers: {},
            orgId: ORG_ID
        };
        
        let responseBody = null;
        const res = {
            setHeader: function(k, v) { return this; },
            status: function(code) { return this; },
            json: function(data) { responseBody = data; return this; }
        };
        
        await nudgeController.fetchNudge(req, res);
        
        console.log('=== REAL API RESPONSE ===');
        const activeIds = [];
        const inactiveIds = [];
        
        if (responseBody && responseBody.data) {
            for (const n of responseBody.data) {
                if (n.status === 'active') activeIds.push(n.campaign_name || n.nudge_id);
                else inactiveIds.push(n.campaign_name || n.nudge_id);
            }
        }
        
        console.log(`Matched (active): ${activeIds.join(', ')}`);
        console.log(`Invalid (inactive): ${inactiveIds.join(', ')}`);
        
        const Nudge = connection.model('Nudge');
        const stw = await Nudge.findOne({ nudge_id: 'nudge_1775900305496_68yjy32kg' }).lean();
        console.log(`\nSpin The Wheel in DB: ${stw.campaign_name}`);
        
        const returnedStw = responseBody?.data?.find(n => n.nudge_id === 'nudge_1775900305496_68yjy32kg');
        console.log(`Spin The Wheel present in response? ${!!returnedStw}`);
    });

    await mongoose.disconnect();
}

main().catch(err => { console.error(err); process.exit(1); });
