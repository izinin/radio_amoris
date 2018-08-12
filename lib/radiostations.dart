import 'package:flutter/material.dart';
import 'package:radio_amoris/listitem.dart';
import 'package:radio_amoris/stationsdata.dart';

class RadioStations extends StatefulWidget {

  RadioStations({ Key key }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new StationlistState();
  }
}

class StationlistState  extends State<RadioStations>{
  List<Widget> _widgetArr;

  @override
  void initState() {
    super.initState();
    var keys = StationsData.keys;
    _widgetArr = new List<Widget>(keys.length * 2);
    for(var i=0; i < _widgetArr.length; i += 2){
      var item = StationsData[keys.elementAt(i ~/ 2)];
      _widgetArr[i] = new Station(item['descr'], 'implementme');
      _widgetArr[i+1] = new Divider();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Basic List';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: ListView(
          children: _widgetArr,
        ),
      ),
    );
  }
}
