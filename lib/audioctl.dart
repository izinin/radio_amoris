import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum PlayerState { created, playing, paused, inprogress, pauseresume }

class AudioCtl {
  final MethodChannel channel = new MethodChannel('com.zindolla.flutter/audio');

  VoidCallback nativeMsgHandler;
  PlayerState playerState = PlayerState.paused;

  Completer create(){
    channel.invokeMethod('create');
    return new Completer();
  }

  Future setmedia(String url) => channel.invokeMethod('setmedia', {'url': url});
  Future destroy() => channel.invokeMethod('destroy');
  Future pause() => channel.invokeMethod('pause');
  Future resume() => channel.invokeMethod('resume');
  Future stop() => channel.invokeMethod('stop');

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
    // print('_platformCallHandler call ${call.method} ${call.arguments}');
    if(callbacks.containsKey(call.method)){
      if(callbacks[call.method]!=null){
        callbacks[call.method]();
      }
    }else{
        print('Unknowm method ${call.method}');
    }
  }
}
