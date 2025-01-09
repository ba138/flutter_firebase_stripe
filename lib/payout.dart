import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PayoutScreen extends StatefulWidget {
  @override
  _PayoutScreenState createState() => _PayoutScreenState();
}

class _PayoutScreenState extends State<PayoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();

  bool _isLoading = false;
  String? _responseMessage;

  Future<void> _createPayout(String stripeAccountId) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _responseMessage = null;
    });

    try {
      final amountInCents =
          (double.parse(_amountController.text) * 100).toInt();
      print("this is the amountInCents:$amountInCents ");

      final response = await http.post(
        Uri.parse(
            'https://us-central1-stripe-44121.cloudfunctions.net/createPayout'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'stripeAccountId': stripeAccountId,
          'amount': amountInCents,
          'currency': _currencyController.text.toLowerCase(),
        }),
      );
      debugPrint("this is the response body:${response.body}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            _responseMessage =
                "Payout successful: ${responseData['payout']['id']}";
          });
        } else {
          setState(() {
            _responseMessage = "Error: ${responseData['message']}";
          });
        }
      } else {
        setState(() {
          _responseMessage = "Error: ${response.body}";
        });
      }
    } catch (error) {
      setState(() {
        _responseMessage = "Error: $error";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Payout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (in cents)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currencyController,
                decoration: const InputDecoration(
                  labelText: 'Currency (e.g., USD)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a currency';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        _createPayout('acct_1QfO0hKDEFDNLABn');
                      },
                      child: const Text('Create Payout'),
                    ),
              const SizedBox(height: 16),
              if (_responseMessage != null)
                Text(
                  _responseMessage!,
                  style: TextStyle(
                    color: _responseMessage!.contains('Error')
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
