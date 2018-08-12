package com.zindolla.radioamoris;

import android.app.Activity;
import android.util.Log;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodCall;

import java.io.IOException;

import android.content.Context;
import android.os.Build;

/**
 * Android implementation for AudioPlayerPlugin.
 */
public class AudioplayerPlugin implements MethodCallHandler {
  private final MethodChannel channel;
  private final String ID = "AudioplayerPlugin";
  private VLCMedia player = new VLCMedia();


  public AudioplayerPlugin(Activity activity, MethodChannel channel){
    this.channel = channel;
    this.channel.setMethodCallHandler(this);
    Context context = activity.getApplicationContext();
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result response) {
    switch (call.method) {
      case "create":
        create();
        response.success(null);
        break;
      case "setmedia":
        player.setMedia(call.argument("url").toString());
        response.success(null);
        break;
      case "pause":
        player.pause();
        response.success(null);
        break;
      case "stop":
        player.stop();
        response.success(null);
        break;
      case "resume":
        player.resume();
        response.success(null);
        break;
      case "destroy":
        player.releasePlayer();
        response.success(null);
        break;
      default:
        response.notImplemented();
    }
  }

  private void create() {
    try {
      player.createPlayer(channel);
      player.isReadyInit = true;
    } catch (Exception e) {
      channel.invokeMethod("audio.onError", e.getMessage());
    }
  }
}
