const mongoose = require('mongoose');

async function check() {
  await mongoose.connect('mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/nudge_db?appName=EmbedCraft');
  const orgs = await mongoose.connection.db.collection('organizations').find({}).toArray();
  orgs.forEach(o => console.log(o.name, o.app_scheme, o.admin_email));
  process.exit(0);
}
check();
