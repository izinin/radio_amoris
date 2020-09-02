import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'amoris_model.dart';
import 'radiostations.dart';
import 'appdata.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ScopedModel<AmorisModel>(
        model: new AmorisModel(),
        child: new MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Radio Amoris',
            theme: new ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: Center(
              child: FutureBuilder(
                future: appData.fetchConfig(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return new RadioStations(snapshot.data);
                  } else if (snapshot.hasError) {
                    return new Text("${snapshot.error}");
                  }
                  // By default, show a loading spinner
                  return new CircularProgressIndicator();
                },
              ),
            )));
  }
}
