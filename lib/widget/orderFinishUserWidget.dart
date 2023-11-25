import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasispeechtotext/services/dbServices.dart';
import 'package:aplikasispeechtotext/services/messageServices.dart';
import 'package:sizer/sizer.dart';

class OrderFinishUserWidget extends StatefulWidget {
  const OrderFinishUserWidget({super.key});

  @override
  State<OrderFinishUserWidget> createState() => _OrderFinishUserWidgetState();
}

class _OrderFinishUserWidgetState extends State<OrderFinishUserWidget> {
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
                  Expanded(
                    flex: 1,
                    child: FutureBuilder(
                      future: DatabaseServices.readDataOnceShowWithTwoCond('pesananSementara', 'idPesanan', 'statusAntar', 'Sudah Antar', 'statusTempo', 'Lunas'),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                                height: 220.sp,
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
                                          // IconButton(
                                          //   onPressed: () async {
                                          //     await showDialog(
                                          //       context: context,
                                          //       builder: (context) {
                                          //         return AlertDialog(
                                          //           title: Text('Apakah Anda yakin hapus data dengan ID ${snapshot.data![index]}?'),
                                          //           actions: [
                                          //             TextButton(
                                          //               style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.green)),
                                          //               onPressed: () async {
                                          //                 try {
                                          //                   var dataPesanan = await DatabaseServices.readDataWithCondition('pesananSementara', 'idPesanan', snapshot.data![index]);
                                          //                   if (dataPesanan!['id'] != null) {
                                          //                     for (var i = 0; i < dataPesanan['id'].length; i++) {
                                          //                       var hasil = '';

                                          //                       var dataProduk = await DatabaseServices.readDataWithCondition('produk', 'namaProduk', dataPesanan['data'][i]['namaProduk']);
                                          //                       if (dataProduk!['data'] != null) {
                                          //                         if (dataPesanan['data'][i]['jenisHarga'] == 'DumpTruck') {
                                          //                           hasil = (double.parse(dataProduk['data'][0]['stokProduk']) + (double.parse(dataPesanan['data'][i]['jumlahProduk']) * 7.1)).toString();
                                          //                         } else {
                                          //                           hasil = (double.parse(dataProduk['data'][0]['stokProduk']) + double.parse(dataPesanan['data'][i]['jumlahProduk'])).toString();
                                          //                         }
                                          //                         Map<String, String> input = {};
                                          //                         input['stokProduk'] = hasil;
                                          //                         input['namaProduk'] = dataProduk['data'][0]['namaProduk'];
                                          //                         input['hargaEceran'] = dataProduk['data'][0]['hargaEceran'];
                                          //                         input['hargaDT'] = dataProduk['data'][0]['hargaDT'];

                                          //                         await DatabaseServices.updateDataWithDocId('produk', '${dataProduk['id'][0]}', input);
                                          //                         await DatabaseServices.deleteDataFirestore('pesananSementara', dataPesanan['id'][i]);
                                          //                       }

                                          //                       // snapshot.data!.length = snapshot.data!.length - 1;
                                          //                       setState(() {});
                                          //                       Navigator.of(context).pop();
                                          //                       await MessageService.showSnackBar(context, 'Berhasil dihapus');
                                          //                     }
                                          //                   }
                                          //                 } catch (e) {
                                          //                   print(e);
                                          //                 }
                                          //               },
                                          //               child: Text('Hapus'),
                                          //             ),
                                          //             TextButton(
                                          //               style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.red)),
                                          //               onPressed: () {
                                          //                 Navigator.of(context).pop();
                                          //               },
                                          //               child: Text('Batal'),
                                          //             ),
                                          //           ],
                                          //         );
                                          //       },
                                          //     );
                                          //   },
                                          //   icon: Icon(
                                          //     Icons.delete,
                                          //     color: Colors.red,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                    subtitle: Column(
                                      children: [
                                        FutureBuilder(
                                          future: DatabaseServices.readDataWithCondition('pesananSementara', 'idPesanan', snapshot.data![index]),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Nama Pelanggan : ${snapshot.data!['data'][0]['namaPelanggan']}',
                                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                      ),
                                                      Text(
                                                        '${snapshot.data!['data'][0]['jenisMetode'].toString().toUpperCase()}',
                                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 5.sp),
                                                    child: Text(
                                                      'Jenis Harga          : ${snapshot.data!['data'][0]['jenisHarga']}',
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
                                                                '${NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(snapshot.data!['data'][index]['subTotal']))}',
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
                                                  // SizedBox(
                                                  //   height: 40,
                                                  //   child: Center(
                                                  //     child: IconButton(
                                                  //       onPressed: () async {
                                                  //         await showDialog(
                                                  //           context: context,
                                                  //           builder: (context) {
                                                  //             return AlertDialog(
                                                  //               title: Text('Apakah pesanan ${snapshot.data!['data'][0]['namaPelanggan']} sudah selesai?'),
                                                  //               actions: [
                                                  //                 TextButton(
                                                  //                     style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.green)),
                                                  //                     onPressed: () async {
                                                  //                       try {
                                                  //                         var jumlahData = snapshot.data!['data'].length;
                                                  //                         for (var i = 0; i < jumlahData; i++) {
                                                  //                           Map<String, String> input = {};
                                                  //                           String docId = snapshot.data!['id'][i];
                                                  //                           input['idPesanan'] = snapshot.data!['data'][i]['idPesanan'];
                                                  //                           input['namaProduk'] = snapshot.data!['data'][i]['namaProduk'];
                                                  //                           input['jumlahProduk'] = snapshot.data!['data'][i]['jumlahProduk'];
                                                  //                           input['subTotal'] = snapshot.data!['data'][i]['subTotal'];
                                                  //                           input['jenisHarga'] = snapshot.data!['data'][i]['jenisHarga'];
                                                  //                           input['jenisMetode'] = snapshot.data!['data'][i]['jenisMetode'];
                                                  //                           input['jenisService'] = snapshot.data!['data'][i]['jenisService'];
                                                  //                           input['statusTempo'] = snapshot.data!['data'][i]['statusTempo'];
                                                  //                           input['statusAntar'] = snapshot.data!['data'][i]['statusAntar'];
                                                  //                           input['tglTransaksi'] = snapshot.data!['data'][i]['tglTransaksi'];
                                                  //                           input['namaKasir'] = snapshot.data!['data'][i]['namaKasir'];
                                                  //                           input['namaPelanggan'] = snapshot.data!['data'][i]['namaPelanggan'];
                                                  //                           input['total'] = snapshot.data!['data'][i]['total'];
                                                  //                           input['utang'] = snapshot.data!['data'][i]['utang'];
                                                  //                           input['ongkir'] = snapshot.data!['data'][i]['ongkir'];
                                                  //                           await DatabaseServices.createDataWithDocId('laporanJual', docId, input);

                                                  //                           if (i == 0) {
                                                  //                             String hasil = '0';
                                                  //                             var saldo = await DatabaseServices.readOneData('saldo', 'kas');
                                                  //                             if (saldo!['data'] != null) {
                                                  //                               hasil = (int.parse(saldo['data']['total']) + int.parse(snapshot.data!['data'][i]['total'])).toString();
                                                  //                               Map<String, String> inputSaldo = {};
                                                  //                               inputSaldo['total'] = hasil;
                                                  //                               if (snapshot.data!['data'][i]['jenisMetode'] == 'Tempo Cash' || snapshot.data!['data'][i]['jenisMetode'] == 'Cash') {
                                                  //                                 await DatabaseServices.updateDataWithDocId('saldo', 'kas', inputSaldo);
                                                  //                               }

                                                  //                               Map<String, String> input2 = {};
                                                  //                               input2['namaKasir'] = snapshot.data!['data'][i]['namaKasir'];
                                                  //                               input2['statusKas'] = 'pemasukan';
                                                  //                               input2['total'] = snapshot.data!['data'][i]['total'];
                                                  //                               input2['tglTransaksi'] = snapshot.data!['data'][i]['tglTransaksi'];
                                                  //                               input2['deskripsi'] = '${snapshot.data!['data'][i]['namaPelanggan']} (${snapshot.data!['data'][i]['idPesanan']})';

                                                  //                               await DatabaseServices.createDataWithDocId('laporanKas', docId, input2);
                                                  //                             }
                                                  //                           }
                                                  //                           await DatabaseServices.deleteDataFirestore('pesananSementara', docId);
                                                  //                           // snapshot.data!['data'].length = snapshot.data!['data'].length - 1;
                                                  //                           setState(() {});
                                                  //                         }
                                                  //                         await MessageService.showSnackBar(context, 'Berhasil diproses');
                                                  //                       } catch (e) {
                                                  //                         print(e);
                                                  //                       }

                                                  //                       Navigator.of(context).pop();
                                                  //                     },
                                                  //                     child: Text('Masuk Laporan')),
                                                  //                 TextButton(
                                                  //                     style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.red)),
                                                  //                     onPressed: () {
                                                  //                       Navigator.of(context).pop();
                                                  //                     },
                                                  //                     child: Text('Batal')),
                                                  //               ],
                                                  //             );
                                                  //           },
                                                  //         );
                                                  //       },
                                                  //       icon: Icon(
                                                  //         Icons.done_outline,
                                                  //         size: 13.sp,
                                                  //         color: Colors.green,
                                                  //       ),
                                                  //     ),
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
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
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
