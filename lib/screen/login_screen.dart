import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onClickSignUp;

  const LoginScreen({
    Key? key,
    required this.onClickSignUp,
  }) : super(key: key);

  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future signIn() async {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()));

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } on FirebaseAuthException catch (e) {
        print(e);
      }

      //Navigator.of(context) not working!
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 180),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Play',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: 'Today',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      child: TextField(
                        controller: emailController,
                        cursorColor: Colors.white,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                            labelText: 'Enter your email...'),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      child: TextField(
                        controller: passwordController,
                        cursorColor: Colors.white,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                            labelText: 'Enter your password...'),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      icon: const Icon(Icons.lock_open, size: 32),
                      label: const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 24),
                      ),
                      onPressed: signIn,
                    ),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                      text: TextSpan(
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                          text: 'No account? ',
                          children: [
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.onClickSignUp,
                          text: 'Sign Up',
                          style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue),
                        )
                      ]))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
