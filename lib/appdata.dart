
import 'package:flutter/material.dart';
import 'package:radioamoris/shared/model/mem_station.dart';

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

  static MyradioProcessingState fromInt(int value) {
    switch (value) {
      case 1:
        return MyradioProcessingState.idle;
      case 2:
        return MyradioProcessingState.buffering;
      case 3:
        return MyradioProcessingState.ready;
      case 4:
        return MyradioProcessingState.ended;
      default:
        throw ArgumentError('invalid value: $value');
    }
  }

  const MyradioProcessingState(this.value);
  final int value;
}

enum MyradioCommand {
  idle,
  play,
  pause;

  static MyradioCommand fromInt(int value) {
    switch (value) {
      case 0:
        return MyradioCommand.idle;
      case 1:
        return MyradioCommand.play;
      case 2:
        return MyradioCommand.pause;
      default:
        throw ArgumentError('invalid value: $value');
    }
  }
}

class MyradioPlayingState {
  final MyradioProcessingState state;
  final MyradioCommand command;

  MyradioPlayingState(this.state, this.command);
}

// NavigationRail shows if the screen width is greater or equal to
// screenWidthThreshold; otherwise, NavigationBar is used for navigation.
const Color m3BaseColor = Color(0xff6750a4);
const List<Color> colorOptions = [
  m3BaseColor,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.pink
];
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
