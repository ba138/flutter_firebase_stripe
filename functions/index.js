const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
admin.initializeApp();

// Load Stripe client with the secret key from environment config
const stripe = require('stripe')(functions.config().stripe.secret_key);

exports.stripeOAuthCallback = functions.https.onRequest(async (req, res) => {
  const authorizationCode = req.query.code;

  try {
    // Use environment variables for Stripe client ID and secret key
    const response = await axios.post('https://connect.stripe.com/oauth/token', null, {
      params: {
        client_id: functions.config().stripe.client_id,
        client_secret: functions.config().stripe.secret_key,
        code: authorizationCode,
        grant_type: 'authorization_code',
      },
    });

    const stripeAccountId = response.data.stripe_user_id;

    // Get user ID from a query parameter
    const userId = req.query.state;
    if (userId) {
      // Save the stripeAccountId to the user's document in Firestore
      await admin.firestore().collection('users').doc(userId).update({
        stripeAccountId: stripeAccountId,
      });

      // Redirect back to the app with a success message or URI scheme
      res.redirect('yourapp://oauth/callback'); // Replace with your app's URI scheme
    } else {
      res.status(400).send('User ID is missing.');
    }
  } catch (error) {
    console.error('Error during Stripe OAuth callback:', error);
    res.status(500).send('Error connecting to Stripe.');
  }
});