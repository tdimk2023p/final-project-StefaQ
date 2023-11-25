import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasispeechtotext/services/dataServices.dart';
import 'package:aplikasispeechtotext/services/dbservices.dart';
import 'package:aplikasispeechtotext/services/messageServices.dart';
import 'package:sizer/sizer.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ProductWidget extends StatefulWidget {
  const ProductWidget({super.key});

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  TextEditingController namaProduk = TextEditingController();
  TextEditingController hargaEceran = TextEditingController();
  TextEditingController hargaDT = TextEditingController();
  TextEditingController stokProduk = TextEditingController();

  String cari = '';
  List<DocumentSnapshot> documents = [];

  bool dengarEcer = false;
  bool dengarDT = false;
  bool dengarStok = false;

  stt.SpeechToText? bicara;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bicara = stt.SpeechToText();
  }

  void dengarinEcer() async {
    if (!dengarEcer) {
      bool tersedia = await bicara!.initialize(
        onStatus: (status) => print(status),
        onError: (errorNotification) => print(errorNotification),
      );
      if (tersedia) {
        setState(() => dengarEcer = false);
        bicara!.listen(
          onResult: (result) => setState(
            () {
              String nilaiawal = result.recognizedWords;
              List<String> parts = nilaiawal.split('.');
              String nilaiakhir = '';
              for (var part in parts) {
                nilaiakhir = nilaiakhir + part;
              }
              hargaEceran.text = nilaiakhir;
            },
          ),
        );
      }
    } else {
      setState(() => dengarEcer = false);
      bicara!.stop();
    }
  }

  void dengarinDT() async {
    if (!dengarDT) {
      bool tersedia = await bicara!.initialize(
        onStatus: (status) => print(status),
        onError: (errorNotification) => print(errorNotification),
      );
      if (tersedia) {
        setState(() => dengarDT = false);
        bicara!.listen(
          onResult: (result) => setState(
            () {
              String nilaiawal = result.recognizedWords;
              List<String> parts = nilaiawal.split('.');
              String nilaiakhir = '';
              for (var part in parts) {
                nilaiakhir = nilaiakhir + part;
              }

              hargaDT.text = nilaiakhir;
            },
          ),
        );
      }
    } else {
      setState(() => dengarDT = false);
      bicara!.stop();
    }
  }

  void dengarinStok() async {
    if (!dengarStok) {
      bool tersedia = await bicara!.initialize(
        onStatus: (status) => print(status),
        onError: (errorNotification) => print(errorNotification),
      );
      if (tersedia) {
        setState(() => dengarStok = false);
        bicara!.listen(
          onResult: (result) => setState(
            () {
              String nilaiawal = result.recognizedWords;
              List<String> parts = nilaiawal.split('.');
              String nilaiakhir = '';
              for (var part in parts) {
                nilaiakhir = nilaiakhir + part;
              }

              stokProduk.text = nilaiakhir;
            },
          ),
        );
      }
    } else {
      setState(() => dengarStok = false);
      bicara!.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.cyan,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                child: Text(
                  'Menu Produk',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            cari = value;
                          });
                        },
                        obscureText: false,
                        decoration: InputDecoration(
                            labelStyle: TextStyle(color: Colors.cyan, fontSize: 9.sp),
                            labelText: 'Cari',
                            prefixIconColor: Colors.cyan,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              size: 12.sp,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orangeAccent,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsetsDirectional.fromSTEB(8.sp, 8.sp, 8.sp, 8.sp)),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('produk').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            documents = snapshot.data!.docs;

                            if (cari.length > 0) {
                              documents = snapshot.data!.docs.where((element) {
                                return element.get('namaProduk').toString().toLowerCase().contains(cari.toLowerCase());
                              }).toList();
                            }

                            return ListView.builder(
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    namaProduk.text = documents[index]['namaProduk'];
                                    hargaEceran.text = documents[index]['hargaEceran'];
                                    hargaDT.text = documents[index]['hargaDT'];
                                    stokProduk.text = documents[index]['stokProduk'];
                                    await showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          child: ListView(
                                            children: [
                                              SizedBox(
                                                height: 30.sp,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller: namaProduk,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      labelText: 'Nama Produk',
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
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller: hargaEceran,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      labelText: 'Harga Eceran (m3)',
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
                                                padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller: hargaDT,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      labelText: 'Harga DT (7.1 m3)',
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
                                                padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller: stokProduk,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      labelText: 'Stok Produk (m3)',
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
                                                padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                                                  onPressed: () async {
                                                    String docId = snapshot.data!.docs[index].id;
                                                    Map<String, String> input = {};

                                                    if (namaProduk.text != '' && hargaEceran.text != '' && hargaDT.text != '' && stokProduk.text != '') {
                                                      input['namaProduk'] = namaProduk.text;
                                                      input['hargaEceran'] = hargaEceran.text;
                                                      input['hargaDT'] = hargaDT.text;
                                                      input['stokProduk'] = stokProduk.text;

                                                      try {
                                                        await DatabaseServices.updateDataWithDocId('produk', docId, input);
                                                        Navigator.of(context).pop();
                                                        await MessageService.showSnackBar(context, 'Berhasil diubah');
                                                      } catch (e) {
                                                        print(e);
                                                      }
                                                    } else {
                                                      await MessageService.showSnackBar(context, 'Data tidak boleh kosong');
                                                    }
                                                  },
                                                  child: Text('Ubah Produk'),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 15.sp),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  onPressed: () async {
                                                    String docId = documents[index].id;

                                                    try {
                                                      await DatabaseServices.deleteDataFirestore('produk', docId);
                                                      Navigator.of(context).pop();
                                                      await MessageService.showSnackBar(context, 'Berhasil dihapus');
                                                    } catch (e) {
                                                      print(e);
                                                    }
                                                  },
                                                  child: Text('Hapus Produk'),
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.viewInsetsOf(context).bottom,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Card(
                                    elevation: 5,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Image.asset('assets/icons/product.png'),
                                      ),
                                      title: Text('${documents[index]['namaProduk']}'),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Harga Eceran (1 m3)'),
                                              Text('${NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(documents[index]['hargaEceran']))}'),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Harga DumpTruk (7.1 m3)'),
                                              Text('${NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(documents[index]['hargaDT']))}'),
                                            ],
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        child: Icon(Icons.add),
        onPressed: () async {
          namaProduk.text = '';
          hargaEceran.text = '';
          hargaDT.text = '';
          stokProduk.text = '';

          await showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                child: ListView(
                  children: [
                    SizedBox(
                      height: 30.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                      child: Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: namaProduk,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Nama Produk',
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
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                      child: Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: hargaEceran,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Harga Eceran (m3)',
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
                            suffixIcon: IconButton(
                              onPressed: dengarinEcer,
                              icon: Icon(dengarEcer ? Icons.mic : Icons.mic_none),
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
                      padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                      child: Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: hargaDT,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Harga DT (7.1 m3)',
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
                            suffixIcon: IconButton(
                              onPressed: dengarinDT,
                              icon: Icon(dengarDT ? Icons.mic : Icons.mic_none),
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
                      padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                      child: Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: stokProduk,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Stok Produk (m3)',
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
                            suffixIcon: IconButton(
                              onPressed: dengarinStok,
                              icon: Icon(dengarStok ? Icons.mic : Icons.mic_none),
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
                      padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                        onPressed: () async {
                          String docId = DataServices.randomChar();
                          Map<String, String> input = {};

                          if (namaProduk.text != '' && hargaEceran.text != '' && hargaDT.text != '' && stokProduk.text != '') {
                            input['namaProduk'] = namaProduk.text;
                            input['hargaEceran'] = hargaEceran.text;
                            input['hargaDT'] = hargaDT.text;
                            input['stokProduk'] = stokProduk.text;

                            try {
                              await DatabaseServices.createDataWithDocId('produk', docId, input);
                              Navigator.of(context).pop();
                              await MessageService.showSnackBar(context, 'Berhasil ditambah');
                            } catch (e) {
                              print(e);
                            }
                          } else {
                            await MessageService.showSnackBar(context, 'Data tidak boleh kosong');
                          }
                        },
                        child: Text('Tambah Produk'),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.viewInsetsOf(context).bottom,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
