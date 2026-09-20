const mongoose = require('mongoose');

async function check() {
  await mongoose.connect('mongodb+srv://admin:Sinister%40123@embedcraft.z923ska.mongodb.net/tenant_6a2baa7a38002e1f2eab9f77?appName=EmbedCraft');
  const Nudge = mongoose.connection.useDb('tenant_6a2baa7a38002e1f2eab9f77').collection('nudges');
  
  const docs = await Nudge.find({}).toArray();
  docs.forEach(doc => {
      console.log(doc.nudge_id, "platforms:", doc.display_rules?.platforms, "audience:", doc.target_audience);
  });
  process.exit(0);
}
check();
