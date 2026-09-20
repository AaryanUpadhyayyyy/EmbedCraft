const fs = require('fs');
// Write a quick check
console.log('File size:', fs.statSync('test_qr.png').size);
