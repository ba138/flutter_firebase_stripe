import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_stripe/stripe_connect_screen.dart';

class AuthRepository {
  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;

  Future<void> signupUser(
      String email, String password, String name, BuildContext context) async {
    try {
      // Await the user creation to ensure it completes before moving forward
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint("User created");

      // Save user data in Firestore only if the user is successfully created
      await saveSellerInfo(name);

      // Navigate to StripeConnectScreen only after saving data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => StripeConnectScreen(),
        ),
      );
    } catch (e) {
      debugPrint("Error during signup: $e");
    }
  }

  Future<void> saveSellerInfo(String name) async {
    try {
      // Verify that currentUser is available
      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        Map<String, dynamic> userData = {
          "name": name,
          "Gmail": currentUser.email,
          "SellerId": currentUser.uid,
        };
        // Store user data in Firestore
        await fireStore
            .collection("Sellers")
            .doc(currentUser.uid)
            .set(userData);
        debugPrint("User details saved");
      } else {
        debugPrint("No user is currently signed in");
      }
    } catch (e) {
      debugPrint("Error saving user info: $e");
    }
  }
}
