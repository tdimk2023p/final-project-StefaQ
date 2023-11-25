import 'package:aplikasispeechtotext/services/dataServices.dart';
import 'package:aplikasispeechtotext/services/dbservices.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ValidationServices {
  static Future<List<String>> loginValidation(String username, String password) async {
    List<String> hasil = [];
    if (username == '') {
      return hasil;
    }
    if (password == '') {
      return hasil;
    }

    await DatabaseServices.readOneData('pengguna', username).then((value) {
      if (value?['data'] != null) {
        hasil.add(value?['id']);
        hasil.add(value?['data']['nama']);
        hasil.add(value?['data']['password']);
        hasil.add(value?['data']['status']);
      }
    });
    if (password != hasil[2]) {
      hasil = [];
    }
    return hasil;
  }

  static Future<List<String>?> prefValidation(String data) async {
    List<String>? user = await DataServices.readListPreferences(data);
    return user;
  }
}
