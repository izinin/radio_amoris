import 'dart:async';

import 'package:flutter/material.dart';
import 'audioctl.dart';
import 'listitem.dart';
import 'stationsdata.dart';
import 'shared_selection.dart';

class RadioStations extends StatefulWidget {

  RadioStations({ Key key }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new StationlistState();
  }
}

class StationlistState  extends State<RadioStations>{
  PlayerState _playerState = PlayerState.destroyed;
  List<Widget> _widgetArr;
  AudioCtl _playerCtl;
  int _selected = -1;
  Completer _completer;

  @override
  void initState() {
    super.initState();
    _playerCtl =  new AudioCtl(
            _onCreated,
            _onDestroying,
            _onPaused,
            _onResumed,
            _onError);
    initAmorisData();
  }

  @override
  void dispose() {
    _playerCtl.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = 'ANIMA AMORIS';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: SharedSelection(
          child: ListView(
                children: _widgetArr,
              ),
          playerstate: _playerCtl.state,
          uid: _selected,
          )
      ),
    );
  }

  void initAmorisData() {
    var keys = StationsData.keys;
    _widgetArr = new List<Widget>(keys.length * 2);
    for(var i=0; i < _widgetArr.length; i += 2){
      int uid = keys.elementAt(i ~/ 2);
      var item = StationsData[uid];
      _widgetArr[i] = new Station(_playerCtl, uid, item['descr'], item['url'],
      itemSelectedCallback: (uid){
        setState(() {
            _selected = uid;
          });
      });
      _widgetArr[i+1] = new Divider();
    }
  }

  _onCreated() {
    setState(() {
      _playerState = PlayerState.created;
    });
  }

  _onError() {
    print("error received");
    _completer.completeError(null);
  }

  _onDestroying() {
    _playerState = PlayerState.destroyed;
  }

  _onPaused(){
    if (_playerState == PlayerState.paused) {
      // TODO: fix parameters!
      _playerCtl.create(_selected);
      _playerCtl.resume();
    } else {
      setState(() {
        _playerState = PlayerState.paused;
      });
    }
  }

  _onResumed() {
    setState(() {
      _playerState = PlayerState.playing;
    });
  }
}
