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
        refresh_url: 'https://oauth/callback',
        return_url: 'https://oauth/callback',
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
        currency: "EUR",
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
exports.createPayout = functions.https.onRequest(async (req, res) => {
  try {
    const { stripeAccountId, amount, currency } = req.body;

    // Validate input parameters
    if (!stripeAccountId || !amount || !currency) {
      res.status(400).send({ success: false, message: "Missing required parameters: stripeAccountId, amount, or currency." });
      return;
    }

    const parsedAmount = parseInt(amount);
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      res.status(400).send({ success: false, message: "Invalid amount. It must be a positive integer in the smallest currency unit." });
      return;
    }

    // Fetch account balance
    const balance = await stripe.balance.retrieve({
      stripeAccount: stripeAccountId,
    });

    // Find available balances in requested currency
    const availableBalance = balance.available.find((b) => b.currency === currency.toLowerCase());

    if (!availableBalance) {
      res.status(400).send({
        success: false,
        message: `No available balance found for the currency ${currency.toUpperCase()}.`
      });
      return;
    }

    const availableAmountInMainUnit = (availableBalance.amount / 100).toFixed(2);

    // Check if there is available balance in either 'card' or 'bank_account'
    const availableCardBalance = availableBalance.source_types.card || 0;
    const availableBankBalance = availableBalance.source_types.bank_account || 0;

    // Ensure sufficient funds in either card or bank account
    if (availableCardBalance + availableBankBalance < parsedAmount) {
      res.status(400).send({
        success: false,
        message: `Insufficient balance for this payout. Available balance: ${availableAmountInMainUnit} ${currency.toUpperCase()}.`
      });
      return;
    }

    // Determine the source type for payout
    let sourceType = 'bank_account'; // Default to bank_account
    if (availableCardBalance >= parsedAmount) {
      sourceType = 'card'; // If card balance is sufficient, use card
    }

    // Create the payout
    const payout = await stripe.payouts.create(
      {
        amount: parsedAmount,
        currency: currency.toLowerCase(),
        source_type: sourceType,
      },
      {
        stripeAccount: stripeAccountId,
      }
    );

    res.status(200).send({
      success: true,
      message: "Payout created successfully.",
      payout,
    });
  } catch (error) {
    console.error("Error creating payout:", error);
    res.status(500).send({
      success: false,
      message: "Failed to create payout.",
      error: error.message,
    });
  }
});

