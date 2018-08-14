import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:radio_amoris/audioctl.dart';
import 'dart:convert';

import 'package:radio_amoris/radiostations.dart';

class Station extends StatefulWidget{
  final String _descr;
  final String _baseUrl;
  final AudioCtl _playerCtl;
  final int _uid;
  final ValueChanged<int> itemSelectedCallback;

  Station(this._playerCtl, this._uid, this._descr, this._baseUrl,
  { @required this.itemSelectedCallback });

  @override
  State<StatefulWidget> createState() {
    return new StationState();
  }
}

class StationState extends State<Station>{
  bool _selected = false;
  var _client = new http.Client();

  Future<ChanInfo> _fetchChanInfo() async {
    final response = await _client.get(widget._baseUrl + '/stats.json',
      headers: {
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36'
      }
    );
    if (response.statusCode == 200) {
      return ChanInfo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load channel info');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sharedSel = SharedSelection.of(context);
    print(sharedSel.uid);
    return ListTile(
      leading: Icon((!_selected) ? Icons.play_circle_outline : 
        (PlayerState.paused == widget._playerCtl.playerState) ? 
          Icons.pause_circle_outline : Icons.play_circle_outline),
      title: Text(widget._descr),
      subtitle: FutureBuilder<ChanInfo>(
        future: _fetchChanInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text('${snapshot.data.songtitle} \nlisteners: ${snapshot.data.uniquelisteners}');
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner
          return Text('...');
        },
      ),
      isThreeLine: true,
      onTap: (){
          setState(() { 
            _selected = !_selected; 
            });
          widget.itemSelectedCallback(widget._uid);
        //  if (PlayerState.paused == widget._playerCtl.playerState) {
        //    widget._playerCtl.setmedia(widget._baseUrl);
        //    widget._playerCtl.resume();
        //  }else{
        //    widget._playerCtl.pause();
        //  }
        },
      selected: _selected
    );
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
