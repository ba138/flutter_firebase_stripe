import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var nameController = TextEditingController();
    var emailController = TextEditingController();
    var passwordController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 40,
              ),
              const Text("userName"),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text("Email"),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text("Password"),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Center(
                  child:
                      ElevatedButton(onPressed: () {}, child: Text("SignUp")))
            ],
          ),
        ),
      ),
    );
  }
}
