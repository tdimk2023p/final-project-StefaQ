import 'package:flutter/material.dart';

class MessageService {
  static Future<void> showSnackBar(BuildContext context, String pesan) async {
    await ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(pesan),
      duration: Duration(seconds: 1),
    ));
  }
}
