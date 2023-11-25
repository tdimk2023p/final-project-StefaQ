import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasispeechtotext/screen/adminHomeScreen.dart';
import 'package:aplikasispeechtotext/services/dataServices.dart';
import 'package:aplikasispeechtotext/services/dbservices.dart';
import 'package:aplikasispeechtotext/services/messageServices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class OrderWidget extends StatefulWidget {
  const OrderWidget({super.key});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  String cari = '';
  List<DocumentSnapshot> documents = [];
  List<DropdownMenuItem<String>> hargaListItemWidget = [
    DropdownMenuItem(
      child: Text(
        'Manual',
        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.cyan),
      ),
      value: 'Manual',
    ),
    DropdownMenuItem(
      child: Text(
        'Eceran',
        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.cyan),
      ),
      value: 'Eceran',
    ),
    DropdownMenuItem(
      child: Text(
        'DumpTruck',
        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.cyan),
      ),
      value: 'DumpTruck',
    ),
  ];

  List<DropdownMenuItem<String>> serviceListItemWidget = [
    DropdownMenuItem(
      child: Text(
        'Ambil Sendiri',
        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.cyan),
      ),
      value: 'Ambil Sendiri',
    ),
    DropdownMenuItem(
      child: Text(
        'Antar',
        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.cyan),
      ),
      value: 'Antar',
    ),
  ];

  List<DropdownMenuItem<String>> metodeListItemWidget = [
    DropdownMenuItem(
      child: Text(
        'Cash',
        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.cyan),
      ),
      value: 'Cash',
    ),
    DropdownMenuItem(
      child: Text(
        'Transfer Bank',
        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.cyan),
      ),
      value: 'Transfer Bank',
    ),
    DropdownMenuItem(
      child: Text(
        'Tempo Cash',
        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.cyan),
      ),
      value: 'Tempo Cash',
    ),
    DropdownMenuItem(
      child: Text(
        'Tempo Transfer',
        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.cyan),
      ),
      value: 'Tempo Transfer',
    ),
  ];

  String selectedHarga = "Manual";
  String selectedMetode = "Cash";
  String selectedService = "Ambil Sendiri";
  List<TextEditingController> hargaSatuan = [];
  List<TextEditingController> nama = [];
  List<TextEditingController> jumlah = [];
  List<TextEditingController> subTotal = [];

  int jumlahPesanan = 0;

  String total = '0';
  TextEditingController ongkir = TextEditingController();
  TextEditingController namaPembeli = TextEditingController();
  TextEditingController uangBayar = TextEditingController();
  bool dengarBarang = false;
  stt.SpeechToText? bicara;
  String nilaiDengar = '';

  List<DropdownMenuItem<BluetoothDevice>> getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text(
          'Perangkat tidak ditemukan',
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
    } else {
      devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(
            device.name!,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          value: device,
        ));
      });
    }
    return items;
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => connected = false);
  }

  Future<void> dengarinBarang() async {
    if (!dengarBarang) {
      bool tersedia = await bicara!.initialize(
        onStatus: (status) => print(status),
        onError: (errorNotification) => print(errorNotification),
      );
      if (tersedia) {
        setState(() => dengarBarang = false);
        bicara!.listen(
          onResult: (result) => setState(
            () {
              nilaiDengar = result.recognizedWords;
            },
          ),
        );
      }
    } else {
      setState(() => dengarBarang = false);
      bicara!.stop();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bicara = stt.SpeechToText();
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Menu Pesanan ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp),
                    ),
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Metode yang digunakan'),
                                content: StatefulBuilder(
                                  builder: (context, setState) {
                                    return DropdownButton(
                                      isExpanded: true,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 9.sp,
                                      ),
                                      value: selectedHarga,
                                      onChanged: (String? Value) {
                                        setState(() {
                                          selectedHarga = Value!;
                                          //
                                        });
                                      },
                                      items: hargaListItemWidget.toList(),
                                    );
                                  },
                                ),
                                actions: [
                                  TextButton(
                                      style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.green)),
                                      onPressed: () async {
                                        Navigator.of(context).pop();

                                        int indeks = 0;

                                        if (selectedHarga == 'Manual') {
                                          indeks = 0;
                                        } else if (selectedHarga == 'Eceran') {
                                          indeks = 2;
                                        }
                                        if (selectedHarga == 'DumpTruck') {
                                          indeks = 3;
                                        }

                                        await showModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Column(
                                              children: [
                                                SizedBox(
                                                  height: 9.sp,
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: FutureBuilder(
                                                    future: DataServices.readIntPreferences('jumlahPesanan'),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        Map pesanan = {};
                                                        jumlahPesanan = int.parse(snapshot.data!.toString());
                                                        for (var i = 0; i < snapshot.data!; i++) {
                                                          hargaSatuan.add(TextEditingController(text: ''));
                                                          nama.add(TextEditingController(text: ''));

                                                          jumlah.add(TextEditingController(text: ''));
                                                          subTotal.add(TextEditingController(text: ''));
                                                        }

                                                        return ListView.builder(
                                                          itemCount: snapshot.data,
                                                          itemBuilder: (context, index) {
                                                            return Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 5.sp),
                                                              child: FutureBuilder(
                                                                future: DataServices.readListPreferences('pesanan$index'),
                                                                builder: (context, snapshot) {
                                                                  if (snapshot.hasData) {
                                                                    if (indeks != 0) {
                                                                      hargaSatuan[index].text = snapshot.data![indeks].toString();
                                                                    }

                                                                    nama[index].text = snapshot.data![1].toString();

                                                                    return Card(
                                                                      elevation: 5,
                                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                                      child: Column(
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              Padding(
                                                                                padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                                                child: Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      '${snapshot.data?[1]}',
                                                                                      style: TextStyle(
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontSize: 11.sp,
                                                                                      ),
                                                                                    ),
                                                                                    IconButton(
                                                                                        onPressed: () async {
                                                                                          await DataServices.deleteListOrderPreferences(index.toString());
                                                                                          nama.removeAt(index);
                                                                                          hargaSatuan.removeAt(index);
                                                                                          jumlah.removeAt(index);
                                                                                          subTotal.removeAt(index);
                                                                                          jumlahPesanan = jumlahPesanan - 1;

                                                                                          setState(() {});
                                                                                          Navigator.of(context).pop();
                                                                                        },
                                                                                        icon: Icon(
                                                                                          Icons.delete,
                                                                                          color: Colors.red,
                                                                                        ))
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Padding(
                                                                              padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                                              child: TextFormField(
                                                                                onChanged: (value) {
                                                                                  hargaSatuan[index].text = value.toString();
                                                                                },
                                                                                //enabled: selectedHarga == 'Manual' ? true : false,
                                                                                controller: hargaSatuan[index],
                                                                                // initialValue: hargaSatuan[index].text,
                                                                                obscureText: false,
                                                                                decoration: InputDecoration(
                                                                                  labelText: selectedHarga == 'Manual'
                                                                                      ? 'Harga Manual'
                                                                                      : selectedHarga == 'Eceran'
                                                                                          ? 'Harga Eceran'
                                                                                          : 'Harga DumpTruck',
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
                                                                                keyboardType: TextInputType.number,
                                                                              )),
                                                                          Padding(
                                                                              padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                                              child: TextFormField(
                                                                                onChanged: (value) {
                                                                                  jumlah[index].text = value.toString();
                                                                                },
                                                                                controller: jumlah[index],
                                                                                obscureText: false,
                                                                                decoration: InputDecoration(
                                                                                  labelText: selectedHarga == 'Manual'
                                                                                      ? 'Jumlah /m3'
                                                                                      : selectedHarga == 'Eceran'
                                                                                          ? 'Jumlah /m3'
                                                                                          : 'Jumlah / 7.1 m3',
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
                                                                                keyboardType: TextInputType.number,
                                                                              )),
                                                                          Padding(
                                                                            padding: EdgeInsets.symmetric(horizontal: 15.sp),
                                                                            child: const Divider(
                                                                              thickness: 4,
                                                                              color: Colors.grey,
                                                                            ),
                                                                          ),
                                                                          StreamBuilder(
                                                                            stream: Stream.periodic(Duration(seconds: 1)),
                                                                            builder: (context, snapshot) {
                                                                              if (hargaSatuan[index].text != '' && jumlah[index].text != '') {
                                                                                subTotal[index].text = (double.parse(hargaSatuan[index].text) * double.parse(jumlah[index].text)).toStringAsFixed(0);
                                                                              }

                                                                              return Padding(
                                                                                  padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                                                  child: TextFormField(
                                                                                    controller: subTotal[index],
                                                                                    // initialValue: subTotal[index].text = TextEditingController(text: '').text,
                                                                                    obscureText: false,
                                                                                    readOnly: true,
                                                                                    enabled: false,
                                                                                    decoration: InputDecoration(
                                                                                      labelText: 'SubTotal',
                                                                                      labelStyle: TextStyle(
                                                                                        color: Colors.cyan,
                                                                                        fontSize: 11.sp,
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
                                                                                      fontSize: 11.sp,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                    keyboardType: TextInputType.number,
                                                                                  ));
                                                                            },
                                                                          ),
                                                                          SizedBox(
                                                                            height: MediaQuery.of(context).viewInsets.bottom,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    return Container();
                                                                  }
                                                                },
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        return Container();
                                                      }
                                                    },
                                                  ),
                                                ),
                                                Card(
                                                  elevation: 10,
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                        child: TextFormField(
                                                          controller: namaPembeli,
                                                          obscureText: false,
                                                          decoration: InputDecoration(
                                                            labelText: 'Nama Pembeli',
                                                            labelStyle: TextStyle(
                                                              color: Colors.black,
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
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                        child: TextFormField(
                                                          controller: ongkir,
                                                          obscureText: false,
                                                          decoration: InputDecoration(
                                                            labelText: 'Ongkos Kirim (Opsional khusus Pengantaran)',
                                                            labelStyle: TextStyle(
                                                              color: Colors.black,
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
                                                          keyboardType: TextInputType.number,
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                        height: 40.sp,
                                                        width: double.infinity,
                                                        child: ElevatedButton.icon(
                                                          style: ButtonStyle(
                                                            shape: MaterialStatePropertyAll(
                                                              RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
                                                            ),
                                                            backgroundColor: MaterialStatePropertyAll(Colors.red),
                                                          ),
                                                          onPressed: () async {
                                                            total = '0';
                                                            List<String> cekData = [];
                                                            for (var i = 0; i < jumlahPesanan; i++) {
                                                              cekData.add(subTotal[i].text);
                                                            }

                                                            if (cekData.contains('')) {
                                                            } else {
                                                              for (var i = 0; i < jumlahPesanan; i++) {
                                                                total = (double.parse(total) + double.parse(subTotal[i].text)).toStringAsFixed(0);
                                                              }

                                                              if (ongkir.text != '') {
                                                                total = (double.parse(total) + double.parse(ongkir.text)).toStringAsFixed(0);
                                                              }

                                                              final String totalTetap = total;
                                                              //

                                                              var stock = '';
                                                              var cekStok = true;
                                                              for (var i = 0; i < jumlahPesanan; i++) {
                                                                var dataProduk = await DatabaseServices.readDataWithCondition('produk', 'namaProduk', nama[i].text);
                                                                if (dataProduk!['data'] != null) {
                                                                  if (selectedHarga == 'DumpTruck') {
                                                                    stock = (double.parse(dataProduk['data'][0]['stokProduk']) - (double.parse(jumlah[i].text) * 7.1)).toString();
                                                                  } else {
                                                                    stock = (double.parse(dataProduk['data'][0]['stokProduk']) - double.parse(jumlah[i].text)).toString();
                                                                  }
                                                                }

                                                                if (double.parse(stock) < 0) {
                                                                  await MessageService.showSnackBar(context, "Stok ${dataProduk?['data'][0]['namaProduk']} Habis");
                                                                  Navigator.of(context).pop();
                                                                  return;
                                                                }
                                                              }

                                                              await showModalBottomSheet(
                                                                context: context,
                                                                builder: (context) {
                                                                  return Column(
                                                                    children: [
                                                                      SizedBox(
                                                                        height: 10.sp,
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child: ListView.builder(
                                                                          itemCount: jumlahPesanan,
                                                                          itemBuilder: (context, index) {
                                                                            return Card(
                                                                              child: ListTile(
                                                                                title: Text(nama[index].text),
                                                                                subtitle: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Text('@${jumlah[index].text} x ${NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(hargaSatuan[index].text))}'),
                                                                                    Text('${NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(subTotal[index].text))}'),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 30.sp,
                                                                        child: Text(
                                                                          'Total Bayar : ${NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(total))}',
                                                                          style: TextStyle(
                                                                            fontSize: 11.sp,
                                                                            color: Colors.black,
                                                                            fontWeight: FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 120.sp,
                                                                        child: Padding(
                                                                          padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                                          child: TextFormField(
                                                                            controller: uangBayar,
                                                                            obscureText: false,
                                                                            decoration: InputDecoration(
                                                                              labelText: 'Uang Bayar',
                                                                              labelStyle: TextStyle(
                                                                                color: Colors.black,
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
                                                                            keyboardType: TextInputType.number,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 30.sp,
                                                                        child: StatefulBuilder(
                                                                          builder: (context, setState) {
                                                                            return DropdownButton(
                                                                              isExpanded: true,
                                                                              padding: EdgeInsets.symmetric(
                                                                                horizontal: 9.sp,
                                                                              ),
                                                                              value: selectedService,
                                                                              onChanged: (String? Value) {
                                                                                setState(() {
                                                                                  selectedService = Value!;
                                                                                  //
                                                                                });
                                                                              },
                                                                              items: serviceListItemWidget.toList(),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 30.sp,
                                                                        child: StatefulBuilder(
                                                                          builder: (context, setState) {
                                                                            return DropdownButton(
                                                                              isExpanded: true,
                                                                              padding: EdgeInsets.symmetric(
                                                                                horizontal: 9.sp,
                                                                              ),
                                                                              value: selectedMetode,
                                                                              onChanged: (String? Value) {
                                                                                setState(() {
                                                                                  selectedMetode = Value!;
                                                                                  //
                                                                                });
                                                                              },
                                                                              items: metodeListItemWidget.toList(),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                                        height: 40.sp,
                                                                        width: double.infinity,
                                                                        child: Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 3,
                                                                              child: StatefulBuilder(
                                                                                builder: (context, setState) {
                                                                                  return DropdownButton(
                                                                                    isExpanded: true,
                                                                                    items: getDeviceItems(),
                                                                                    onChanged: (value) => setState(() {
                                                                                      device = value as BluetoothDevice?;
                                                                                      bluetooth.connect(device!);
                                                                                    }),
                                                                                    value: device,
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: ElevatedButton.icon(
                                                                                style: ButtonStyle(
                                                                                  shape: MaterialStatePropertyAll(
                                                                                    RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(12),
                                                                                    ),
                                                                                  ),
                                                                                  backgroundColor: MaterialStatePropertyAll(Colors.green),
                                                                                ),
                                                                                onPressed: () async {
                                                                                  String idPesanan = DataServices.charFromDateTime(DateTime.now());
                                                                                  String jenis = '0';
                                                                                  String statusTempo = 'Lunas';
                                                                                  String statusAntar = 'Sudah Antar';
                                                                                  if (ongkir.text == '') {
                                                                                    ongkir.text = '0';
                                                                                  }

                                                                                  if (selectedMetode == 'Tempo Cash') {
                                                                                    jenis = total.toString();
                                                                                    statusTempo = 'Belum Lunas';
                                                                                  }

                                                                                  if (selectedMetode == 'Tempo Transfer') {
                                                                                    jenis = total.toString();
                                                                                    statusTempo = 'Belum Lunas';
                                                                                  }

                                                                                  if (selectedService == 'Antar') {
                                                                                    statusAntar = 'Belum Antar';
                                                                                  }

                                                                                  if (jumlahPesanan > 0) {
                                                                                    if (selectedMetode == 'Cash' || selectedMetode == 'Transfer Bank') {
                                                                                      if (int.parse(uangBayar.text) >= int.parse(total)) {
                                                                                        try {
                                                                                          List dataPrint = [];
                                                                                          for (var i = 0; i < jumlahPesanan; i++) {
                                                                                            Map<String, String> input = {};
                                                                                            DateTime tglPesanan = DateTime.now();
                                                                                            String docId = DataServices.charFromDateTime(tglPesanan);

                                                                                            input['tglTransaksi'] = tglPesanan.toString();
                                                                                            input['idPesanan'] = idPesanan;
                                                                                            input['namaProduk'] = nama[i].text;
                                                                                            input['jumlahProduk'] = jumlah[i].text;
                                                                                            input['subTotal'] = subTotal[i].text;
                                                                                            input['jenisHarga'] = selectedHarga;
                                                                                            input['jenisMetode'] = selectedMetode;
                                                                                            input['jenisService'] = selectedService;
                                                                                            input['statusTempo'] = statusTempo;
                                                                                            input['statusAntar'] = statusAntar;
                                                                                            input['namaPelanggan'] = namaPembeli.text;
                                                                                            input['total'] = total;
                                                                                            if (selectedMetode == 'Tempo Cash' || selectedMetode == 'Tempo Transfer') {
                                                                                              if (int.parse(uangBayar.text) < int.parse(total)) {
                                                                                                input['utang'] = (int.parse(total) - int.parse(uangBayar.text)).toString();
                                                                                              } else {
                                                                                                input['utang'] = '0';
                                                                                                statusTempo = 'Lunas';
                                                                                              }
                                                                                            } else {
                                                                                              input['utang'] = jenis;
                                                                                            }
                                                                                            input['ongkir'] = ongkir.text;

                                                                                            List<String>? dataUser = await DataServices.readListPreferences('dataUser');
                                                                                            if (dataUser != null) {
                                                                                              input['namaKasir'] = dataUser[1];
                                                                                            }

                                                                                            var dataProduk = await DatabaseServices.readDataWithCondition('produk', 'namaProduk', nama[i].text);
                                                                                            var hasil = '';
                                                                                            if (dataProduk!['data'] != null) {
                                                                                              if (selectedHarga == 'DumpTruck') {
                                                                                                hasil = (double.parse(dataProduk['data'][0]['stokProduk']) - (double.parse(jumlah[i].text) * 7.1)).toString();
                                                                                              } else {
                                                                                                hasil = (double.parse(dataProduk['data'][0]['stokProduk']) - double.parse(jumlah[i].text)).toString();
                                                                                              }

                                                                                              Map<String, String> input2 = {};
                                                                                              input2['stokProduk'] = hasil;
                                                                                              input2['namaProduk'] = dataProduk['data'][0]['namaProduk'];
                                                                                              input2['hargaEceran'] = dataProduk['data'][0]['hargaEceran'];
                                                                                              input2['hargaDT'] = dataProduk['data'][0]['hargaDT'];

                                                                                              await DatabaseServices.updateDataWithDocId('produk', '${dataProduk['id'][0]}', input2);
                                                                                            }

                                                                                            dataPrint.add(input);
                                                                                            await DatabaseServices.createDataWithDocId('pesananSementara', docId, input);

                                                                                            await DataServices.deletePreferences('pesanan$i');
                                                                                          }

                                                                                          await DataServices.printStruk(dataPrint, namaPembeli.text, uangBayar.text, ongkir.text);

                                                                                          Navigator.of(context).pop();

                                                                                          nama.clear();
                                                                                          hargaSatuan.clear();
                                                                                          jumlah.clear();
                                                                                          subTotal.clear();
                                                                                          jumlahPesanan = 0;
                                                                                          ongkir.clear();
                                                                                          total = '0';
                                                                                          namaPembeli.clear();
                                                                                          uangBayar.text = '';
                                                                                          await DataServices.deletePreferences('jumlahPesanan');
                                                                                          await MessageService.showSnackBar(context, 'Berhasil diproses');
                                                                                          setState(() {});
                                                                                        } catch (e) {
                                                                                          print(e);
                                                                                        }
                                                                                      }
                                                                                    } else {
                                                                                      try {
                                                                                        List dataPrint = [];
                                                                                        for (var i = 0; i < jumlahPesanan; i++) {
                                                                                          Map<String, String> input = {};
                                                                                          DateTime tglPesanan = DateTime.now();
                                                                                          String docId = DataServices.charFromDateTime(tglPesanan);

                                                                                          input['tglTransaksi'] = tglPesanan.toString();
                                                                                          input['idPesanan'] = idPesanan;
                                                                                          input['namaProduk'] = nama[i].text;
                                                                                          input['jumlahProduk'] = jumlah[i].text;
                                                                                          input['subTotal'] = subTotal[i].text;
                                                                                          input['jenisHarga'] = selectedHarga;
                                                                                          input['jenisMetode'] = selectedMetode;
                                                                                          input['jenisService'] = selectedService;
                                                                                          input['statusTempo'] = statusTempo;
                                                                                          input['statusAntar'] = statusAntar;
                                                                                          input['namaPelanggan'] = namaPembeli.text;
                                                                                          input['total'] = total;
                                                                                          if (selectedMetode == 'Tempo Cash' || selectedMetode == 'Tempo Transfer') {
                                                                                            if (int.parse(uangBayar.text) < int.parse(total)) {
                                                                                              input['utang'] = (int.parse(total) - int.parse(uangBayar.text)).toString();
                                                                                            } else {
                                                                                              input['utang'] = '0';
                                                                                              statusTempo = 'Lunas';
                                                                                            }
                                                                                          } else {
                                                                                            input['utang'] = jenis;
                                                                                          }
                                                                                          input['ongkir'] = ongkir.text;

                                                                                          List<String>? dataUser = await DataServices.readListPreferences('dataUser');
                                                                                          if (dataUser != null) {
                                                                                            input['namaKasir'] = dataUser[1];
                                                                                          }

                                                                                          var dataProduk = await DatabaseServices.readDataWithCondition('produk', 'namaProduk', nama[i].text);
                                                                                          var hasil = '';
                                                                                          if (dataProduk!['data'] != null) {
                                                                                            if (selectedHarga == 'DumpTruck') {
                                                                                              hasil = (double.parse(dataProduk['data'][0]['stokProduk']) - (double.parse(jumlah[i].text) * 7.1)).toString();
                                                                                            } else {
                                                                                              hasil = (double.parse(dataProduk['data'][0]['stokProduk']) - double.parse(jumlah[i].text)).toString();
                                                                                            }

                                                                                            Map<String, String> input2 = {};
                                                                                            input2['stokProduk'] = hasil;
                                                                                            input2['namaProduk'] = dataProduk['data'][0]['namaProduk'];
                                                                                            input2['hargaEceran'] = dataProduk['data'][0]['hargaEceran'];
                                                                                            input2['hargaDT'] = dataProduk['data'][0]['hargaDT'];

                                                                                            await DatabaseServices.updateDataWithDocId('produk', '${dataProduk['id'][0]}', input2);
                                                                                          }

                                                                                          dataPrint.add(input);
                                                                                          await DatabaseServices.createDataWithDocId('pesananSementara', docId, input);

                                                                                          await DataServices.deletePreferences('pesanan$i');
                                                                                        }

                                                                                        await DataServices.printStruk(dataPrint, namaPembeli.text, uangBayar.text, ongkir.text);

                                                                                        Navigator.of(context).pop();

                                                                                        nama.clear();
                                                                                        hargaSatuan.clear();
                                                                                        jumlah.clear();
                                                                                        subTotal.clear();
                                                                                        jumlahPesanan = 0;
                                                                                        ongkir.clear();
                                                                                        total = '0';
                                                                                        namaPembeli.clear();
                                                                                        uangBayar.text = '';
                                                                                        await DataServices.deletePreferences('jumlahPesanan');
                                                                                        await MessageService.showSnackBar(context, 'Berhasil diproses');

                                                                                        setState(() {});
                                                                                      } catch (e) {
                                                                                        print(e);
                                                                                      }
                                                                                    }
                                                                                  } else {
                                                                                    Navigator.of(context).pop();

                                                                                    await MessageService.showSnackBar(context, 'Gagal diproses');
                                                                                  }
                                                                                },
                                                                                icon: Icon(Icons.create),
                                                                                label: Text(
                                                                                  'PROSES',
                                                                                  style: TextStyle(
                                                                                    fontSize: 9.sp,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                              Navigator.of(context).pop();
                                                            }
                                                          },
                                                          icon: Icon(Icons.shopping_basket),
                                                          label: Text(
                                                            'PEMBAYARAN',
                                                            style: TextStyle(
                                                              fontSize: 9.sp,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Text('Pilih')),
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
                        icon: Icon(Icons.trolley),
                        label: Text('Order List'))
                  ],
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9.sp),
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
                                    bool check = false;
                                    int? jumlahPesanan = await DataServices.readIntPreferences('jumlahPesanan');

                                    if (jumlahPesanan == null) {
                                      await DataServices.createIntPreferences('jumlahPesanan', 1);

                                      List<String> data = [];
                                      data.add(documents[index].id);
                                      data.add(documents[index]['namaProduk']);
                                      data.add(documents[index]['hargaEceran']);
                                      data.add(documents[index]['hargaDT']);

                                      await DataServices.createListPreferences('pesanan0', data);
                                      await MessageService.showSnackBar(context, 'Produk berhasil masuk keranjang');
                                    } else {
                                      for (var i = 0; i < jumlahPesanan; i++) {
                                        List<String>? pesanan = await DataServices.readListPreferences('pesanan$i');
                                        if (pesanan?[1] == documents[index]['namaProduk']) {
                                          check = true;
                                        }
                                      }

                                      if (check == false) {
                                        List<String> data = [];
                                        data.add(documents[index].id);
                                        data.add(documents[index]['namaProduk']);
                                        data.add(documents[index]['hargaEceran']);
                                        data.add(documents[index]['hargaDT']);

                                        await DataServices.createListPreferences('pesanan${jumlahPesanan}', data);

                                        await DataServices.createIntPreferences('jumlahPesanan', jumlahPesanan + 1);
                                        await MessageService.showSnackBar(context, 'Produk berhasil masuk keranjang');
                                      } else {
                                        await MessageService.showSnackBar(context, 'Produk sudah ada');
                                      }
                                    }
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        child: Icon(dengarBarang ? Icons.mic : Icons.mic_off),
        onPressed: () async {
          await dengarinBarang().then(
            (value) async {
              await Future.delayed(Duration(seconds: 4));

              var dataProduk = await DatabaseServices.readDataWithCondition('produk', 'namaProduk', nilaiDengar.toLowerCase());
              if (dataProduk!['data'] != null) {
                bool check = false;
                int? jumlahPesanan = await DataServices.readIntPreferences('jumlahPesanan');

                if (jumlahPesanan == null) {
                  await DataServices.createIntPreferences('jumlahPesanan', 1);

                  List<String> data = [];
                  data.add(dataProduk['id'][0]);
                  data.add(dataProduk['data'][0]['namaProduk']);
                  data.add(dataProduk['data'][0]['hargaEceran']);
                  data.add(dataProduk['data'][0]['hargaDT']);

                  await DataServices.createListPreferences('pesanan0', data);
                  await MessageService.showSnackBar(context, 'Produk berhasil masuk keranjang');
                } else {
                  for (var i = 0; i < jumlahPesanan; i++) {
                    List<String>? pesanan = await DataServices.readListPreferences('pesanan$i');
                    if (pesanan?[1] == dataProduk['data'][0]['namaProduk']) {
                      check = true;
                    }
                  }

                  if (check == false) {
                    List<String> data = [];
                    data.add(dataProduk['id'][0]);
                    data.add(dataProduk['data'][0]['namaProduk']);
                    data.add(dataProduk['data'][0]['hargaEceran']);
                    data.add(dataProduk['data'][0]['hargaDT']);

                    await DataServices.createListPreferences('pesanan${jumlahPesanan}', data);

                    await DataServices.createIntPreferences('jumlahPesanan', jumlahPesanan + 1);
                    await MessageService.showSnackBar(context, 'Produk berhasil masuk keranjang');
                  } else {
                    await MessageService.showSnackBar(context, 'Produk sudah ada');
                  }
                }
              } else {
                await MessageService.showSnackBar(context, 'Produk tidak tersedia');
              }
            },
          );
        },
      ),
    );
  }
}
