import 'package:flutter/material.dart';
import 'package:jusconnect/core/components/default_appbar.dart';

class HomePage   extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: DefaultAppbar()
    );
  }
}