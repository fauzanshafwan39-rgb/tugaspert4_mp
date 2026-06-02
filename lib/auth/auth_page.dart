import 'package:flutter/material.dart';
import 'package:tugaspert4_mp/auth/login_page.dart';
import 'package:tugaspert4_mp/auth/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    if (isLogin) {
      return LoginPage(onClickedSignUp: toggle);
    } else {
      return RegisterPage(onClickedSignIn: toggle);
    }
  }

  void toggle() => setState(() => isLogin = !isLogin);
}