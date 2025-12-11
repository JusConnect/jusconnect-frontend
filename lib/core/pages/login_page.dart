import 'package:flutter/material.dart';
import 'package:jusconnect/core/components/default_appbar.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: DefaultAppbar(showActions: false,),
      body: Center(child: Text('Login Page')),
    );
  }
}
