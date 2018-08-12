import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum PlayerState { created, destroyed, playing, paused }

class AudioCtl {
  final MethodChannel channel = new MethodChannel('com.zindolla.flutter/audio');

  VoidCallback nativeMsgHandler;
  PlayerState playerState = PlayerState.destroyed;

  Completer create(String url){
    channel.invokeMethod('create', {'url': url});
    return new Completer();
  }

  Future destroy() => channel.invokeMethod('destroy');
  Future pause() => channel.invokeMethod('pause');
  Future resume() => channel.invokeMethod('resume');

  Map<String, VoidCallback> callbacks = {
    'audio.onCreate': null,
    'audio.onDestroy': null,
    'audio.onPause': null,
    'audio.onResume': null,
    'audio.onError': null
  };

  AudioCtl() {
    channel.setMethodCallHandler(platformCallHandler);
  }

  Future platformCallHandler(MethodCall call) async {
    print('_platformCallHandler call ${call.method} ${call.arguments}');
    if(callbacks.containsKey(call.method)){
      if(callbacks[call.method]!=null){
        callbacks[call.method]();
      }
    }else{
        print('Unknowm method ${call.method}');
    }
  }
}
