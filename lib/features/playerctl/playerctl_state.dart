import 'package:equatable/equatable.dart';

import '../../appdata.dart';

abstract class PlayerctlState extends Equatable {
  const PlayerctlState();

  @override
  List<Object> get props => [];
}

/// UnInitialized
class InitialState extends PlayerctlState {
  const InitialState();

  @override
  String toString() => 'UnPlayerctlState';
}

/// Initialized
class InitAudioPlayerState extends PlayerctlState {
  const InitAudioPlayerState(this.player);

  final PlayerSingleton player;

  @override
  String toString() => 'InitAudioPlayerState';
  @override
  List<Object> get props => [player];
}

class ErrorPlayerctlState extends PlayerctlState {
  const ErrorPlayerctlState(this.errorMessage);

  final String errorMessage;

  @override
  String toString() => 'ErrorPlayerctlState';

  @override
  List<Object> get props => [errorMessage];
}
