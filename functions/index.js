const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
admin.initializeApp();

const stripe = require('stripe')(functions.config().stripe.secret_key);


exports.stripeOAuthCallback = functions.https.onRequest(async (req, res) => {
  const authorizationCode = req.query.code;

  try {
    // Exchange the authorization code for a Stripe token
    const response = await axios.post('https://connect.stripe.com/oauth/token', null, {
      params: {
        client_id: functions.config().stripe.client_id,
        client_secret: functions.config().stripe.secret_key,
        code: authorizationCode,
        grant_type: 'authorization_code',
      },
    });

    const stripeAccountId = response.data.stripe_user_id;
    const userId = req.query.state;

    if (userId) {
      // Store the stripe_account_id in Firestore
      await admin.firestore().collection('Sellers').doc(userId).update({
        stripeAccountId: stripeAccountId,
      });

      // Redirect the seller to the Stripe-hosted account setup page
      const accountLink = await stripe.accountLinks.create({
        account: stripeAccountId,
        refresh_url: 'yourapp://oauth/callback',
        return_url: 'yourapp://oauth/callback',
        type: 'account_onboarding',
      });

      res.redirect(accountLink.url); // Redirect to Stripe's account onboarding page
    } else {
      res.status(400).send('User ID is missing.');
    }
  } catch (error) {
    console.error('Error during Stripe OAuth callback:', error);
    res.status(500).send({ success: false, error: error.message });
  }
});

exports.stripeMultiSellerPaymentIntent = functions.https.onRequest(async (req, res) => {
  try {
    const sellers = req.body.sellers;
  
    if (!sellers || !Array.isArray(sellers)) {
      res.status(400).send({ success: false, message: "Invalid sellers data format" });
      return;
    }

    const paymentResults = [];

    for (const seller of sellers) {
      const { stripeAccountId, amount } = seller;
      if (!stripeAccountId || !amount) {
        paymentResults.push({ success: false, message: "Missing stripeAccountId or amount", seller });
        continue;
      }

      const paymentIntent = await stripe.paymentIntents.create({
        amount: parseInt(amount),
        currency: "usd",
        payment_method_types: ["card"],
        transfer_data: {
          destination: stripeAccountId,
        },
        description: `Payment for Seller ${stripeAccountId}`,
      });

      paymentResults.push({
        success: true,
        paymentIntent: paymentIntent.client_secret,
        seller: stripeAccountId,
      });
    }

    res.status(200).send({
      success: true,
      paymentResults,
    });
  } catch (error) {
    console.error("Error processing multi-seller payments:", error);
    res.status(500).send({ success: false, error: error.message });
  }
});
