const mongoose = require('mongoose');

async function check() {
  await mongoose.connect('mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/nudge_db?appName=EmbedCraft');
  const orgs = await mongoose.connection.collection('organizations').find({ app_scheme: 'bigbasket://home' }).toArray();
  console.log(orgs);
  process.exit(0);
}
check();
