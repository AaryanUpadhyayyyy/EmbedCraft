const axios = require('axios');

async function testFetch() {
  try {
    const res = await axios.get('http://localhost:4000/api/v1/nudge/fetch?userId=test_user&platform=android&screenName=all', {
      headers: {
        'x-api-key': 'nk_live_0a90aae3964062cc3b1c2bf9f84c4968'
      }
    });
    console.log(JSON.stringify(res.data, null, 2));
  } catch (e) {
    console.error(e.response?.data || e.message);
  }
}

testFetch();
