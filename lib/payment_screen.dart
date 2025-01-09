import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;

  Future<void> initMultiSellerPayment(
      List<Map<String, dynamic>> sellers) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "https://us-central1-stripe-44121.cloudfunctions.net/stripeMultiSellerPaymentIntent",
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'sellers': sellers}),
      );

      final jsonResponse = jsonDecode(response.body);
      debugPrint("this is the response body:${response.body}");
      if (jsonResponse['success'] == true) {
        for (var paymentResult in jsonResponse['paymentResults']) {
          if (paymentResult['success'] == true) {
            final paymentIntentClientSecret = paymentResult['paymentIntent'];
            await Stripe.instance.initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                paymentIntentClientSecret: paymentIntentClientSecret,
                merchantDisplayName: 'Multi-Seller Service',
              ),
            );
            await Stripe.instance.presentPaymentSheet();
            // Save payment success in Firebase for each seller
            print("Payment successful for seller ${paymentResult['seller']}");
          } else {
            // Log the error for each failed payment attempt
            print(
                "Payment failed for seller ${paymentResult['seller']}: ${paymentResult['message']}");
          }
        }
        showSuccessDialog();
      } else {
        throw Exception('Failed to initialize payment intents for sellers.');
      }
    } catch (e) {
      print("Error in multi-seller payment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error in multi-seller payment")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Dummy method to show success dialog
  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Payment Successful"),
        content: Text("Payments have been completed for all sellers."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Multi-Seller Payment")),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () {
                  // Example seller data
                  List<Map<String, dynamic>> sellers = [
                    {
                      'stripeAccountId': 'acct_1QfETvK710PTgfwB',
                      'amount': 100000
                    },
                  ];
                  initMultiSellerPayment(sellers);
                },
                child: Text("Pay Sellers"),
              ),
      ),
    );
  }
}
