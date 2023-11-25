import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasispeechtotext/services/dataServices.dart';
import 'package:aplikasispeechtotext/services/dbServices.dart';
import 'package:aplikasispeechtotext/services/messageServices.dart';
import 'package:aplikasispeechtotext/services/otherServices.dart';
import 'package:sizer/sizer.dart';

class LossReportWidget extends StatefulWidget {
  const LossReportWidget({super.key});

  @override
  State<LossReportWidget> createState() => _LossReportWidgetState();
}

class _LossReportWidgetState extends State<LossReportWidget> {
  String cari = '';
  List<DocumentSnapshot> documents = [];
  DateTimeRange? rangeTanggal;
  TextEditingController tanggalLaporan = TextEditingController();

  TextEditingController total = TextEditingController();
  TextEditingController desc = TextEditingController();

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
                              var data = await DatabaseServices.readDataWithTwoDateRange('laporanBeban', 'tglTransaksi', DateFormat('yyyy-MM-dd').format(rangeTanggal!.end.add(Duration(days: 1))), 'tglTransaksi', DateFormat('yyyy-MM-dd').format(rangeTanggal!.start));
                              await DataServices.createPDF(data!, 'BEBAN', 'laporan', DateFormat('yyyy-MM-dd').format(rangeTanggal!.start), DateFormat('yyyy-MM-dd').format(rangeTanggal!.end.add(Duration(days: 1))));
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
                            ? FirebaseFirestore.instance.collection('laporanBeban').where('tglTransaksi', isEqualTo: DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()).orderBy(FieldPath.documentId, descending: true).snapshots()
                            : rangeTanggal != null && (DateFormat('yyyy-MM-dd').format(rangeTanggal!.end) == DateFormat('yyyy-MM-dd').format(rangeTanggal!.start))
                                ? FirebaseFirestore.instance.collection('laporanBeban').where('tglTransaksi', isEqualTo: DateFormat('yyyy-MM-dd').format(rangeTanggal!.start)).orderBy(FieldPath.documentId, descending: true).snapshots()
                                : FirebaseFirestore.instance
                                    .collection('laporanBeban')
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
                                                              String hasil = '';
                                                              var dataKas = await DatabaseServices.readOneData('saldo', 'kas');
                                                              if (dataKas!['data'] != null) {
                                                                hasil = (int.parse(dataKas['data']['total']) + int.parse(snapshot.data!.docs[index]['total'])).toString();

                                                                Map<String, String> input = {};
                                                                input['total'] = hasil;

                                                                await DatabaseServices.updateDataWithDocId('saldo', 'kas', input);
                                                                await DatabaseServices.deleteDataFirestore('laporanKas', snapshot.data!.docs[index].reference.id);
                                                                await DatabaseServices.deleteDataFirestore('laporanBeban', snapshot.data!.docs[index].reference.id);
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        child: Icon(Icons.add),
        onPressed: () async {
          total.text = '';
          desc.text = '';

          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Tambah Beban'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 2.sp,
                      ),
                      child: Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: total,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Total',
                            labelStyle: TextStyle(
                              color: Colors.cyan,
                              fontSize: 10.sp,
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
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 2.sp,
                      ),
                      child: Container(
                        width: double.infinity,
                        child: TextFormField(
                          maxLines: 3,
                          controller: desc,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Deskripsi',
                            labelStyle: TextStyle(
                              color: Colors.cyan,
                              fontSize: 10.sp,
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
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () async {
                        if (total.text != '') {
                          try {
                            String hasil = '0';
                            var saldo = await DatabaseServices.readOneData('saldo', 'kas');
                            if (saldo!['data'] != null) {
                              List<String>? dataUser = await DataServices.readListPreferences('dataUser');
                              if (dataUser != null) {
                                Map<String, String> input = {};
                                input['namaKasir'] = dataUser[1];

                                DateTime tglHariIni = DateTime.now();
                                String docId = DataServices.charFromDateTime(tglHariIni);
                                input['statusKas'] = 'pengeluaran';
                                input['total'] = total.text;
                                input['tglTransaksi'] = tglHariIni.toString();
                                input['deskripsi'] = desc.text;

                                await DatabaseServices.createDataWithDocId('laporanKas', docId, input);

                                Map<String, String> input2 = {};
                                input2['namaKasir'] = dataUser[1];
                                input2['total'] = total.text;
                                input2['tglTransaksi'] = tglHariIni.toString();
                                input2['deskripsi'] = desc.text;
                                await DatabaseServices.createDataWithDocId('laporanBeban', docId, input2);

                                Map<String, String> input3 = {};
                                hasil = (int.parse(saldo['data']['total']) - int.parse(total.text)).toString();

                                if (int.parse(hasil) < 0) {
                                  Navigator.of(context).pop();
                                  await MessageService.showSnackBar(context, 'Saldo Anda kurang');
                                } else {
                                  input3['total'] = hasil;
                                  await DatabaseServices.updateDataWithDocId('saldo', 'kas', input3);
                                  Navigator.of(context).pop();
                                  await MessageService.showSnackBar(context, 'Berhasil diproses');
                                }

                                setState(() {});
                              }
                            }
                          } catch (e) {
                            print(e);
                          }
                        }
                      },
                      child: Text(
                        'Tambah',
                        style: TextStyle(color: Colors.orange),
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Batal',
                        style: TextStyle(color: Colors.red),
                      )),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
