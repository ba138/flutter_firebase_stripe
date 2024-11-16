import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_stripe/signup_screen.dart';
import 'package:flutter_firebase_stripe/stripe_connect_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var auth = FirebaseAuth.instance;
  Future<void> seasionHandler() async {
    Future.delayed(
      const Duration(seconds: 5),
      () {
        if (auth.currentUser?.uid != null) {
          debugPrint("this is user id:${auth.currentUser!.uid}");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => StripeConnectScreen(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => const SignupScreen(),
            ),
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    seasionHandler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
