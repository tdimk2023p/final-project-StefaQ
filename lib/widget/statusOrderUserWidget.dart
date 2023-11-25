import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aplikasispeechtotext/widget/orderDeliveryUserWidget.dart';
import 'package:aplikasispeechtotext/widget/orderFinishUserWidget.dart';
import 'package:aplikasispeechtotext/widget/orderTempoUserWidget.dart';

class StatusOrderUserWidget extends StatefulWidget {
  const StatusOrderUserWidget({super.key});

  @override
  State<StatusOrderUserWidget> createState() => _StatusOrderUserWidgetState();
}

class _StatusOrderUserWidgetState extends State<StatusOrderUserWidget> {
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
                        Icons.drive_eta_outlined,
                        color: Colors.orange,
                      ),
                      child: Text(
                        'Pesanan\nAntar',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.warning_amber,
                        color: Colors.red,
                      ),
                      child: Text(
                        'Pesanan\nTempo',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.done_outline,
                        color: Colors.green,
                      ),
                      child: Text(
                        'Pesanan\nSelesai',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  flex: 1,
                  child: TabBarView(
                    children: [
                      OrderDeliveryUserWidget(),
                      OrderTempoUserWidget(),
                      OrderFinishUserWidget(),
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
