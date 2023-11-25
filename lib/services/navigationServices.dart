import 'package:flutter/material.dart';

class NavigationServices {
  static Future<void> navigationPushAndRemoveUntil(BuildContext context, var halaman) async {
    await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => halaman,
        ),
        (route) => false);
  }
}
