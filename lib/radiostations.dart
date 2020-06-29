import 'package:flutter/material.dart';
import 'config.dart';
import 'listitem.dart';

class RadioStations extends StatefulWidget {
  final Config data;

  RadioStations(this.data, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new StationlistState();
  }
}

class StationlistState extends State<RadioStations> {
  List<Widget> _widgetArr;

  @override
  void initState() {
    super.initState();
    initAmorisData();
  }

  @override
  Widget build(BuildContext context) {
    final title = 'ANIMA AMORIS';
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: ListView(
          children: _widgetArr,
        ));
  }

  void initAmorisData() {
    _widgetArr = new List<Widget>(widget.data.channels.length * 2);
    for (var i = 0; i < _widgetArr.length; i += 2) {
      var idx = i ~/ 2;
      var item = widget.data.channels[idx];
      _widgetArr[i] = new Station(idx, item);
      _widgetArr[i + 1] = new Divider();
    }
  }
}
