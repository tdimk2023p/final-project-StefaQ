import 'package:flutter/material.dart';

class OtherServices {
  static DateTimeRange? hasil;
  static DateTimeRange? rangeTanggal;

  static Future<DateTimeRange?> showDateTimeRange(BuildContext context) async {
    hasil = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2010, 1, 1),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      initialDateRange: rangeTanggal,
      saveText: 'Pilih',
      builder: (context, child) {
        return Theme(
          child: child!,
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan, primary: Colors.cyan),
          ),
        );
      },
    );

    return hasil;
  }
}
