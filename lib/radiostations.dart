
import 'package:flutter/material.dart';
import 'listitem.dart';
import 'stationsdata.dart';

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
            )
      );
  }

  void initAmorisData() {
    var keys = StationsData.keys;
    _widgetArr = new List<Widget>(keys.length * 2);
    for(var i=0; i < _widgetArr.length; i += 2){
      int uid = keys.elementAt(i ~/ 2);
      var item = StationsData[uid];
      _widgetArr[i] = new Station(uid, item['descr'], item['url']);
      _widgetArr[i+1] = new Divider();
    }
  }
}
