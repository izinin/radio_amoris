import 'package:flutter/material.dart';

class Station extends StatefulWidget{
  final String _title;
  final String _subtitle;

  Station(this._title, this._subtitle);

  @override
  State<StatefulWidget> createState() {
    return new StationState();
  }
}

class StationState extends State<Station>{
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    print('-->');
    print(widget._title);
    print(widget._subtitle);
    return ListTile(
      leading: Icon(Icons.map),
      title: Text(widget._title),
      subtitle: Text(widget._subtitle),
      isThreeLine: true,
      onTap: (){
        setState(() { this._selected = !this._selected; });
        },
      selected: this._selected
    );
  }
}