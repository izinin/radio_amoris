import 'package:flutter/material.dart';
import 'package:radio_amoris/radiostations.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Radio Amoris',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RadioStations(),
    );
  }
}
