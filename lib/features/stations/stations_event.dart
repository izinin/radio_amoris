import 'dart:async';
import 'dart:developer' as developer;

import 'package:get_it/get_it.dart';
import 'package:radioamoris/features/stations/index.dart';
import 'package:meta/meta.dart';

import '../../appdata.dart';
import '../../shared/model/mem_station.dart';

@immutable
abstract class StationsEvent {
  static PlayerSingleton? _playerCtl;
  Stream<StationsState> applyAsync({StationsState currentState, StationsBloc bloc});
}

class InitAppDataEvent extends StationsEvent {
  @override
  Stream<StationsState> applyAsync({StationsState? currentState, StationsBloc? bloc}) async* {
    StationsEvent._playerCtl = await GetIt.I.getAsync<PlayerSingleton>();
    yield InitAppDataState(StationsEvent._playerCtl!);
  }
}

class LoadStationsEvent extends StationsEvent {
  static const metadataRefreshDuration = 60;
  LoadStationsEvent();
  @override
  Stream<StationsState> applyAsync({StationsState? currentState, StationsBloc? bloc}) async* {
    try {
      if (AppData.inMemoryStations.isEmpty) {
        await bloc?.repo.getRemoteData();
        for (var el in AppData.inMemoryStations) {
          await bloc?.repo.fillMetadata(el);
        }
        Timer(const Duration(seconds: metadataRefreshDuration), () {
          Timer.periodic(const Duration(seconds: metadataRefreshDuration), (timer) async {
            for (var el in AppData.inMemoryStations) {
              await bloc?.repo.fillMetadata(el);
            }
          });
        });
      }
      yield const LoadStationsState();
    } catch (_, stackTrace) {
      developer.log('$_', name: 'LoadStationsEvent', error: _, stackTrace: stackTrace);
      yield ErrorStationsState(_.toString());
    }
  }
}

class LoadTuneForStationEvent extends StationsEvent {
  final MemStation _station;
  LoadTuneForStationEvent(this._station);

  @override
  Stream<StationsState> applyAsync({StationsState? currentState, StationsBloc? bloc}) async* {
    try {
      await StationsEvent._playerCtl!.exoPlayerStart(_station);
      yield PlayingStationState(_station);
    } catch (err) {
      _station.errorMessage = 'cannot connect';
      _station.state = TuneState.invalid;
      yield ErrorPlayerState(_station);
    }
  }
}
