import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class StripeConnectScreen extends StatelessWidget {
  final String stripeClientId = 'YOUR_STRIPE_CLIENT_ID';
  final String redirectUri = 'YOUR_FIREBASE_FUNCTION_REDIRECT_URL';

  Future<void> _connectWithStripe() async {
    final Uri stripeUrl = Uri.parse(
      'https://connect.stripe.com/oauth/authorize'
      '?response_type=code'
      '&client_id=$stripeClientId'
      '&scope=read_write'
      '&redirect_uri=$redirectUri',
    );

    if (await canLaunchUrl(stripeUrl)) {
      await launchUrl(stripeUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open Stripe Connect URL';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect with Stripe"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _connectWithStripe,
          child: const Text("Connect with Stripe"),
        ),
      ),
    );
  }
}
