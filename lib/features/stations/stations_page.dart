import 'package:flutter/material.dart';
import 'package:radio_amoris/features/stations/index.dart';

class StationsPage extends StatefulWidget {
  static const String routeName = '/stations';

  const StationsPage({super.key});

  @override
  StationsPageState createState() => StationsPageState();
}

class StationsPageState extends State<StationsPage> with AutomaticKeepAliveClientMixin {
  final _stationsBloc = StationsBloc(const InitialState());

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StationsScreen(stationsBloc: _stationsBloc);
  }

  @override
  bool get wantKeepAlive => true;
}
