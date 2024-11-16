import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_stripe/stripe_connect_screen.dart';

class AuthRepository {
  var auth = FirebaseAuth.instance;
  var fireStore = FirebaseFirestore.instance;
  Future<void> signupUser(
      String email, String password, String name, BuildContext context) async {
    try {
      auth.createUserWithEmailAndPassword(email: email, password: password);
      debugPrint("user created and save details");
      saveSellerInfo(name);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => StripeConnectScreen(),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> saveSellerInfo(
    String name,
  ) async {
    try {
      Map<String, dynamic> userData = {
        "name": name,
        "Gmail": auth.currentUser!.email,
        "SellerId": auth.currentUser!.uid,
      };
      fireStore.collection("Sellers").doc(auth.currentUser!.uid).set(userData);
      // auth.createUserWithEmailAndPassword(email: email, password: password);
      debugPrint("user created");
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
