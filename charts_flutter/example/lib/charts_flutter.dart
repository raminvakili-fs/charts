import 'package:example/simple.dart';
import 'package:flutter/material.dart';

class ChartsFlutterPage extends StatefulWidget {
  @override
  _ChartsFlutterPageState createState() => _ChartsFlutterPageState();
}

class _ChartsFlutterPageState extends State<ChartsFlutterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Charts Flutter'),),
      body: SimpleLineChart(),
    );
  }
}
