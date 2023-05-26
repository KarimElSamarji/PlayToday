import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:playtoday/screen/login_screen.dart';
import 'package:playtoday/screen/signup_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  void toggle() => setState(() => {isLogin = !isLogin});

  @override
  Widget build(BuildContext context) => isLogin
      ? LoginScreen(onClickSignUp: toggle)
      : SignUpScreen(onClickSignIn: toggle);
}
