import 'package:flutter/material.dart';
import 'package:aplikasispeechtotext/widget/kasReportWidget.dart';
import 'package:aplikasispeechtotext/widget/lossReportWidget.dart';
import 'package:aplikasispeechtotext/widget/salesReportWidget.dart';

class ReportWidget extends StatefulWidget {
  const ReportWidget({super.key});

  @override
  State<ReportWidget> createState() => _ReportWidgetState();
}

class _ReportWidgetState extends State<ReportWidget> {
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
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(
                      icon: Icon(
                        Icons.book_outlined,
                        color: Colors.green,
                      ),
                      child: Text(
                        'Laporan Jual',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.book_outlined,
                        color: Colors.orange,
                      ),
                      child: Text(
                        'Laporan Kas',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.book_outlined,
                        color: Colors.red,
                      ),
                      child: Text(
                        'Laporan Beban',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  flex: 1,
                  child: TabBarView(
                    children: [
                      SalesReportWidget(),
                      KasReportWidget(),
                      LossReportWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
