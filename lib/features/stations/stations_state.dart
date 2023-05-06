import 'package:equatable/equatable.dart';
import 'package:radioamoris/appdata.dart';

import '../../shared/model/mem_station.dart';

abstract class StationsState extends Equatable {
  const StationsState();

  @override
  List<Object> get props => [];
}

/// UnInitialized
class InitialState extends StationsState {
  const InitialState();
}

class InitAppDataState extends StationsState {
  const InitAppDataState(this.playerSingleton);
  final PlayerSingleton playerSingleton;

  @override
  List<Object> get props => [playerSingleton];
}

/// Initialized
class LoadStationsState extends StationsState {
  const LoadStationsState();
}

class ErrorStationsState extends StationsState {
  const ErrorStationsState(this.errorMessage);

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}

class PlayingStationState extends StationsState {
  final MemStation station;
  const PlayingStationState(this.station);

  @override
  List<Object> get props => [station];
}

class ErrorPlayerState extends StationsState {
  final MemStation station;
  const ErrorPlayerState(this.station);

  @override
  List<Object> get props => [station];
}
