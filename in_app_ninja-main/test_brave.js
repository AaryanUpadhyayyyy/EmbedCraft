const https = require('https');

const url = 'https://imgs.search.brave.com/RFoqd7aMbaLmycMMhBwwuwOUee3sZhYg9D9kH5QmSGQ/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMDgv/ODU0LzcwMC9zbWFs/bC8zZC1jb2luLWZv/ci1maW5hbmNlLW9y/LWJ1c2luZXNzLWls/bHVzdHJhdGlvbi1w/bmcucG5n';

const options = {
  headers: {
    'User-Agent': 'Dart/2.19 (dart:io)'
  }
};

https.get(url, options, (res) => {
  console.log('Status Code:', res.statusCode);
  console.log('Headers:', res.headers);
}).on('error', (e) => {
  console.error(e);
});
