import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasispeechtotext/services/dataServices.dart';
import 'package:aplikasispeechtotext/services/dbServices.dart';
import 'package:aplikasispeechtotext/services/messageServices.dart';
import 'package:aplikasispeechtotext/services/otherServices.dart';
import 'package:sizer/sizer.dart';

class OrderTempoWidget extends StatefulWidget {
  const OrderTempoWidget({super.key});

  @override
  State<OrderTempoWidget> createState() => _OrderTempoWidgetState();
}

class _OrderTempoWidgetState extends State<OrderTempoWidget> {
  String cari = '';
  List<DocumentSnapshot> documents = [];

  TextEditingController tempo = TextEditingController();
  TextEditingController bayar = TextEditingController();

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
                        future: DatabaseServices.readDataOnceShowWithOneCond('pesananSementara', 'idPesanan', 'statusTempo', 'Belum Lunas'),
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
                                                              var dataPesanan = await DatabaseServices.readDataWithCondition('pesananSementara', 'idPesanan', snapshot.data![index]);
                                                              if (dataPesanan!['id'] != null) {
                                                                for (var i = 0; i < dataPesanan['id'].length; i++) {
                                                                  var hasil = '';

                                                                  var dataProduk = await DatabaseServices.readDataWithCondition('produk', 'namaProduk', dataPesanan['data'][i]['namaProduk']);
                                                                  if (dataProduk!['data'] != null) {
                                                                    if (dataPesanan['data'][i]['jenisHarga'] == 'DumpTruck') {
                                                                      hasil = (double.parse(dataProduk['data'][0]['stokProduk']) + (double.parse(dataPesanan['data'][i]['jumlahProduk']) * 7.1)).toString();
                                                                    } else {
                                                                      hasil = (double.parse(dataProduk['data'][0]['stokProduk']) + double.parse(dataPesanan['data'][i]['jumlahProduk'])).toString();
                                                                    }
                                                                    Map<String, String> input = {};
                                                                    input['stokProduk'] = hasil;
                                                                    input['namaProduk'] = dataProduk['data'][0]['namaProduk'];
                                                                    input['hargaEceran'] = dataProduk['data'][0]['hargaEceran'];
                                                                    input['hargaDT'] = dataProduk['data'][0]['hargaDT'];

                                                                    await DatabaseServices.updateDataWithDocId('produk', '${dataProduk['id'][0]}', input);
                                                                    await DatabaseServices.deleteDataFirestore('pesananSementara', dataPesanan['id'][i]);
                                                                    setState(() {});
                                                                  }
                                                                }
                                                                Navigator.of(context).pop();
                                                              }
                                                              await MessageService.showSnackBar(context, 'Berhasil dihapus');
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
                                                        itemCount: snapshot.data!['data'].length,
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
                                                    SizedBox(
                                                      height: 40,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        children: [
                                                          ElevatedButton(
                                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                                              onPressed: () async {
                                                                await DataServices.createPDF(snapshot.data!, 'TEMPO', 'tagihan', '', '');
                                                              },
                                                              child: Text('Cetak 1')),
                                                          ElevatedButton(
                                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                                                              onPressed: () async {
                                                                DateTimeRange? rangeTanggal;
                                                                TextEditingController tanggalLaporan = TextEditingController();
                                                                rangeTanggal = await OtherServices.showDateTimeRange(context);
                                                                if (rangeTanggal != null) {
                                                                  tanggalLaporan.text = DateFormat('dd/MM/yyyy').format(rangeTanggal.start).split(' ')[0] + '-' + DateFormat('dd/MM/yyyy').format(rangeTanggal.end).split(' ')[0];
                                                                  var data = await DatabaseServices.readDataWithTwoDateRange(
                                                                    'pesananSementara',
                                                                    'tglTransaksi',
                                                                    DateFormat('yyyy-MM-dd').format(rangeTanggal.end.add(Duration(days: 1))),
                                                                    'tglTransaksi',
                                                                    DateFormat('yyyy-MM-dd').format(rangeTanggal.start),
                                                                  );
                                                                  // print(snapshot.data!['data'][0]['namaPelanggan']);
                                                                  List selectedData = [];
                                                                  Map dataAll = {};

                                                                  for (var i = 0; i < data!['data'].length; i++) {
                                                                    if (data['data'][i]['namaPelanggan'].toString().toLowerCase().trim() == snapshot.data!['data'][0]['namaPelanggan'].toString().toLowerCase().trim() && data['data'][i]['statusTempo'] == 'Belum Lunas') {
                                                                      selectedData.add(data['data'][i]);
                                                                    }
                                                                  }
                                                                  dataAll['data'] = selectedData;
                                                                  await DataServices.createPDF(dataAll, 'TEMPO', 'totaltagihan', DateFormat('dd/MM/yyyy').format(rangeTanggal.start).split(' ')[0].toString(), DateFormat('dd/MM/yyyy').format(rangeTanggal.end).split(' ')[0].toString());

                                                                  // print(selectedData.length);
                                                                }
                                                              },
                                                              child: Text('Cetak Semua')),
                                                          IconButton(
                                                            onPressed: () async {
                                                              tempo.text = snapshot.data!['data'][0]['utang'];
                                                              bayar.text = '';
                                                              await showDialog(
                                                                context: context,
                                                                builder: (context) {
                                                                  return AlertDialog(
                                                                    title: Text('Pembayaran Tempo ${snapshot.data!['data'][0]['namaPelanggan']}'),
                                                                    content: Container(
                                                                      child: Column(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [
                                                                          Padding(
                                                                            padding: EdgeInsets.symmetric(
                                                                              vertical: 2.sp,
                                                                            ),
                                                                            child: TextFormField(
                                                                              controller: tempo,
                                                                              obscureText: false,
                                                                              decoration: InputDecoration(
                                                                                labelText: 'Sisa Tempo',
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
                                                                          Padding(
                                                                            padding: EdgeInsets.symmetric(
                                                                              vertical: 2.sp,
                                                                            ),
                                                                            child: TextFormField(
                                                                              controller: bayar,
                                                                              obscureText: false,
                                                                              decoration: InputDecoration(
                                                                                labelText: 'Pembayaran',
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
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    actions: [
                                                                      TextButton(
                                                                          style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.green)),
                                                                          onPressed: () async {
                                                                            var jumlahData = snapshot.data!['data'].length;

                                                                            for (var i = 0; i < jumlahData; i++) {
                                                                              try {
                                                                                Map<String, String> input = {};
                                                                                String hasil = '';
                                                                                if (bayar.text != '') {
                                                                                  hasil = (int.parse(snapshot.data!['data'][i]['utang']) - int.parse(bayar.text)).toString();
                                                                                  if (int.parse(hasil) == 0) {
                                                                                    input['statusTempo'] = 'Lunas';
                                                                                    input['utang'] = '0';
                                                                                  } else if (int.parse(hasil) > 0) {
                                                                                    input['statusTempo'] = snapshot.data!['data'][i]['statusTempo'];
                                                                                    input['utang'] = hasil;
                                                                                  }
                                                                                  input['idPesanan'] = snapshot.data!['data'][i]['idPesanan'];
                                                                                  input['tglTransaksi'] = snapshot.data!['data'][i]['tglTransaksi'];
                                                                                  input['namaKasir'] = snapshot.data!['data'][i]['namaKasir'];
                                                                                  input['namaProduk'] = snapshot.data!['data'][i]['namaProduk'];
                                                                                  input['jumlahProduk'] = snapshot.data!['data'][i]['jumlahProduk'];
                                                                                  input['subTotal'] = snapshot.data!['data'][i]['subTotal'];
                                                                                  input['jenisHarga'] = snapshot.data!['data'][i]['jenisHarga'];
                                                                                  input['jenisMetode'] = snapshot.data!['data'][i]['jenisMetode'];
                                                                                  input['jenisService'] = snapshot.data!['data'][i]['jenisService'];

                                                                                  input['statusAntar'] = snapshot.data!['data'][i]['statusAntar'];
                                                                                  input['namaPelanggan'] = snapshot.data!['data'][i]['namaPelanggan'];
                                                                                  input['total'] = snapshot.data!['data'][i]['total'];

                                                                                  input['ongkir'] = snapshot.data!['data'][i]['ongkir'];

                                                                                  await DatabaseServices.updateDataWithDocId('pesananSementara', '${snapshot.data!['id'][i]}', input);
                                                                                }
                                                                                await MessageService.showSnackBar(context, 'Pesanan telah dibayar');
                                                                              } catch (e) {
                                                                                print(e);
                                                                              }
                                                                            }

                                                                            setState(() {});

                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child: Text('Bayar')),
                                                                      TextButton(
                                                                          style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.red)),
                                                                          onPressed: () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child: Text('Batal')),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            icon: Icon(
                                                              Icons.done_rounded,
                                                              size: 17.sp,
                                                              color: Colors.green,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            onPressed: () async {
                                                              DateTimeRange? rangeTanggal;
                                                              TextEditingController tanggalLaporan = TextEditingController();
                                                              try {
                                                                rangeTanggal = await OtherServices.showDateTimeRange(context);
                                                                if (rangeTanggal != null) {
                                                                  tanggalLaporan.text = DateFormat('dd/MM/yyyy').format(rangeTanggal.start).split(' ')[0] + '-' + DateFormat('dd/MM/yyyy').format(rangeTanggal.end).split(' ')[0];
                                                                  var data = await DatabaseServices.readDataWithTwoDateRange(
                                                                    'pesananSementara',
                                                                    'tglTransaksi',
                                                                    DateFormat('yyyy-MM-dd').format(rangeTanggal.end.add(Duration(days: 1))),
                                                                    'tglTransaksi',
                                                                    DateFormat('yyyy-MM-dd').format(rangeTanggal.start),
                                                                  );
                                                                  // print(snapshot.data!['data'][0]['namaPelanggan']);
                                                                  List selectedData = [];
                                                                  List selectedId = [];

                                                                  for (var i = 0; i < data!['data'].length; i++) {
                                                                    if ((data['data'][i]['namaPelanggan'].toString().toLowerCase().trim() == snapshot.data!['data'][0]['namaPelanggan'].toString().toLowerCase().trim()) && (data['data'][i]['statusTempo'] == 'Belum Lunas')) {
                                                                      selectedData.add(data['data'][i]);
                                                                      selectedId.add(data['id'][i]);
                                                                    }
                                                                  }

                                                                  await showDialog(
                                                                    context: context,
                                                                    builder: (context) {
                                                                      return AlertDialog(
                                                                        title: Text('Selesaikan Tagihan'),
                                                                        content: Text('Toko ${selectedData[0]['namaPelanggan']} \nPeriode ${tanggalLaporan.text}'),
                                                                        actions: [
                                                                          TextButton(
                                                                              style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.green)),
                                                                              onPressed: () async {
                                                                                int count = 0;
                                                                                for (var element in selectedData) {
                                                                                  print(element['idPesanan']);
                                                                                  try {
                                                                                    // print(selectedData[i]);
                                                                                    Map<String, String> input = {};

                                                                                    input['statusTempo'] = 'Lunas';
                                                                                    input['utang'] = '0';

                                                                                    input['idPesanan'] = element['idPesanan'];
                                                                                    input['tglTransaksi'] = element['tglTransaksi'];
                                                                                    input['namaKasir'] = element['namaKasir'];
                                                                                    input['namaProduk'] = element['namaProduk'];
                                                                                    input['jumlahProduk'] = element['jumlahProduk'];
                                                                                    input['subTotal'] = element['subTotal'];
                                                                                    input['jenisHarga'] = element['jenisHarga'];
                                                                                    input['jenisMetode'] = 'Tempo Transfer';
                                                                                    input['jenisService'] = element['jenisService'];

                                                                                    input['statusAntar'] = 'Sudah Antar';
                                                                                    input['namaPelanggan'] = element['namaPelanggan'];
                                                                                    input['total'] = element['total'];

                                                                                    input['ongkir'] = element['ongkir'];

                                                                                    await DatabaseServices.updateDataWithDocId('pesananSementara', '${selectedId[count]}', input);
                                                                                    count++;
                                                                                    setState(() {});
                                                                                  } catch (e) {
                                                                                    print(e);
                                                                                  }
                                                                                }

                                                                                await MessageService.showSnackBar(context, 'Pesanan telah Selesai');

                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: Text('Selesai')),
                                                                          TextButton(
                                                                              style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.red)),
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: Text('Batal')),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                }
                                                              } catch (e) {}
                                                            },
                                                            icon: Icon(
                                                              Icons.done_all,
                                                              size: 17.sp,
                                                              color: Colors.lightBlue,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
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
