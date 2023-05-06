import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:radio_amoris/features/playerctl/index.dart';
import 'package:meta/meta.dart';

import '../../appdata.dart';

@immutable
abstract class PlayerctlEvent {
  Stream<PlayerctlState> applyAsync({PlayerctlState currentState, PlayerctlBloc bloc});
}

class InitAudioPlayerEvent extends PlayerctlEvent {
  @override
  Stream<PlayerctlState> applyAsync({PlayerctlState? currentState, PlayerctlBloc? bloc}) async* {
    PlayerSingleton singleton = await GetIt.I.getAsync<PlayerSingleton>();
    yield InitAudioPlayerState(singleton);
  }
}
