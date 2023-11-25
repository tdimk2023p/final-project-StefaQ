import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:aplikasispeechtotext/screen/adminHomeScreen.dart';
import 'package:aplikasispeechtotext/screen/loginScreen.dart';
import 'package:aplikasispeechtotext/services/dataServices.dart';
import 'package:aplikasispeechtotext/services/dbServices.dart';
import 'package:aplikasispeechtotext/services/navigationServices.dart';
import 'package:aplikasispeechtotext/widget/orderUserWidget.dart';
import 'package:aplikasispeechtotext/widget/statusOrderUserWidget.dart';
import 'package:sizer/sizer.dart';

BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
List<BluetoothDevice> devices = [];
BluetoothDevice? device;
bool connected = false;

int kas = 0;

class KasirHomeScreen extends StatefulWidget {
  const KasirHomeScreen({super.key});

  @override
  State<KasirHomeScreen> createState() => _KasirHomeScreenState();
}

class _KasirHomeScreenState extends State<KasirHomeScreen> {
  TextEditingController total = TextEditingController();
  TextEditingController desc = TextEditingController();
  int selectedIndex = 0;
  List<Widget> halaman = [
    OrderUserWidget(),
    StatusOrderUserWidget(),
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
        title: Row(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('saldo').doc('kas').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    'Jumlah Kas : ${NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(snapshot.data!['total']))}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
            // IconButton(
            //   onPressed: () async {
            //     total.text = '';
            //     desc.text = '';

            //     await showDialog(
            //       context: context,
            //       builder: (context) {
            //         return AlertDialog(
            //           title: Text('Atur Saldo'),
            //           content: Column(
            //             mainAxisSize: MainAxisSize.min,
            //             children: [
            //               Padding(
            //                 padding: EdgeInsets.symmetric(
            //                   vertical: 2.sp,
            //                 ),
            //                 child: Container(
            //                   width: double.infinity,
            //                   child: TextFormField(
            //                     controller: total,
            //                     obscureText: false,
            //                     decoration: InputDecoration(
            //                       labelText: 'Total',
            //                       labelStyle: TextStyle(
            //                         color: Colors.cyan,
            //                         fontSize: 10.sp,
            //                         fontWeight: FontWeight.bold,
            //                       ),
            //                       enabledBorder: OutlineInputBorder(
            //                         borderSide: BorderSide(
            //                           color: Colors.grey,
            //                           width: 2,
            //                         ),
            //                         borderRadius: BorderRadius.circular(12),
            //                       ),
            //                       focusedBorder: OutlineInputBorder(
            //                         borderSide: BorderSide(
            //                           color: Colors.cyan,
            //                           width: 2,
            //                         ),
            //                         borderRadius: BorderRadius.circular(12),
            //                       ),
            //                     ),
            //                     style: TextStyle(
            //                       fontSize: 10.sp,
            //                       fontWeight: FontWeight.bold,
            //                     ),
            //                     keyboardType: TextInputType.number,
            //                   ),
            //                 ),
            //               ),
            //               Padding(
            //                 padding: EdgeInsets.symmetric(
            //                   vertical: 2.sp,
            //                 ),
            //                 child: Container(
            //                   width: double.infinity,
            //                   child: TextFormField(
            //                     maxLines: 3,
            //                     controller: desc,
            //                     obscureText: false,
            //                     decoration: InputDecoration(
            //                       labelText: 'Deskripsi',
            //                       labelStyle: TextStyle(
            //                         color: Colors.cyan,
            //                         fontSize: 10.sp,
            //                         fontWeight: FontWeight.bold,
            //                       ),
            //                       enabledBorder: OutlineInputBorder(
            //                         borderSide: BorderSide(
            //                           color: Colors.grey,
            //                           width: 2,
            //                         ),
            //                         borderRadius: BorderRadius.circular(12),
            //                       ),
            //                       focusedBorder: OutlineInputBorder(
            //                         borderSide: BorderSide(
            //                           color: Colors.cyan,
            //                           width: 2,
            //                         ),
            //                         borderRadius: BorderRadius.circular(12),
            //                       ),
            //                     ),
            //                     style: TextStyle(
            //                       fontSize: 10.sp,
            //                       fontWeight: FontWeight.bold,
            //                     ),
            //                     keyboardType: TextInputType.text,
            //                   ),
            //                 ),
            //               ),
            //             ],
            //           ),
            //           actions: [
            //             TextButton(
            //                 onPressed: () async {
            //                   if (total.text != '') {
            //                     try {
            //                       String hasil = '0';
            //                       var saldo = await DatabaseServices.readOneData('saldo', 'kas');
            //                       if (saldo!['data'] != null) {
            //                         hasil = (int.parse(saldo['data']['total']) + int.parse(total.text)).toString();
            //                         Map<String, String> input = {};
            //                         input['total'] = hasil;

            //                         await DatabaseServices.updateDataWithDocId('saldo', 'kas', input);

            //                         List<String>? dataUser = await DataServices.readListPreferences('dataUser');
            //                         if (dataUser != null) {
            //                           input['namaKasir'] = dataUser[1];
            //                         }

            //                         DateTime tglHariIni = DateTime.now();
            //                         input['statusKas'] = 'pemasukan';
            //                         input['total'] = total.text;
            //                         input['tglTransaksi'] = tglHariIni.toString();
            //                         input['deskripsi'] = desc.text;

            //                         String docId = DataServices.charFromDateTime(tglHariIni);

            //                         await DatabaseServices.createDataWithDocId('laporanKas', docId, input);
            //                       }
            //                     } catch (e) {
            //                       print(e);
            //                     }

            //                     Navigator.of(context).pop();
            //                   }
            //                 },
            //                 child: Text(
            //                   'Masuk',
            //                   style: TextStyle(color: Colors.green),
            //                 )),
            //             // TextButton(
            //             //     onPressed: () async {
            //             //       if (total.text != '') {
            //             //         try {
            //             //           String hasil = '0';
            //             //           var saldo = await DatabaseServices.readOneData('saldo', 'kas');
            //             //           if (saldo!['data'] != null) {
            //             //             hasil = (int.parse(saldo['data']['total']) - int.parse(total.text)).toString();
            //             //             Map<String, String> input = {};
            //             //             input['total'] = hasil;

            //             //             await DatabaseServices.updateDataWithDocId('saldo', 'kas', input);

            //             //             List<String>? dataUser = await DataServices.readListPreferences('dataUser');
            //             //             if (dataUser != null) {
            //             //               input['namaKasir'] = dataUser[1];
            //             //             }

            //             //             DateTime tglHariIni = DateTime.now();
            //             //             input['statusKas'] = 'pengeluaran';
            //             //             input['total'] = total.text;
            //             //             input['tglTransaksi'] = tglHariIni.toString();
            //             //             input['deskripsi'] = desc.text;

            //             //             String docId = DataServices.charFromDateTime(tglHariIni);

            //             //             await DatabaseServices.createDataWithDocId('laporanKas', docId, input);
            //             //           }
            //             //         } catch (e) {
            //             //           print(e);
            //             //         }

            //             //         Navigator.of(context).pop();
            //             //       }
            //             //     },
            //             //     child: Text(
            //             //       'Keluar',
            //             //       style: TextStyle(color: Colors.orange),
            //             //     )),
            //             TextButton(
            //                 onPressed: () {
            //                   Navigator.of(context).pop();
            //                 },
            //                 child: Text(
            //                   'Batal',
            //                   style: TextStyle(color: Colors.red),
            //                 )),
            //           ],
            //         );
            //       },
            //     );
            //   },
            //   icon: Icon(
            //     Icons.currency_exchange,
            //     color: Colors.white,
            //   ),
            // ),
          ],
        ),
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
        ],
      ),
    );
  }
}
