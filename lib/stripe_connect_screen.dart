import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_stripe/payment_screen.dart';

import 'package:flutter_firebase_stripe/signup_screen.dart';

class StripeConnectScreen extends StatefulWidget {
  const StripeConnectScreen({super.key});

  @override
  State<StripeConnectScreen> createState() => _StripeConnectScreenState();
}

class _StripeConnectScreenState extends State<StripeConnectScreen> {
  final String stripeClientId = 'ca_R9k4oiSuxVz13O4iT42MYJFQy6a1G8IR';

  final String baseRedirectUri =
      'https://us-central1-stripe-44121.cloudfunctions.net/stripeOAuthCallback';

  Future<void> _connectWithStripe() async {
    var auth = FirebaseAuth.instance.currentUser!.uid;
    final String encodedUserId = Uri.encodeComponent(auth);

    // Use the `state` parameter to pass the userId safely
    final Uri stripeUrl = Uri.parse('https://connect.stripe.com/oauth/authorize'
        '?redirect_uri=https://us-central1-stripe-44121.cloudfunctions.net/stripeOAuthCallback' // your Firebase Cloud Function endpoint
        '&client_id=ca_R9k4oiSuxVz13O4iT42MYJFQy6a1G8IR'
        '&state=$encodedUserId' // Pass userId inside state
        '&response_type=code'
        '&scope=read_write'
        '&stripe_user[country]=DE');

    debugPrint("Stripe URL: ${stripeUrl.toString()}");
    EasyLauncher.url(url: stripeUrl.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect with Stripe"),
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: _connectWithStripe,
              child: const Text("Connect with Stripe"),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => const SignupScreen(),
                  ),
                );
              },
              child: const Text("Logout"),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => const PaymentScreen(),
                  ),
                );
              },
              child: const Text("Payment Screen"),
            ),
          ),
        ],
      ),
    );
  }
}
