import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:jusconnect/shared/themes/light_theme.dart';

class Notifications {
  
  static void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    floatingSnackBar(
      context: context,
      message: message,
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 2),
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.accentColor);
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.errorColor);
  }

  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.successColor);
  }
}
