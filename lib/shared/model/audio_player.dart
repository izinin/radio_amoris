import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:radioamoris/appdata.dart';
import 'package:radioamoris/shared/model/mem_station.dart';
import 'package:rxdart/rxdart.dart';

class PlayerSingleton {
  // singleton
  static final PlayerSingleton _singleton = PlayerSingleton._internal();
  factory PlayerSingleton() => _singleton;
  static bool once = true;

  static const _platform = MethodChannel('com.zindolla.radioamoris/audio');
  static const EventChannel _playerStateStream = EventChannel(
    'com.zindolla.radioamoris/player-state',
  );
  static const EventChannel _currPlayingStream = EventChannel(
    'com.zindolla.radioamoris/currently-playing',
  );
  static const EventChannel _playlistCtrlStream = EventChannel(
    'com.zindolla.radioamoris/playlist-ctrl',
  );
  static const EventChannel _playerException = EventChannel(
    'com.zindolla.radioamoris/player-exception',
  );

  // https://stackoverflow.com/questions/53841750/flutter-stream-has-already-been-listened-to/55893532#55893532
  static final StreamController<MyradioPlayingState> _playerStatecontroller =
      BehaviorSubject();

  static final List<String> _playerErrors = [];

  // private constructor
  PlayerSingleton._internal();

  static String get settingsBoxName => 'settings';
  Stream<MyradioPlayingState> get getPlayerStateStream =>
      _playerStatecontroller.stream;

  // the second step initialiazation
  static Future<PlayerSingleton> instance() async {
    if (!once) {
      FlutterVolumeController.showSystemUI = false;
      await FlutterVolumeController.setIOSAudioSessionCategory(
          category: AudioSessionCategory.playback);
      return _singleton;
    }
    once = false;
    return _singleton;
  }

  Future<void> exoPlayerStart(MemStation tune) async {
    try {
      await _platform.invokeMethod('exoPlayerStart', {
        'id': tune.id,
        'url': tune.listenurl,
        'name': tune.name,
        'logo': null,
        'assetLogo': 'art/lockscr_256.png'
      });
      _startPlayerStateListener();
      _startNowPlayingListener();
      _startPlaylistCtrlListener();
      _startPlayerExceptionlListener();

      AppData.currentTune.value = tune;
    } on PlatformException catch (e) {
      _playerErrors.add("exoPlayerStart error: '${e.message}'");
    }
  }

  Future<void> exoPlayerResume() async {
    try {
      await _platform.invokeMethod('exoPlayerResume');
    } on PlatformException catch (e) {
      _playerErrors.add("exoPlayerResume error: '${e.message}'");
    }
  }

  Future<void> exoPlayerPause() async {
    try {
      await _platform.invokeMethod('exoPlayerPause');
    } on PlatformException catch (e) {
      _playerErrors.add("exoPlayerPause error: '${e.message}'");
    }
  }

  void _startPlayerStateListener() {
    _playerStateStream.receiveBroadcastStream().listen(
          listenPlayerStateStream,
        );
  }

  void _startNowPlayingListener() {
    _currPlayingStream.receiveBroadcastStream().listen(listenNowPlayingStream);
  }

  void _startPlaylistCtrlListener() {
    _playlistCtrlStream.receiveBroadcastStream().listen(
          listenPlaylistCtrlStream,
        );
  }

  void _startPlayerExceptionlListener() {
    _playerException.receiveBroadcastStream().listen(
          _listenPlayerExceptionStream,
        );
  }

  void _listenPlayerExceptionStream(dynamic raw) {
    final value = raw as Map<Object?, Object?>;
    final stationId = value['failed_id'] as int;
    MemStation mem =
        AppData.inMemoryStations.where((e) => e.id == stationId).first;
    mem.state = TuneState.invalid;
  }

  void listenPlayerStateStream(dynamic raw) {
    final value = raw as Map<Object?, Object?>;
    final stateInt = value['state'] as int;
    MyradioProcessingState state = MyradioProcessingState.fromInt(stateInt);
    final cmdInt = value['command'] as int;
    MyradioCommand command = MyradioCommand.fromInt(cmdInt);
    _playerStatecontroller.add(MyradioPlayingState(state, command));
  }

  void listenNowPlayingStream(dynamic raw) {
    final value = raw as Map<Object?, Object?>;
    final title = value['title'] as String;
    final url = value['url'] as String;
    if (title.isNotEmpty) {
      AppData.currentTuneMeta.value = {'title': title, 'url': url};
    }
  }

  void listenPlaylistCtrlStream(dynamic raw) {
    final tuneId = AppData.currentTune.value?.id;
    if (tuneId == null) {
      return;
    }
    final isForward = raw as bool;
    _playNextItem(tuneId, isForward, AppData.inMemoryStations);
  }

  void _playNextItem(int tuneId, bool isForward, List<MemStation> stations) {
    MemStation? nextTune;
    for (var i = 0; i < stations.length; i++) {
      MemStation station = stations[i];
      if (station.id == tuneId) {
        if (isForward) {
          nextTune = (i == stations.length - 1) ? stations[0] : stations[i + 1];
        } else {
          nextTune = (i == 0) ? stations[stations.length - 1] : stations[i - 1];
        }
        break;
      }
    }
    if (nextTune == null) {
      return;
    }
    exoPlayerStart(nextTune);
  }
}
