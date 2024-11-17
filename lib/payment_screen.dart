import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  void initiatePayments() {
    List<Map<String, dynamic>> sellers = [
      {
        'stripeAccountId': 'acct_1QM5wSG83iV0r8zZ',
        'amount': 5000,
      },
    ];

    initiateMultiSellerPayment(sellers);
  }

  Future<void> initiateMultiSellerPayment(
      List<Map<String, dynamic>> sellers) async {
    // Replace with your Firebase Cloud Function endpoint
    final url = Uri.parse(
        'https://your-cloud-function-url/stripeMultiSellerPaymentIntent');

    try {
      final response = await https.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'sellers': sellers,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if payments were successful
        if (data['success']) {
          final paymentResults = data['paymentResults'];
          for (var result in paymentResults) {
            if (result['success']) {
              debugPrint(
                  'Payment for seller ${result['seller']} succeeded. Client secret: ${result['paymentIntent']}');
            } else {
              debugPrint('Payment for seller ${result['seller']} failed.');
            }
          }
        } else {
          debugPrint('Payment failed: ${data['error']}');
        }
      } else {
        debugPrint('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error initiating payment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: () {}, child: const Text("Pay")),
      ),
    );
  }
}
