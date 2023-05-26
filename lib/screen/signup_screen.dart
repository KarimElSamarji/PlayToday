import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:email_validator/email_validator.dart';
import '../main.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onClickSignIn;

  const SignUpScreen({
    Key? key,
    required this.onClickSignIn,
  }) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    dateController.text = "";
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future signUp() async {
      final isValid = formKey.currentState!.validate();
      if (!isValid) return;

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()));

      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim())
            .then((value) async {
          User? user = FirebaseAuth.instance.currentUser;

          await FirebaseFirestore.instance
              .collection("users")
              .doc(user?.uid)
              .set({
            'uid': user?.uid,
            'username': usernameController.text.trim(),
            'birthday': dateController.text.trim(),
            'email': emailController.text.trim(),
            'password': passwordController.text.trim(),
          });
        });
      } on FirebaseAuthException catch (e) {
        print(e);
      }

      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 100),
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
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Material(
                          child: TextFormField(
                            controller: usernameController,
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.next,
                            validator: (username) =>
                                username == "" ? 'Enter a username' : null,
                            decoration: const InputDecoration(
                                labelText: 'Enter your username...'),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                              controller: dateController,
                              decoration: const InputDecoration(
                                  icon: Icon(Icons.calendar_today),
                                  labelText: "Enter Date"),
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101));
                                if (pickedDate != null) {
                                  print(pickedDate);
                                  String formattedDate =
                                      DateFormat('dd-MM-yyyy')
                                          .format(pickedDate);
                                  setState(() {
                                    dateController.text = formattedDate;
                                  });
                                } else {
                                  print("Date is not selected");
                                }
                              })),
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Material(
                          child: TextFormField(
                            controller: emailController,
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.next,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (email) =>
                                email != null && !EmailValidator.validate(email)
                                    ? 'Enter a valid email'
                                    : null,
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
                          child: TextFormField(
                            controller: passwordController,
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.done,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) =>
                                value != null && value.length < 6
                                    ? 'Use min. 6 charachter'
                                    : null,
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
                          icon: const Icon(Icons.create, size: 32),
                          label: const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 24),
                          ),
                          onPressed: signUp,
                        ),
                      ),
                      const SizedBox(height: 24),
                      RichText(
                          text: TextSpan(
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                              text: 'Already have an account? ',
                              children: [
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = widget.onClickSignIn,
                              text: 'Sign In',
                              style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue),
                            )
                          ]))
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
