const axios = require('axios');

async function testTrackEvent() {
  try {
    const res = await axios.post('http://localhost:4000/api/v1/nudge/track', {
      userId: 'test_user_rewards',
      platform: 'android',
      screenName: 'all',
      action: 'screen_views',
      metadata: {
        EventName: 'rewards_initialized',
        ScreenSlug: 'home'
      }
    }, {
      headers: {
        'x-api-key': 'nk_live_0a90aae3964062cc3b1c2bf9f84c4968'
      }
    });
    console.log(JSON.stringify(res.data, null, 2));
  } catch (e) {
    if (e.response && e.response.data) {
        console.error("API Response Error:", e.response.data);
    } else {
        console.error("Network Error:", e.message);
    }
  }
}

testTrackEvent();
