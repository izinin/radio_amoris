import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'amoris_model.dart';
import 'radiostations.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ScopedModel<AmorisModel>(
      model: new AmorisModel(),
      child: new MaterialApp(
        title: 'Radio Amoris',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new RadioStations(),
      )
    );
  }
}
