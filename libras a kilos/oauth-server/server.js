const express = require('express');
const axios = require('axios');
const app = express();
const port = 63477;

app.get('/', async (req, res) => {
  const code = req.query.code;
  const state = req.query.state;

  if (!code) {
    return res.send('No code provided');
  }

  try {
    const response = await axios.post('https://github.com/login/oauth/access_token', {
      client_id: 'Ov23lizQX1EWa6FjMj3s',
      client_secret: '1108b4be458b2040cec5ed25c014df160604104c',
      code: code,
      redirect_uri: 'http://127.0.0.1:63477/',
      state: state
    }, {
      headers: {
        'Accept': 'application/json'
      }
    });

    const accessToken = response.data.access_token;
    res.send(`Access Token: ${accessToken}`);
  } catch (error) {
    res.send(`Error: ${error.message}`);
  }
});

app.listen(port, () => {
  console.log(`Server running at http://127.0.0.1:${port}/`);
});