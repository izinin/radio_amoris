import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:radio_amoris/amoris_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'audioctl.dart';
import 'dart:convert';

class Station extends StatefulWidget{
  final String _descr;
  final String _baseUrl;
  final AudioCtl _playerCtl;
  final int _uid;
  final ValueChanged<int> itemSelectedCallback;

  Station(this._playerCtl, this._uid, this._descr, this._baseUrl, {
      @required this.itemSelectedCallback });

  @override
  State<StatefulWidget> createState() {
    return new StationState();
  }
}

class StationState extends State<Station>{
  bool _selected = false;
  var _client = new http.Client();
  bool _allowhttp = true;
  String _lastsongtitle = '...';

  Future<ChanInfo> _fetchChanInfo() async {
    final response = await _client.get(widget._baseUrl + '/stats.json',
      headers: {
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36'
      }
    );
    _allowhttp = false;
    if (response.statusCode == 200) {
      new Timer(const Duration(seconds: 30), ()=> _allowhttp = true);
      return ChanInfo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load channel info');
    }
  }
    
  @override
  Widget build(BuildContext context) {
    return new ScopedModelDescendant<AmorisModel>(
      builder: (context, child, model) => new ListTile(  // sharedSel ----> FIXME! Text('${model.counter}'),
        leading: _getIgon(sharedSel),
        title: Text(widget._descr),
        subtitle: _allowhttp ? FutureBuilder<ChanInfo>(
          future: _fetchChanInfo(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _lastsongtitle = '${snapshot.data.songtitle} \nlisteners: ${snapshot.data.uniquelisteners}';
              return Text(_lastsongtitle);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner
            return Text('...');
          },
        ) : Text(_lastsongtitle),
        isThreeLine: true,
        onTap: (){
          widget.itemSelectedCallback(widget._uid);
          setState(() { 
            _selected = (sharedSel.uid == widget._uid);
          });
          if(_isSelected(sharedSel.uid)){
            if (PlayerState.paused == sharedSel.playerstate) {
              widget._playerCtl.playerState = PlayerState.inprogress;
              widget._playerCtl.create(widget._uid);
              widget._playerCtl.resume();
            } else {
              widget._playerCtl.pause();
            }
          }else if (PlayerState.playing == sharedSel.playerstate){
            widget._playerCtl.pause();
          }
        },
        selected: _isSelected(sharedSel.uid)
      )
    );
  }

  bool _isSelected(int uid){
    return (uid == -1 || uid == widget._uid) && _selected;
  }

  _getIgon(SharedSelection sharedSel) {
    var icondata = Icons.play_circle_outline;
    if(_isSelected(sharedSel.uid)) {
      switch(sharedSel.playerstate){
        case PlayerState.destroyed:
        case PlayerState.created:
        case PlayerState.paused:
          icondata = Icons.pause_circle_outline;
          break;
        case PlayerState.playing:
          icondata = Icons.play_circle_outline;
          break;
        case PlayerState.inprogress:
          icondata = Icons.loop;
          break;
      }
    }
    return new Icon(icondata);
  }
}

class ChanInfo {
  final int uniquelisteners;
  final String songtitle;

  ChanInfo({this.uniquelisteners, this.songtitle});

  factory ChanInfo.fromJson(Map<String, dynamic> json) {
    return new ChanInfo(
      uniquelisteners: json['uniquelisteners'],
      songtitle: json['songtitle'],
    );
  }
}
