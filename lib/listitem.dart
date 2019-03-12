import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:radio_amoris/amoris_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:convert';

class Station extends StatefulWidget{
  final String _descr;
  final String _baseUrl;
  final int _uid;

  Station(this._uid, this._descr, this._baseUrl);

  @override
  State<StatefulWidget> createState() {
    return new StationState();
  }
}

class StationState extends State<Station>{
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
      return ChanInfo.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load channel info');
    }
  }
    
  @override
  Widget build(BuildContext context) {
    return new ScopedModelDescendant<AmorisModel>(
      builder: (context, child, model) => new ListTile(  // sharedSel ----> FIXME! Text('${model.counter}'),
        leading: model.getIgon(widget._uid),
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
          model.select(widget._uid);
        },
        selected: model.isSelected(widget._uid)
      )
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
