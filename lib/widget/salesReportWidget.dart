import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasispeechtotext/services/dataServices.dart';
import 'package:aplikasispeechtotext/services/dbServices.dart';
import 'package:aplikasispeechtotext/services/otherServices.dart';
import 'package:sizer/sizer.dart';

class SalesReportWidget extends StatefulWidget {
  const SalesReportWidget({super.key});

  @override
  State<SalesReportWidget> createState() => _SalesReportWidgetState();
}

class _SalesReportWidgetState extends State<SalesReportWidget> {
  String cari = '';
  List<DocumentSnapshot> documents = [];
  DateTimeRange? rangeTanggal;
  TextEditingController tanggalLaporan = TextEditingController();

  static Future<List<String>?> readListDataGroup(data) async {
    List<String> listIdPesanan = [];
    Set<String> setIdPesanan = {};
    for (var element in data) {
      setIdPesanan.add(element['idPesanan']);
    }

    for (var element in setIdPesanan) {
      listIdPesanan.add(element);
    }

    return listIdPesanan;
  }

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
                              var data = await DatabaseServices.readDataWithTwoDateRange('laporanJual', 'tglTransaksi', DateFormat('yyyy-MM-dd').format(rangeTanggal!.end.add(Duration(days: 1))), 'tglTransaksi', DateFormat('yyyy-MM-dd').format(rangeTanggal!.start));
                              await DataServices.createPDF(data!, 'PENJUALAN', 'laporan', DateFormat('yyyy-MM-dd').format(rangeTanggal!.start), DateFormat('yyyy-MM-dd').format(rangeTanggal!.end.add(Duration(days: 1))));
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
                    child: FutureBuilder(
                        future:
                            rangeTanggal != null ? DatabaseServices.readDataOnceShowWithTwoCondDateTime('laporanJual', 'idPesanan', 'tglTransaksi', DateFormat('yyyy-MM-dd').format(rangeTanggal!.end.add(Duration(days: 1))), 'tglTransaksi', DateFormat('yyyy-MM-dd').format(rangeTanggal!.start)) : null,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            // print(snapshot.data);
                            return ListView.builder(
                              itemCount: snapshot.data?.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                                  height: 200.sp,
                                  child: Card(
                                    elevation: 5,
                                    child: ListTile(
                                      title: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5.sp),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'ID : ${snapshot.data![index]}',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                await showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text('Apakah Anda yakin hapus data dengan ID ${snapshot.data![index]}?'),
                                                      actions: [
                                                        TextButton(
                                                          style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.green)),
                                                          onPressed: () async {
                                                            try {
                                                              var dataJual = await DatabaseServices.readDataWithCondition('laporanJual', 'idPesanan', snapshot.data![index]);
                                                              if (dataJual!['data'] != null) {
                                                                String hasil = '';
                                                                var dataSaldo = await DatabaseServices.readOneData('saldo', 'kas');
                                                                if (dataSaldo!['data'] != null) {
                                                                  hasil = (int.parse(dataSaldo['data']['total']) - int.parse(dataJual['data'][0]['total'])).toString();
                                                                }
                                                                Map<String, String> input = {};
                                                                input['total'] = hasil;
                                                                if (dataJual['data'][0]['jenisMetode'] == 'Tempo Cash' || dataJual['data'][0]['jenisMetode'] == 'Cash') {
                                                                  await DatabaseServices.updateDataWithDocId('saldo', 'kas', input);
                                                                }

                                                                var dataKas = await DatabaseServices.readOneData('laporanKas', dataJual['id'][0]);
                                                                if (dataKas!['data'] != null) {
                                                                  await DatabaseServices.deleteDataFirestore('laporanKas', dataKas['id']);
                                                                }

                                                                for (var i = 0; i < dataJual['data'].length; i++) {
                                                                  var dataProduk = await DatabaseServices.readDataWithCondition('produk', 'namaProduk', dataJual['data'][i]['namaProduk']);
                                                                  if (dataProduk!['data'] != null) {
                                                                    if (dataJual['data'][i]['jenisHarga'] == 'DumpTruck') {
                                                                      hasil = (double.parse(dataProduk['data'][0]['stokProduk']) + (double.parse(dataJual['data'][i]['jumlahProduk']) * 7.1)).toString();
                                                                    } else {
                                                                      hasil = (double.parse(dataProduk['data'][0]['stokProduk']) + double.parse(dataJual['data'][i]['jumlahProduk'])).toString();
                                                                    }
                                                                    Map<String, String> input2 = {};
                                                                    input2['stokProduk'] = hasil;
                                                                    input2['namaProduk'] = dataProduk['data'][0]['namaProduk'];
                                                                    input2['hargaEceran'] = dataProduk['data'][0]['hargaEceran'];
                                                                    input2['hargaDT'] = dataProduk['data'][0]['hargaDT'];

                                                                    await DatabaseServices.updateDataWithDocId('produk', '${dataProduk['id'][0]}', input2);
                                                                    await DatabaseServices.deleteDataFirestore('laporanJual', dataJual['id'][i]);
                                                                  }

                                                                  snapshot.data!.length = snapshot.data!.length - 1;
                                                                }
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
                                        children: [
                                          FutureBuilder(
                                            future: DatabaseServices.readDataWithCondition('laporanJual', 'idPesanan', snapshot.data![index]),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                // print(snapshot.data?['id'].length);
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Nama Pelanggan : ${snapshot.data?['data'][0]['namaPelanggan']}',
                                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                        ),
                                                        Text(
                                                          '${snapshot.data?['data'][0]['jenisMetode'].toString().toUpperCase()}',
                                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(vertical: 5.sp),
                                                      child: Text(
                                                        'Jenis Harga          : ${snapshot.data?['data'][0]['jenisHarga']}',
                                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Expanded(
                                                            flex: 2,
                                                            child: Text(
                                                              'Nama',
                                                              style: TextStyle(color: Colors.black),
                                                            )),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            'Jumlah',
                                                            style: TextStyle(color: Colors.black),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                            'SubTotal',
                                                            style: TextStyle(color: Colors.black),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 65,
                                                      child: ListView.builder(
                                                        itemCount: snapshot.data?['data'].length ?? 0,
                                                        itemBuilder: (context, index) {
                                                          return Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    '${snapshot.data!['data'][index]['namaProduk']}',
                                                                    style: TextStyle(color: Colors.black),
                                                                  )),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  '@${snapshot.data!['data'][index]['jumlahProduk']}',
                                                                  style: TextStyle(color: Colors.black),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 3,
                                                                child: Text(
                                                                  '${NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(snapshot.data!['data'][index]['subTotal']))} ',
                                                                  style: TextStyle(color: Colors.black),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: 30,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 1,
                                                              child: Text(
                                                                'TOTAL                   : ${NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(snapshot.data!['data'][0]['total']))}',
                                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Text(
                                                                'SISA TEMPO        : ${NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(snapshot.data!['data'][0]['utang']))}',
                                                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                          ],
                                                        )),
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
                                                );
                                              } else {
                                                return SizedBox();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return SizedBox();
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
