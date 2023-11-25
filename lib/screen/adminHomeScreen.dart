import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:aplikasispeechtotext/screen/loginScreen.dart';
import 'package:aplikasispeechtotext/services/dataServices.dart';
import 'package:aplikasispeechtotext/services/dbServices.dart';
import 'package:aplikasispeechtotext/services/navigationServices.dart';
import 'package:aplikasispeechtotext/widget/orderDeliveryWidget.dart';
import 'package:aplikasispeechtotext/widget/orderFinishWidget.dart';
import 'package:aplikasispeechtotext/widget/orderTempoWidget.dart';
import 'package:aplikasispeechtotext/widget/orderWidget.dart';
import 'package:aplikasispeechtotext/widget/productWidget.dart';
import 'package:aplikasispeechtotext/widget/reportWidget.dart';
import 'package:aplikasispeechtotext/widget/statusOrderWidget.dart';
import 'package:aplikasispeechtotext/widget/salesReportWidget.dart';
import 'package:aplikasispeechtotext/widget/userWidget.dart';
import 'package:sizer/sizer.dart';

BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
List<BluetoothDevice> devices = [];
BluetoothDevice? device;
bool connected = false;

int kas = 0;

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  TextEditingController total = TextEditingController();
  TextEditingController desc = TextEditingController();
  int selectedIndex = 0;
  List<Widget> halaman = [
    OrderWidget(),
    StatusOrderWidget(),
    ProductWidget(),
  ];

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    // List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      // TODO - Error
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            connected = true;
            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            connected = false;
            print("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            connected = false;
            print("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            connected = false;
            print("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            connected = false;
            print("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            connected = false;
            print("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            connected = false;
            print("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            connected = false;
            print("bluetooth device state: error");
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      devices = devices;
    });

    if (isConnected!) {
      setState(() {
        connected = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    initPlatformState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
              onPressed: () async {
                await DataServices.deletePreferences('dataUser');
                await NavigationServices.navigationPushAndRemoveUntil(context, loginScreen());
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: Container(
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
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                )),
            Expanded(
              flex: 3,
              child: halaman[selectedIndex],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.assignment_outlined,
              ),
              label: 'Kasir'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.library_books_outlined,
              ),
              label: 'Status Order'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.dataset_outlined,
              ),
              label: 'Produk'),
        ],
      ),
    );
  }
}
