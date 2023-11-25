import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasispeechtotext/services/dataServices.dart';
import 'package:aplikasispeechtotext/services/dbServices.dart';
import 'package:aplikasispeechtotext/services/otherServices.dart';
import 'package:sizer/sizer.dart';

class KasReportWidget extends StatefulWidget {
  const KasReportWidget({super.key});

  @override
  State<KasReportWidget> createState() => _KasReportWidgetState();
}

class _KasReportWidgetState extends State<KasReportWidget> {
  String cari = '';
  List<DocumentSnapshot> documents = [];
  DateTimeRange? rangeTanggal;
  TextEditingController tanggalLaporan = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.sp),
                            child: GestureDetector(
                              onTap: () async {
                                rangeTanggal = await OtherServices.showDateTimeRange(context);
                                if (rangeTanggal == null) {
                                  tanggalLaporan.text = DateFormat('dd/MM/yyyy').format(DateTime.now()).split(' ')[0] + '-' + DateFormat('dd/MM/yyyy').format(DateTime.now()).split(' ')[0];
                                } else {
                                  tanggalLaporan.text = DateFormat('dd/MM/yyyy').format(rangeTanggal!.start).split(' ')[0] + '-' + DateFormat('dd/MM/yyyy').format(rangeTanggal!.end).split(' ')[0];
                                }
                                setState(() {});
                              },
                              child: TextFormField(
                                enabled: false,
                                controller: tanggalLaporan,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelText: 'Pilih Tanggal',
                                  labelStyle: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: Colors.black,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.orange,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: EdgeInsetsDirectional.fromSTEB(4.sp, 4.sp, 4.sp, 4.sp),
                                ),
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: Color(0xFF101213),
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.print_rounded),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                            ),
                            onPressed: () async {
                              var data = await DatabaseServices.readDataWithTwoDateRange('laporanKas', 'tglTransaksi', DateFormat('yyyy-MM-dd').format(rangeTanggal!.end.add(Duration(days: 1))), 'tglTransaksi', DateFormat('yyyy-MM-dd').format(rangeTanggal!.start));
                              await DataServices.createPDF(data!, 'KAS', 'laporan', DateFormat('yyyy-MM-dd').format(rangeTanggal!.start), DateFormat('yyyy-MM-dd').format(rangeTanggal!.end.add(Duration(days: 1))));
                            },
                            label: Text(
                              '',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: StreamBuilder(
                        stream: rangeTanggal == null
                            ? FirebaseFirestore.instance.collection('laporanKas').where('tglTransaksi', isEqualTo: DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()).orderBy(FieldPath.documentId, descending: true).snapshots()
                            : rangeTanggal != null && (DateFormat('yyyy-MM-dd').format(rangeTanggal!.end) == DateFormat('yyyy-MM-dd').format(rangeTanggal!.start))
                                ? FirebaseFirestore.instance.collection('laporanKas').where('tglTransaksi', isEqualTo: DateFormat('yyyy-MM-dd').format(rangeTanggal!.start)).orderBy(FieldPath.documentId, descending: true).snapshots()
                                : FirebaseFirestore.instance
                                    .collection('laporanKas')
                                    .where('tglTransaksi', isLessThanOrEqualTo: DateFormat('yyyy-MM-dd').format(rangeTanggal!.end.add(Duration(days: 1))))
                                    .where('tglTransaksi', isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(rangeTanggal!.start))
                                    .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              itemCount: snapshot.data?.docs.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                                  height: 140.sp,
                                  child: Card(
                                    elevation: 5,
                                    child: ListTile(
                                      title: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5.sp),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'ID : ${snapshot.data!.docs[index].reference.id}',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                await showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text('Apakah Anda yakin hapus data dengan ID ${snapshot.data!.docs[index].reference.id}?'),
                                                      actions: [
                                                        TextButton(
                                                          style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.green)),
                                                          onPressed: () async {
                                                            try {
                                                              String idPesanan = '';
                                                              String jenisMetode = '';
                                                              bool masukan = true;
                                                              if (snapshot.data!.docs[index]['deskripsi'].toString().contains('(JCO')) {
                                                                masukan = false;
                                                                idPesanan = snapshot.data!.docs[index]['deskripsi'].toString().substring(snapshot.data!.docs[index]['deskripsi'].toString().length - 24, max(0, snapshot.data!.docs[index]['deskripsi'].toString().length - 1));
                                                                var dataJual = await DatabaseServices.readDataWithCondition('laporanJual', 'idPesanan', idPesanan);
                                                                if (dataJual!['data'] != null) {
                                                                  jenisMetode = dataJual['data'][0]['jenisMetode'];
                                                                  for (var i = 0; i < dataJual['data'].length; i++) {
                                                                    await DatabaseServices.deleteDataFirestore('laporanJual', dataJual['id'][i]);
                                                                  }
                                                                }
                                                              } else if (snapshot.data!.docs[index]['statusKas'].toString() == 'pengeluaran') {
                                                                await DatabaseServices.deleteDataFirestore('laporanBeban', snapshot.data!.docs[index].reference.id);
                                                              }

                                                              String hasil = '';
                                                              var dataKas = await DatabaseServices.readOneData('saldo', 'kas');
                                                              if (dataKas!['data'] != null) {
                                                                if (snapshot.data!.docs[index]['statusKas'] == 'pemasukan') {
                                                                  hasil = (int.parse(dataKas['data']['total']) - int.parse(snapshot.data!.docs[index]['total'])).toString();
                                                                } else {
                                                                  hasil = (int.parse(dataKas['data']['total']) + int.parse(snapshot.data!.docs[index]['total'])).toString();
                                                                }
                                                                Map<String, String> input = {};
                                                                input['total'] = hasil;
                                                                if (snapshot.data!.docs[index]['statusKas'] == 'pemasukan') {
                                                                  if (masukan == true) {
                                                                    await DatabaseServices.updateDataWithDocId('saldo', 'kas', input);
                                                                  } else if (masukan == false) {
                                                                    if (jenisMetode == 'Tempo Cash' || jenisMetode == 'Cash') {
                                                                      await DatabaseServices.updateDataWithDocId('saldo', 'kas', input);
                                                                    }
                                                                  }
                                                                } else if (snapshot.data!.docs[index]['statusKas'] == 'pengeluaran') {
                                                                  await DatabaseServices.updateDataWithDocId('saldo', 'kas', input);
                                                                }
                                                                await DatabaseServices.deleteDataFirestore('laporanKas', snapshot.data!.docs[index].reference.id);
                                                                setState(() {});

                                                                Navigator.of(context).pop();
                                                              }
                                                            } catch (e) {
                                                              print(e);
                                                            }
                                                          },
                                                          child: Text('Hapus'),
                                                        ),
                                                        TextButton(
                                                          style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.red)),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: Text('Batal'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 2.sp),
                                            child: Text(
                                              '${snapshot.data!.docs[index]['tglTransaksi']}',
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Nama Kasir : ${snapshot.data!.docs[index]['namaKasir']}',
                                                style: TextStyle(color: Colors.black),
                                              ),
                                              Text(
                                                '${snapshot.data!.docs[index]['statusKas'].toString().toUpperCase()}',
                                                style: TextStyle(color: snapshot.data!.docs[index]['statusKas'] == 'pemasukan' ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5.sp,
                                          ),
                                          Text(
                                            'Total         : ${NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(snapshot.data!.docs[index]['total'].toString()))} ',
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Deskripsi : ${snapshot.data!.docs[index]['deskripsi'].toString().toUpperCase()}',
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          // SizedBox(
                                          //   height: 40,
                                          //   child: Row(
                                          //     mainAxisAlignment: MainAxisAlignment.end,
                                          //     children: [
                                          //       Padding(
                                          //         padding: EdgeInsets.symmetric(horizontal: 2.sp),
                                          //         child: ElevatedButton.icon(
                                          //             style: ElevatedButton.styleFrom(
                                          //               backgroundColor: Colors.teal,
                                          //             ),
                                          //             onPressed: () {},
                                          //             icon: Icon(Icons.print),
                                          //             label: Text('Struk')),
                                          //       ),
                                          //       Padding(
                                          //         padding: EdgeInsets.symmetric(horizontal: 2.sp),
                                          //         child: ElevatedButton.icon(
                                          //             style: ElevatedButton.styleFrom(
                                          //               backgroundColor: Colors.grey,
                                          //             ),
                                          //             onPressed: () {},
                                          //             icon: Icon(Icons.print),
                                          //             label: Text('Nota')),
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
