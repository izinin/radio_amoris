import 'package:flutter/material.dart';
import 'package:radio_amoris/features/playerctl/index.dart';

class PlayerctlPage extends StatefulWidget {
  static const String routeName = '/playerctl';

  const PlayerctlPage({super.key});

  @override
  PlayerctlPageState createState() => PlayerctlPageState();
}

class PlayerctlPageState extends State<PlayerctlPage> with AutomaticKeepAliveClientMixin {
  final _playerctlBloc = PlayerctlBloc(const InitialState());

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PlayerctlScreen(playerctlBloc: _playerctlBloc);
  }

  @override
  bool get wantKeepAlive => true;
}
