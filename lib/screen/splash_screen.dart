// ignore_for_file: prefer_const_constructors
import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SplashScreen> {
  var _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(Duration(seconds: 3), () => {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Color.fromARGB(255, 0, 0, 0),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: const [
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
    );
  }
}
