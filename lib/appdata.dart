import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radioamoris/shared/model/mem_station.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

class AppData {
  // singleton
  static final AppData _appData = AppData._internal();
  static bool _isSun = false;

  bool get isSun {
    _isSun = !_isSun;
    return _isSun;
  }

  // private constructor
  AppData._internal();

  factory AppData() => _appData;
  static List<MemStation> inMemoryStations = [];

  String getDefaultArt() {
    return isSun ? 'art/sun-60.png' : 'art/moon-60.png';
  }

  static String getAssetSvg(String url) {
    return url == 'art/sun-60.png' ? 'art/sun.svg' : 'art/moon.svg';
  }

  static var currentTune = ValueNotifier<MemStation?>(null);
  static var currentTuneMeta = ValueNotifier<Map<String, String>?>(null);
}

enum MyradioProcessingState {
  idle(1), //  ExoPlayer.STATE_IDLE
  buffering(2), //  ExoPlayer.STATE_BUFFERING
  ready(3), //  ExoPlayer.STATE_READY
  ended(4); //  ExoPlayer.STATE_ENDED

  const MyradioProcessingState(this.value);
  final int value;
}

enum MyradioCommand {
  idle,
  play,
  pause;
}

class MyradioPlayingState {
  final MyradioProcessingState state;
  final MyradioCommand command;

  MyradioPlayingState(this.state, this.command);
}

class PlayerSingleton {
  // singleton
  static final PlayerSingleton _singleton = PlayerSingleton._internal();

  factory PlayerSingleton() => _singleton;
  static bool once = true;
  static const _platform = MethodChannel('com.zindolla.radioamoris/audio');

  // https://stackoverflow.com/questions/53841750/flutter-stream-has-already-been-listened-to/55893532#55893532
  static final StreamController<MyradioPlayingState> _playerStatecontroller = BehaviorSubject();

  static final List<String> _playerErrors = [];

  // private constructor
  PlayerSingleton._internal();

  static String get settingsBoxName => 'settings';
  Stream<MyradioPlayingState> get getPlayerStateStream => _playerStatecontroller.stream;

  // the second step initialiazation
  static Future<PlayerSingleton> instance() async {
    if (!once) {
      FlutterVolumeController.showSystemUI = false;
      await FlutterVolumeController.setIOSAudioSessionCategory(category: AudioSessionCategory.playback);
      return _singleton;
    }
    once = false;
    return _singleton;
  }

  Future<void> exoPlayerStart(MemStation tune) async {
    try {
      await _platform.invokeMethod('exoPlayerStart', {'id': tune.id, 'url': tune.listenurl, 'name': tune.name, 'logo': null, 'assetLogo': 'art/lockscr_256.png'});
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

  void listenPlayerStateStream(dynamic raw) {
    final value = raw as Map<Object?, Object?>;
    final stateInt = value['state'] as int;
    MyradioProcessingState state = MyradioProcessingState.values.firstWhere((e) => e.index == stateInt, orElse: () => MyradioProcessingState.idle);
    final cmdInt = value['command'] as int;
    MyradioCommand command = MyradioCommand.values.firstWhere((e) => e.index == cmdInt, orElse: () => MyradioCommand.idle);
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

// NavigationRail shows if the screen width is greater or equal to
// screenWidthThreshold; otherwise, NavigationBar is used for navigation.
const Color m3BaseColor = Color(0xff6750a4);
const List<Color> colorOptions = [m3BaseColor, Colors.blue, Colors.teal, Colors.green, Colors.yellow, Colors.orange, Colors.pink];
const List<String> colorText = <String>[
  'M3 Baseline',
  'Blue',
  'Teal',
  'Green',
  'Yellow',
  'Orange',
  'Pink',
];
const apptitle = 'ANIMA AMORIS';
