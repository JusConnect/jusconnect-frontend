import 'package:flutter/material.dart';
import 'package:jusconnect/shared/themes/light_theme.dart';

class LoginButton extends StatelessWidget {
  final Function? onPressed;

  const LoginButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Entrar',
          style: TextStyle(fontWeight: .w900, color: AppColors.onPrimaryColor),
        ),
      ),
    );
  }
}
