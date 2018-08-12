import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:radio_amoris/audioctl.dart';
import 'dart:convert';

class Station extends StatefulWidget{
  final String _descr;
  final String _baseUrl;
  final AudioCtl _playerCtl;

  Station(this._playerCtl, this._descr, this._baseUrl);

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
    return ListTile(
      leading: Icon(Icons.map),
      title: Text(widget._descr),
      subtitle: FutureBuilder<ChanInfo>(
        future: _fetchChanInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print(snapshot.data);
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
        setState(() { this._selected = !this._selected; });
        (PlayerState.paused == widget._playerCtl.playerState) ? 
            widget._playerCtl.resume : widget._playerCtl.pause;
        },
      selected: this._selected
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
