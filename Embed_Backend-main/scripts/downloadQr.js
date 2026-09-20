const https = require('https');
const fs = require('fs');

const url = "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=" + encodeURIComponent("amazon95845://capture?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJvcmdhbml6YXRpb25faWQiOiI2NjI4ZTNmZDc2Zjg5NGEwZDY1NjFkNTciLCJ0eXBlIjoicGFnZV9jYXB0dXJlX3Nlc3Npb24iLCJpYXQiOjE3MTQ0MDU2NDAsImV4cCI6MTcxNDQwNjI0MH0.V1_fT-7REfLyXCA");

https.get(url, (res) => {
  const file = fs.createWriteStream("test_qr.png");
  res.pipe(file);
  file.on('finish', () => {
    file.close();
    console.log("Downloaded QR code");
  });
});
