import 'package:flutter/material.dart';
import 'package:aplikasispeechtotext/screen/adminHomeScreen.dart';
import 'package:aplikasispeechtotext/services/dataServices.dart';
import 'package:aplikasispeechtotext/services/messageServices.dart';
import 'package:aplikasispeechtotext/services/navigationServices.dart';
import 'package:aplikasispeechtotext/services/validationServices.dart';
import 'package:sizer/sizer.dart';

import 'kasirHomeScreen.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  void setErrorBuilder() {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return Scaffold(body: SizedBox());
    };
  }

  @override
  Widget build(BuildContext context) {
    setErrorBuilder();
    return Scaffold(
      body: FutureBuilder(
        future: ValidationServices.prefValidation('dataUser'),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data?[3] == 'admin') {
              return AdminHomeScreen();
            } else {
              return KasirHomeScreen();
            }
          } else {
            return Container(
              color: Colors.cyan,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  SizedBox(
                      height: 170.sp,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/logo.png',
                            width: MediaQuery.of(context).size.width * 0.35,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Pangkalan Batu\nDesa Kapur',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      )),
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 30.sp,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                            child: Container(
                              width: double.infinity,
                              child: TextFormField(
                                controller: username,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  labelStyle: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                keyboardType: TextInputType.text,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                            child: Container(
                              width: double.infinity,
                              child: TextFormField(
                                controller: password,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                keyboardType: TextInputType.text,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                            child: Container(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ButtonStyle(
                                  shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  backgroundColor: MaterialStatePropertyAll(Colors.cyan),
                                ),
                                onPressed: () async {
                                  List<String>? hasil = await ValidationServices.loginValidation(username.text, password.text);

                                  if (hasil.isEmpty) {
                                    await MessageService.showSnackBar(context, 'Username dan password salah');
                                  } else {
                                    await DataServices.createListPreferences('dataUser', hasil);

                                    if (hasil[3] == 'admin') {
                                      await NavigationServices.navigationPushAndRemoveUntil(context, AdminHomeScreen());
                                    } else if (hasil[3] == 'kasir') {
                                      await NavigationServices.navigationPushAndRemoveUntil(context, KasirHomeScreen());
                                    }
                                  }
                                },
                                icon: Icon(Icons.login),
                                label: Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
