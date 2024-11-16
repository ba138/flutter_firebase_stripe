const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')('sk_test_51QLjHlELdLmOhrIRw5IN0VzbUuRYCinX0Uszj5Tpvm1N0iI9LNLN4DxTE3kwJmJ1ZEbH0owsCHle7tbSVVr1b4uw00j7MFniTD');
const axios = require('axios');

admin.initializeApp();

exports.stripeOAuthCallback = functions.https.onRequest(async (req, res) => {
  const authorizationCode = req.query.code;

  try {
    const response = await axios.post('https://connect.stripe.com/oauth/token', null, {
      params: {
        client_id: 'YOUR_STRIPE_CLIENT_ID',
        client_secret: 'sk_test_51QLjHlELdLmOhrIRw5IN0VzbUuRYCinX0Uszj5Tpvm1N0iI9LNLN4DxTE3kwJmJ1ZEbH0owsCHle7tbSVVr1b4uw00j7MFniTD',
        code: authorizationCode,
        grant_type: 'authorization_code',
      },
    });

    const stripeAccountId = response.data.stripe_user_id;

    // Get user ID from a query parameter or other method
    const userId = req.query.userId;
    if (userId) {
      // Save the stripeAccountId to the user's document in Firestore
      await admin.firestore().collection('users').doc(userId).update({
        stripeAccountId: stripeAccountId,
      });

      res.redirect('your-app://redirect-uri-success');
    } else {
      res.status(400).send('User ID is missing.');
    }
  } catch (error) {
    console.error('Error during Stripe OAuth callback:', error);
    res.status(500).send('Error connecting to Stripe.');
  }
});
