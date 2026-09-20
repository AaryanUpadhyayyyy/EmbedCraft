require('dotenv').config();
const mongoose = require('mongoose');
const Organization = require('../src/models/Organization');

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/nudge_db';

async function listOrgs() {
    try {
        await mongoose.connect(MONGO_URI);
        const orgs = await Organization.find({}, 'name app_scheme');
        console.log('Orgs in DB:');
        orgs.forEach(o => console.log(`- ${o.name} (app_scheme: ${o.app_scheme || 'null'})`));
        process.exit(0);
    } catch (error) {
        console.error(error);
        process.exit(1);
    }
}

listOrgs();
