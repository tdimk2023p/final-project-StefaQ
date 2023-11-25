import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:aplikasispeechtotext/screen/adminHomeScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class DataServices {
  static Future<void> createListPreferences(String key, List<String> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setStringList(key, data);
  }

  static Future<void> createIntPreferences(String key, int data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt(key, data);
  }

  static Future<List<String>?> readListPreferences(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(data);
  }

  static Future<int?> readIntPreferences(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt(data);
  }

  static Future<void> deletePreferences(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(data);
  }

  static Future<void> deleteListOrderPreferences(String index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? jumlahPesanan = await DataServices.readIntPreferences('jumlahPesanan');
    List<List<String>?> dataPesanan = [];
    for (var i = 0; i < jumlahPesanan!; i++) {
      dataPesanan.add(await DataServices.readListPreferences('pesanan$i'));
      await DataServices.deletePreferences('pesanan$i');
    }

    dataPesanan.removeAt(int.parse(index));
    jumlahPesanan = jumlahPesanan - 1;

    for (var i = 0; i < jumlahPesanan; i++) {
      await DataServices.createListPreferences('pesanan$i', dataPesanan[i]!);
    }

    await DataServices.createIntPreferences('jumlahPesanan', jumlahPesanan);
  }

  //buat random char 20 karakter
  static String randomChar() {
    String uuid;

    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

    uuid = getRandomString(20);
    return uuid;
  }

  static String charFromDateTime(DateTime tanggal) {
    String char = '';
    String tahun = tanggal.toString().substring(0, 4);
    String bulan = tanggal.toString().substring(5, 7);
    String hari = tanggal.toString().substring(8, 10);
    String jam = tanggal.toString().substring(11, 13);
    String menit = tanggal.toString().substring(14, 16);
    String detik = tanggal.toString().substring(17, 19);
    String milidetik = tanggal.toString().substring(20, 26);

    char = 'JCO' + tahun + bulan + hari + jam + menit + detik + milidetik;

    return char;
  }

  static Future<void> printLaporan(PdfPage page, Size pageSize, PdfGrid grid, Map data, String jenis, String tglStart, String tglEnd) async {
    if (data.isEmpty) {
      return;
    }

    page.graphics.drawString("PANGKALAN BATU\nDesa Kapur", PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold), bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height), format: PdfStringFormat(alignment: PdfTextAlignment.center));
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), dashStyle: PdfDashStyle.solid), const Offset(0, 40), Offset(pageSize.width, 40));
    page.graphics.drawString("LAPORAN $jenis", PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold), bounds: Rect.fromLTWH(0, 50, pageSize.width, pageSize.height), format: PdfStringFormat(alignment: PdfTextAlignment.center));
    page.graphics.drawString("$tglStart - $tglEnd", PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular), bounds: Rect.fromLTWH(0, 70, pageSize.width, pageSize.height), format: PdfStringFormat(alignment: PdfTextAlignment.center));

    if (jenis == 'BEBAN') {
      grid.columns.add(count: 4);
      grid.headers.add(1);
      PdfGridRow header = grid.headers[0];

      for (var i = 0; i < 4; i++) {
        header.cells[i].style.backgroundBrush = PdfBrushes.cyan;
        header.cells[i].style.textBrush = PdfBrushes.black;
        header.cells[i].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
        header.cells[i].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      }

      header.cells[0].value = 'Tanggal';
      header.cells[1].value = 'Deskripsi';
      header.cells[2].value = 'Nama Kasir';
      header.cells[3].value = 'Total';

      PdfGridRow row;
      int total = 0;
      for (var i = 0; i < data['data'].length; i++) {
        row = grid.rows.add();
        row.cells[0].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[0].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[0].value = data['data'][i]['tglTransaksi'].toString().substring(0, 19);
        row.cells[1].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[1].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[1].value = data['data'][i]['deskripsi'];
        row.cells[2].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[2].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[2].value = data['data'][i]['namaKasir'];
        row.cells[3].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[3].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[3].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(data['data'][0]['total']));
        total = total + int.parse(data['data'][0]['total']);
      }

      row = grid.rows.add();
      row.cells[0].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      row.cells[0].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[0].value = '';
      row.cells[1].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      row.cells[1].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[1].value = '';
      row.cells[2].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
      row.cells[2].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[2].value = 'Total';
      row.cells[3].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
      row.cells[3].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[3].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(total);
    } else if (jenis == 'PENJUALAN') {
      grid.columns.add(count: 12);
      grid.headers.add(1);
      PdfGridRow header = grid.headers[0];

      for (var i = 0; i < 12; i++) {
        header.cells[i].style.backgroundBrush = PdfBrushes.cyan;
        header.cells[i].style.textBrush = PdfBrushes.black;
        header.cells[i].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
        header.cells[i].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      }

      header.cells[0].value = 'Tanggal';
      header.cells[1].value = 'Id Pesanan';
      header.cells[2].value = 'Pelanggan';
      header.cells[3].value = 'Produk';
      header.cells[4].value = 'Jumlah';
      header.cells[5].value = 'Ongkir';
      header.cells[6].value = 'Sub Total';
      header.cells[7].value = 'Total';
      header.cells[8].value = 'Harga';
      header.cells[9].value = 'Service';
      header.cells[10].value = 'Metode';
      header.cells[11].value = 'Nama Kasir';

      PdfGridRow row;
      int total = 0;
      for (var i = 0; i < data['data'].length; i++) {
        row = grid.rows.add();
        row.cells[0].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[0].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[0].value = data['data'][i]['tglTransaksi'].toString().substring(0, 19);
        row.cells[1].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[1].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[1].value = data['data'][i]['idPesanan'];
        row.cells[2].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[2].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[2].value = data['data'][i]['namaPelanggan'];
        row.cells[3].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[3].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[3].value = data['data'][i]['namaProduk'];
        row.cells[4].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[4].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[4].value = data['data'][i]['jumlahProduk'];
        row.cells[5].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[5].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[5].value = data['data'][i]['ongkir'];
        row.cells[6].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[6].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[6].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(data['data'][i]['subTotal']));
        row.cells[7].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[7].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[7].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(data['data'][i]['total']));
        row.cells[8].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[8].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[8].value = data['data'][i]['jenisHarga'];
        row.cells[9].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[9].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[9].value = data['data'][i]['jenisService'];
        row.cells[10].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[10].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[10].value = data['data'][i]['jenisMetode'];
        row.cells[11].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[11].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[11].value = data['data'][i]['namaKasir'];
        //
        total = total + int.parse(data['data'][0]['total']);
      }

      // row = grid.rows.add();
      // row.cells[0].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      // row.cells[0].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      // row.cells[0].value = '';
      // row.cells[1].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      // row.cells[1].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      // row.cells[1].value = '';
      // row.cells[2].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
      // row.cells[2].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      // row.cells[2].value = 'Total';
      // row.cells[3].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
      // row.cells[3].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
      // row.cells[3].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(total);
    } else if (jenis == 'KAS') {
      grid.columns.add(count: 5);
      grid.headers.add(1);
      PdfGridRow header = grid.headers[0];

      for (var i = 0; i < 5; i++) {
        header.cells[i].style.backgroundBrush = PdfBrushes.cyan;
        header.cells[i].style.textBrush = PdfBrushes.black;
        header.cells[i].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
        header.cells[i].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      }

      header.cells[0].value = 'Tanggal';
      header.cells[1].value = 'Deskripsi';
      header.cells[2].value = 'Status Kas';
      header.cells[3].value = 'Nama Kasir';
      header.cells[4].value = 'Total';

      PdfGridRow row;
      int total = 0;
      for (var i = 0; i < data['data'].length; i++) {
        row = grid.rows.add();
        row.cells[0].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[0].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[0].value = data['data'][i]['tglTransaksi'].toString().substring(0, 19);
        row.cells[1].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[1].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[1].value = data['data'][i]['deskripsi'];
        row.cells[2].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[2].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[2].value = data['data'][i]['statusKas'];
        row.cells[3].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[3].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[3].value = data['data'][i]['namaKasir'];
        row.cells[4].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
        row.cells[4].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
        row.cells[4].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(data['data'][0]['total']));

        if (data['data'][i]['statusKas'] == 'pemasukan') {
          total = total + int.parse(data['data'][0]['total']);
        } else if (data['data'][i]['statusKas'] == 'pengeluaran') {
          total = total - int.parse(data['data'][0]['total']);
        }
      }

      row = grid.rows.add();
      row.cells[0].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      row.cells[0].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[0].value = '';
      row.cells[1].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      row.cells[1].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[1].value = '';
      row.cells[2].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      row.cells[2].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[2].value = '';
      row.cells[3].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
      row.cells[3].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[3].value = 'Total';
      row.cells[4].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
      row.cells[4].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[4].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(total);
    }

    grid.style = PdfGridStyle(cellPadding: PdfPaddings(left: 2, right: 3, top: 4, bottom: 5), font: PdfStandardFont(PdfFontFamily.helvetica, 12));
    grid.draw(page: page, bounds: Rect.fromLTWH(0, 100, pageSize.width, pageSize.height));
  }

  static Future<void> printNotaSemuaTagihan(PdfPage page, Size pageSize, PdfGrid grid, Map data, String jenis, tglStart, tglEnd) async {
    if (data.isEmpty) {
      return;
    }

    // String tanggalLaporan = '';
    double ukuran = 0;
    double ukuranBaris = 35;
    // tanggalLaporan = DateFormat('dd/MM/yyyy').format(DateTime.now()).split(' ')[0];

    page.graphics.drawString("PANGKALAN BATU\nDesa Kapur", PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold), bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height), format: PdfStringFormat(alignment: PdfTextAlignment.center));
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), dashStyle: PdfDashStyle.solid), const Offset(0, 40), Offset(pageSize.width, 40));
    page.graphics.drawString("TAGIHAN PERIODE $tglStart - $tglEnd", PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold), bounds: Rect.fromLTWH(0, 50, pageSize.width, pageSize.height), format: PdfStringFormat(alignment: PdfTextAlignment.center));
    page.graphics.drawString("${data['data'][0]['namaPelanggan'].toString().toUpperCase()}", PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold), bounds: Rect.fromLTWH(0, 70, pageSize.width, pageSize.height), format: PdfStringFormat(alignment: PdfTextAlignment.left));
    ukuran = ukuran + 95;
    grid.columns.add(count: 6);
    grid.headers.add(1);
    PdfGridRow header = grid.headers[0];
    for (var i = 0; i < 6; i++) {
      header.cells[i].style.backgroundBrush = PdfBrushes.cyan;
      header.cells[i].style.textBrush = PdfBrushes.black;
      header.cells[i].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
      header.cells[i].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    }

    header.cells[0].value = 'Tanggal';
    header.cells[1].value = 'ID Pesanan';
    header.cells[2].value = 'Nama Produk';
    header.cells[3].value = 'Jumlah Produk';
    header.cells[4].value = 'Harga Satuan';
    header.cells[5].value = 'Sub Total';

    PdfGridRow row;
    var total = 0;
    var sisaTempo = 0;
    var ongkir = 0;
    for (var i = 0; i < data['data'].length; i++) {
      row = grid.rows.add();
      row.cells[0].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      row.cells[0].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      if (i > 0) {
        if (data['data'][i]['idPesanan'] == data['data'][i - 1]['idPesanan']) {
          row.cells[0].value = '';
        } else {
          row.cells[0].value = data['data'][i]['tglTransaksi'].toString().substring(0, 10);
        }
      } else {
        row.cells[0].value = data['data'][i]['tglTransaksi'].toString().substring(0, 10);
      }
      row.cells[1].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      row.cells[1].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);

      if (i > 0) {
        if (data['data'][i]['idPesanan'] == data['data'][i - 1]['idPesanan']) {
          row.cells[1].value = '';
        } else {
          row.cells[1].value = data['data'][i]['idPesanan'];
        }
      } else {
        row.cells[1].value = data['data'][i]['idPesanan'];
      }
      row.cells[2].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      row.cells[2].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[2].value = data['data'][i]['namaProduk'];
      row.cells[3].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      row.cells[3].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[3].value = data['data'][i]['jumlahProduk'];
      row.cells[4].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      row.cells[4].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[4].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(double.parse(data['data'][i]['subTotal']) / double.parse(data['data'][i]['jumlahProduk']));
      row.cells[5].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      row.cells[5].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[5].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(data['data'][i]['subTotal']));

      total = total + int.parse(data['data'][i]['subTotal']);

      if (i > 0) {
        if (data['data'][i]['idPesanan'] == data['data'][i - 1]['idPesanan']) {
          sisaTempo = sisaTempo + 0;
          ongkir = ongkir + 0;
        } else {
          sisaTempo = sisaTempo + int.parse(data['data'][i]['utang']);
          ongkir = ongkir + int.parse(data['data'][i]['ongkir']);
        }
      } else {
        sisaTempo = sisaTempo + int.parse(data['data'][i]['utang']);
        ongkir = ongkir + int.parse(data['data'][i]['ongkir']);
      }
    }

    row = grid.rows.add();
    row.cells[0].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
    row.cells[0].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[0].value = '';
    row.cells[1].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
    row.cells[1].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[1].value = '';
    row.cells[2].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    row.cells[2].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[3].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    row.cells[3].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[4].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
    row.cells[4].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[4].value = 'Ongkos Kirim';
    row.cells[5].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
    row.cells[5].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[5].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(ongkir);

    row = grid.rows.add();
    row.cells[0].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
    row.cells[0].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[0].value = '';
    row.cells[1].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
    row.cells[1].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[1].value = '';
    row.cells[2].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    row.cells[2].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[3].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    row.cells[3].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[4].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    row.cells[4].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[4].value = 'Total';
    row.cells[5].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    row.cells[5].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[5].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(total + ongkir);

    row = grid.rows.add();
    row.cells[0].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
    row.cells[0].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[0].value = '';
    row.cells[1].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
    row.cells[1].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[1].value = '';
    row.cells[2].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    row.cells[2].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[3].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    row.cells[3].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[4].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    row.cells[4].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[4].value = 'Sisa Tempo';
    row.cells[5].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    row.cells[5].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[5].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(sisaTempo);

    ukuran = ukuran + (ukuranBaris * (data['data'].length + 3));

    page.graphics.drawString("Tanda Terima", PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold), bounds: Rect.fromLTWH(30, ukuran, pageSize.width, pageSize.height), format: PdfStringFormat(alignment: PdfTextAlignment.left));
    page.graphics.drawString("Hormat Kami,", PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold), bounds: Rect.fromLTWH(-30, ukuran, pageSize.width, pageSize.height), format: PdfStringFormat(alignment: PdfTextAlignment.right));

    grid.style = PdfGridStyle(cellPadding: PdfPaddings(left: 2, right: 3, top: 4, bottom: 5), font: PdfStandardFont(PdfFontFamily.helvetica, 12));
    grid.draw(page: page, bounds: Rect.fromLTWH(0, 100, pageSize.width, pageSize.height));
  }

  static Future<void> printNotaTagihan(PdfPage page, Size pageSize, PdfGrid grid, Map data, String jenis) async {
    if (data.isEmpty) {
      return;
    }

    String tanggalLaporan = '';
    double ukuran = 0;
    double ukuranBaris = 35;
    tanggalLaporan = DateFormat('dd/MM/yyyy').format(DateTime.now()).split(' ')[0];

    page.graphics.drawString("PANGKALAN BATU\nDesa Kapur", PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold), bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height), format: PdfStringFormat(alignment: PdfTextAlignment.center));
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), dashStyle: PdfDashStyle.solid), const Offset(0, 40), Offset(pageSize.width, 40));
    page.graphics.drawString("Tanggal     : $tanggalLaporan", PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold), bounds: Rect.fromLTWH(0, 50, pageSize.width, pageSize.height), format: PdfStringFormat(alignment: PdfTextAlignment.left));
    page.graphics.drawString("ID ORDER : ${data['data'][0]['idPesanan']} [$jenis]", PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold), bounds: Rect.fromLTWH(0, 70, pageSize.width, pageSize.height), format: PdfStringFormat(alignment: PdfTextAlignment.left));
    ukuran = ukuran + 95;
    grid.columns.add(count: 4);
    grid.headers.add(1);
    PdfGridRow header = grid.headers[0];
    for (var i = 0; i < 4; i++) {
      header.cells[i].style.backgroundBrush = PdfBrushes.cyan;
      header.cells[i].style.textBrush = PdfBrushes.black;
      header.cells[i].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
      header.cells[i].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    }

    header.cells[0].value = 'Nama Produk';
    header.cells[1].value = 'Jumlah Produk';
    header.cells[2].value = 'Harga Satuan';
    header.cells[3].value = 'Sub Total';

    PdfGridRow row;
    for (var i = 0; i < data['data'].length; i++) {
      row = grid.rows.add();
      row.cells[0].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      row.cells[0].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[0].value = data['data'][i]['namaProduk'];
      row.cells[1].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      row.cells[1].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[1].value = data['data'][i]['jumlahProduk'];
      row.cells[2].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      row.cells[2].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[2].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(double.parse(data['data'][i]['subTotal']) / double.parse(data['data'][i]['jumlahProduk']));
      row.cells[3].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
      row.cells[3].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
      row.cells[3].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(data['data'][i]['subTotal']));
    }

    row = grid.rows.add();
    row.cells[0].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
    row.cells[0].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[0].value = '';
    row.cells[1].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
    row.cells[1].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[1].value = '';
    row.cells[2].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
    row.cells[2].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[2].value = 'Ongkos Kirim';
    row.cells[3].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
    row.cells[3].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[3].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(data['data'][0]['ongkir']));

    row = grid.rows.add();
    row.cells[0].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
    row.cells[0].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[0].value = '';
    row.cells[1].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
    row.cells[1].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[1].value = '';
    row.cells[2].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    row.cells[2].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[2].value = 'Total';
    row.cells[3].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    row.cells[3].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[3].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(data['data'][0]['total']));

    row = grid.rows.add();
    row.cells[0].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
    row.cells[0].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[0].value = '';
    row.cells[1].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);
    row.cells[1].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[1].value = '';
    row.cells[2].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    row.cells[2].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[2].value = 'Sisa Tempo';
    row.cells[3].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    row.cells[3].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, lineAlignment: PdfVerticalAlignment.middle);
    row.cells[3].value = NumberFormat.simpleCurrency(locale: 'id-ID').format(int.parse(data['data'][0]['utang']));

    ukuran = ukuran + (ukuranBaris * (data['data'].length + 3));

    page.graphics.drawString("Tanda Terima", PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold), bounds: Rect.fromLTWH(30, ukuran, pageSize.width, pageSize.height), format: PdfStringFormat(alignment: PdfTextAlignment.left));
    page.graphics.drawString("Hormat Kami,", PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold), bounds: Rect.fromLTWH(-30, ukuran, pageSize.width, pageSize.height), format: PdfStringFormat(alignment: PdfTextAlignment.right));

    grid.style = PdfGridStyle(cellPadding: PdfPaddings(left: 2, right: 3, top: 4, bottom: 5), font: PdfStandardFont(PdfFontFamily.helvetica, 12));
    grid.draw(page: page, bounds: Rect.fromLTWH(0, 100, pageSize.width, pageSize.height));
  }

  static Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
    final path = (await getExternalStorageDirectory())?.path;
    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open("$path/$fileName");
  }

  static Future<void> createPDF(Map data, String jenis, String jenisNota, String tglStart, String tglEnd) async {
    PdfDocument document = PdfDocument();
    if (jenisNota == 'tagihan') {
      document.pageSettings.orientation = PdfPageOrientation.portrait;
    } else if (jenisNota == 'laporan') {
      document.pageSettings.orientation = PdfPageOrientation.landscape;
    } else if (jenisNota == 'totaltagihan') {
      document.pageSettings.orientation = PdfPageOrientation.landscape;
    }
    document.pageSettings.margins.all = 30;
    final PdfPage page = document.pages.add();
    final Size pageSize = page.getClientSize();
    final PdfGrid grid = PdfGrid();
    final PdfPageTemplateElement headerTemplate = PdfPageTemplateElement(const Rect.fromLTWH(0, 0, 515, 50));
//Draw text in the header.
//Add the header element to the document.
    document.template.top = headerTemplate;
    //Draw the header section by creating text element
    if (jenisNota == 'tagihan') {
      await printNotaTagihan(page, pageSize, grid, data, jenis);
    } else if (jenisNota == 'laporan') {
      await printLaporan(page, pageSize, grid, data, jenis, tglStart, tglEnd);
    } else if (jenisNota == 'totaltagihan') {
      await printNotaSemuaTagihan(page, pageSize, grid, data, jenis, tglStart, tglEnd);
      tglStart = '';
      tglEnd = '';
    }

    //Save the PDF document
    final List<int> bytes = document.saveSync();
    document.dispose();
    var nama = jenisNota + jenis.toLowerCase() + tglStart.toString() + tglEnd.toString();
    saveAndLaunchFile(bytes, '$nama.pdf');
  }

  static Future<void> printStruk(List input, String namaPembeli, String uangBayar, String ongkir) async {
    int total = 0;

    bluetooth.isConnected.then((isConnected) async {
      if (isConnected!) {
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        // ByteData bytesAssetLogoName = await rootBundle.load("assets/icons/logo.png");
        // Uint8List imageBytesFromAssetLogoName = bytesAssetLogoName.buffer.asUint8List(bytesAssetLogoName.offsetInBytes, bytesAssetLogoName.lengthInBytes);

        // bluetooth.printImageBytes(imageBytesFromAssetLogoName);
        bluetooth.printCustom("Pangkalan Batu", 3, 1);
        bluetooth.printCustom("Desa Kapur", 1, 1);
        bluetooth.printNewLine();
        bluetooth.printLeftRight('', 'id: ${input[0]['idPesanan'].toString()}', 0);
        bluetooth.printCustom("--------------------------------", 0, 1);
        bluetooth.printLeftRight('', input[0]['tglTransaksi'].toString().substring(0, 19), 0);
        bluetooth.printNewLine();
        bluetooth.printLeftRight('Pelanggan  :', '${input[0]['namaPelanggan']}', 0);
        bluetooth.printLeftRight('Nama Kasir :', '${input[0]['namaKasir']}', 0);

        bluetooth.printCustom("--------------------------------", 0, 1);
        for (var i = 0; i < input.length; i++) {
          String hargasatuan = (double.parse(input[i]['subTotal']) / double.parse(input[i]['jumlahProduk'])).toString();
          bluetooth.printLeftRight('${i + 1}. ${input[i]['namaProduk']}', '', 0);
          if (input[i]['jenisHarga'] == 'Eceran' || input[i]['jenisHarga'] == 'Manual') {
            bluetooth.printLeftRight('   @${input[i]['jumlahProduk']} (m3) x $hargasatuan', '${input[i]['subTotal']}', 0);
          } else {
            bluetooth.printLeftRight('   @${input[i]['jumlahProduk']} (DumpTruck) x $hargasatuan', '${input[i]['subTotal']}', 0);
          }
        }
        bluetooth.printCustom("--------------------------------", 0, 1);
        bluetooth.printLeftRight('Ongkos Kirim :', ongkir, 0);
        bluetooth.printLeftRight('Total Harga  :', '${input[0]['total']}', 0);
        bluetooth.printLeftRight('Total Bayar  :', uangBayar, 0);
        if (input[0]['jenisMetode'] == 'Cash' || input[0]['jenisMetode'] == 'Transfer Bank') {
          bluetooth.printLeftRight('Uang Kembali :', '${int.parse(uangBayar) - int.parse(input[0]['total'])}', 0);
        }
        bluetooth.printCustom("--------------------------------", 0, 1);
        if (input[0]['jenisMetode'] == 'Tempo Cash' || input[0]['jenisMetode'] == 'Tempo Transfer') {
          bluetooth.printLeftRight('Sisa   Tempo :', '${input[0]['utang']}', 0);
        }

        bluetooth.printNewLine();
        bluetooth.printCustom("*** TERIMA KASIH ***", 0, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("--------------------------------", 0, 1);
        bluetooth.printCustom("Supported by Joses Corp.", 0, 1);
        bluetooth.printCustom("--------------------------------", 0, 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();

        bluetooth.printNewLine();
        bluetooth.printCustom("List pesanan :", 0, 0);

        bluetooth.printNewLine();
        bluetooth.printLeftRight('', 'id: ${input[0]['idPesanan'].toString()}', 0);
        bluetooth.printCustom("--------------------------------", 0, 1);
        bluetooth.printLeftRight('', input[0]['tglTransaksi'].toString().substring(0, 19), 0);
        bluetooth.printNewLine();
        bluetooth.printLeftRight('Pelanggan  :', '${input[0]['namaPelanggan']}', 0);
        bluetooth.printLeftRight('Nama Kasir :', '${input[0]['namaKasir']}', 0);

        bluetooth.printCustom("--------------------------------", 0, 1);
        for (var i = 0; i < input.length; i++) {
          // String hargasatuan = (int.parse(input[i]['subTotal']) / int.parse(input[i]['jumlahProduk'])).toString();
          bluetooth.printLeftRight('${i + 1}. ${input[i]['namaProduk']}', '', 0);
          if (input[i]['jenisHarga'] == 'Eceran' || input[i]['jenisHarga'] == 'Manual') {
            bluetooth.printLeftRight('   @${input[i]['jumlahProduk']} (m3) ', '', 0);
          } else {
            bluetooth.printLeftRight('   @${input[i]['jumlahProduk']} (DumpTruck)', '', 0);
          }
        }
        bluetooth.printCustom("--------------------------------", 0, 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();

        bluetooth.printNewLine();
        bluetooth.printCustom("List pesanan :", 0, 0);

        // ByteData bytesAssetLogoName = await rootBundle.load("assets/icons/logo.png");
        // Uint8List imageBytesFromAssetLogoName = bytesAssetLogoName.buffer.asUint8List(bytesAssetLogoName.offsetInBytes, bytesAssetLogoName.lengthInBytes);

        // bluetooth.printImageBytes(imageBytesFromAssetLogoName);
        // bluetooth.printCustom("Pangkalan Batu", 3, 1);
        // bluetooth.printCustom("Desa Kapur", 1, 1);
        bluetooth.printNewLine();
        bluetooth.printLeftRight('', 'id: ${input[0]['idPesanan'].toString()}', 0);
        bluetooth.printCustom("--------------------------------", 0, 1);
        bluetooth.printLeftRight('', input[0]['tglTransaksi'].toString().substring(0, 19), 0);
        bluetooth.printNewLine();
        bluetooth.printLeftRight('Pelanggan  :', '${input[0]['namaPelanggan']}', 0);
        bluetooth.printLeftRight('Nama Kasir :', '${input[0]['namaKasir']}', 0);

        bluetooth.printCustom("--------------------------------", 0, 1);
        for (var i = 0; i < input.length; i++) {
          // String hargasatuan = (int.parse(input[i]['subTotal']) / int.parse(input[i]['jumlahProduk'])).toString();
          bluetooth.printLeftRight('${i + 1}. ${input[i]['namaProduk']}', '', 0);
          if (input[i]['jenisHarga'] == 'Eceran' || input[i]['jenisHarga'] == 'Manual') {
            bluetooth.printLeftRight('   @${input[i]['jumlahProduk']} (m3) ', '', 0);
          } else {
            bluetooth.printLeftRight('   @${input[i]['jumlahProduk']} (DumpTruck)', '', 0);
          }
        }
        bluetooth.printCustom("--------------------------------", 0, 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
      }
    });
  }
}
