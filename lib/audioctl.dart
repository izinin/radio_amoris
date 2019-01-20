import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:radio_amoris/stationsdata.dart';

enum PlayerState { created, destroyed, playing, paused, inprogress }

class AudioCtl {
  final MethodChannel _channel = new MethodChannel('com.zindolla.radio_amoris/audio');
  Map<String, VoidCallback> _callbacks;

  PlayerState playerState = PlayerState.paused;

  final VoidCallback _onCreated;
  final VoidCallback _onDestroying;
  final VoidCallback _onPaused;
  final VoidCallback _onResumed;
  final VoidCallback _onError;

  AudioCtl(this._onCreated,
            this._onDestroying,
            this._onPaused,
            this._onResumed,
            this._onError) {
    _channel.setMethodCallHandler(_platformCallHandler);
    _callbacks = Map<String, VoidCallback>.from({
    'audio.onCreate': _onCreated,
    'audio.onDestroy': _onDestroying,
    'audio.onPause': _onPaused,
    'audio.onResume': _onResumed,
    'audio.onError': _onError
    });
  }

  Future _platformCallHandler(MethodCall call) async {
    print('_platformCallHandler call ${call.method} ${call.arguments}');
    if (_callbacks.containsKey(call.method)) {
      if (_callbacks[call.method] != null) {
        _callbacks[call.method]();
      }
    } else {
      print('Unknowm method ${call.method}');
    }
  }


  get state => playerState;

  Completer create(int id) {
    _channel.invokeMethod('create', {'id': id, 
      'stations': StationsData.entries.toList()});
    return new Completer();
  }

  Future destroy() => _channel.invokeMethod('destroy');
  Future pause() => _channel.invokeMethod('pause');
  Future resume() => _channel.invokeMethod('resume');
}
