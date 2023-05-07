import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:radioamoris/shared/model/mem_station.dart';
import 'package:rxdart/rxdart.dart';

class AppData {
  // singleton
  static final AppData _appData = AppData._internal();
  static bool _isSun = false;

  get isSun {
    _isSun = !_isSun;
    return _isSun;
  }

  // private constructor
  AppData._internal();

  factory AppData() => _appData;
  static List<MemStation> inMemoryStations = [];

  getDefaultArt() {
    return isSun ? 'art/sun-60.png' : 'art/moon-60.png';
  }

  static getAssetSvg(String url) {
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

  static late Box _favorites;

  factory PlayerSingleton() => _singleton;

  static bool once = true;

  static const _platform = MethodChannel('com.zindolla.myradio/audio');
  static const EventChannel _playerStateStream = EventChannel('com.zindolla.myradio/player-state');
  static const EventChannel _currPlayingStream = EventChannel('com.zindolla.myradio/currently-playing');
  static const EventChannel _playlistCtrlStream = EventChannel('com.zindolla.myradio/playlist-ctrl');
  static StreamSubscription? _playerStateStreamSubscr;
  static StreamSubscription? _currPlayingStreamSubscr;
  static StreamSubscription? _playlistCtrlStreamSubscr;
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
      return _singleton;
    }
    once = false;

    await _getImageFileFromAssets('art/moon-60.png');
    await _getImageFileFromAssets('art/sun-60.png');
    return _singleton;
  }

  static Future<String> _getImageFileFromAssets(String resource) async {
    final byteData = await rootBundle.load(resource);
    final buffer = byteData.buffer;
    Directory appDir = await getApplicationSupportDirectory(); // getTemporaryDirectory();
    final resourceArr = resource.split('/');
    final filePath = '${appDir.path}/${resourceArr[resourceArr.length - 1]}';
    var file = File(filePath);
    final existing = await file.exists();
    if (!existing) {
      file.writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return 'content:/$filePath';
  }

  Future<void> exoPlayerStart(MemStation tune) async {
    try {
      await _platform.invokeMethod('exoPlayerStart', {'id': tune.id, 'url': tune.listenurl, 'name': tune.name, 'logo': tune.logo, 'assetLogo': tune.assetlogo});
      _startPlayerStateListener();
      _startNowPlayingListener();
      _startPlaylistCtrlListener();
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
    _playerStateStreamSubscr = _playerStateStreamSubscr ?? _playerStateStream.receiveBroadcastStream().listen(_listenPlayerStateStream);
  }

  void _cancelPlayerStateListener() {
    _playerStateStreamSubscr?.cancel();
  }

  void _startNowPlayingListener() {
    _currPlayingStreamSubscr = _currPlayingStreamSubscr ?? _currPlayingStream.receiveBroadcastStream().listen(_listenNowPlayingStream);
  }

  void _cancelNowPlayingListener() {
    _currPlayingStreamSubscr?.cancel();
  }

  void _startPlaylistCtrlListener() {
    _playlistCtrlStreamSubscr = _playlistCtrlStreamSubscr ?? _playlistCtrlStream.receiveBroadcastStream().listen(_listenPlaylistCtrlStream);
  }

  void _cancelPlaylistCtrlListener() {
    _playlistCtrlStreamSubscr?.cancel();
  }

  void _listenPlayerStateStream(raw) {
    final value = raw as Map<Object?, Object?>;
    final stateInt = value['state'] as int;
    MyradioProcessingState state = MyradioProcessingState.values.firstWhere((e) => e.index == stateInt, orElse: () => MyradioProcessingState.idle);
    final cmdInt = value['command'] as int;
    MyradioCommand command = MyradioCommand.values.firstWhere((e) => e.index == cmdInt, orElse: () => MyradioCommand.idle);
    _playerStatecontroller.add(MyradioPlayingState(state, command));
  }

  void _listenNowPlayingStream(raw) {
    final value = raw as Map<Object?, Object?>;
    final title = value['title'] as String;
    final url = value['url'] as String;
    if (title.isNotEmpty) {
      AppData.currentTuneMeta.value = {'title': title, 'url': url};
    }
  }

  void _listenPlaylistCtrlStream(raw) {
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

const List<NavigationDestination> appBarDestinations = [
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.playlist_play_rounded),
    label: '',
    selectedIcon: Icon(Icons.playlist_play_outlined),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.info_outline_rounded),
    label: '',
    selectedIcon: Icon(Icons.info_rounded),
  ),
];

// NavigationRail shows if the screen width is greater or equal to
// screenWidthThreshold; otherwise, NavigationBar is used for navigation.
const double narrowScreenWidthThreshold = 450;
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
const apptitle = 'World tunes radio';
