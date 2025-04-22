import 'package:eatezy_vendor/utils/app_color.dart';
import 'package:flutter/material.dart';

class AppAlerts {
  static void successAlert(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: AppColor.primary,
    ));
  }

  static void wrongAlert(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    ));
  }
}
