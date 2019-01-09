package com.zindolla.radioamoris;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.ResultReceiver;
import android.support.v4.content.ContextCompat;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements MethodChannel.MethodCallHandler {

    public  static final String TOSERVICE_AUDIO_URL = "Audio.URL";
    public  static final String TOSERVICE_STATION_NAME = "Audio.station.name";
    protected static final String TOSERVICE_FAVOURITES = "Audio.station.favourites";

    private final static String TAG = MainActivity.class.getSimpleName();

    private MethodChannel channel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        channel = new MethodChannel(getFlutterView(), "com.zindolla.flutter/audio");
        channel.setMethodCallHandler(this);
    }

    @Override
    protected void onDestroy(){
        super.onDestroy();
        Intent intent = new Intent( getApplicationContext(), RadioAmorisService.class );
        intent.setAction(RadioAmorisService.EXIT_SERVICE);
        ContextCompat.startForegroundService(this, intent);
    }


    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result response) {
        Intent intent = new Intent( getApplicationContext(), RadioAmorisService.class );
        String action = null;
        switch (call.method) {
            case "create":
                String mediaUrl = call.argument("url") == null ? "" :
                        call.argument("url").toString();
                String stationName = call.argument("station") == null ? "" :
                        call.argument("station").toString();
                intent.putExtra(TOSERVICE_AUDIO_URL, mediaUrl);
                intent.putExtra(TOSERVICE_STATION_NAME, stationName);
                ArrayList<Station> favourites = new ArrayList<>();
                List<Map<String,String>> rawFavs = call.argument("favorites");
                if (rawFavs != null){
                    for (Map<String, String> el: rawFavs)
                    {
                        int id = el.get("id") == null ? -1 : Integer.parseInt(el.get("id"));
                        favourites.add(new Station(id, el.get("name"), el.get("logo"), el.get("url")));
                    }
                }
                intent.putParcelableArrayListExtra(TOSERVICE_FAVOURITES, favourites);
                action = RadioAmorisService.AUDIO_CREATE;
                break;
            case "pause":
                action = RadioAmorisService.AUDIO_PAUSE;
                // response.success(null);
                break;
            case "resume":
                action = RadioAmorisService.AUDIO_RESUME;
                break;
            case "destroy":
                action = RadioAmorisService.AUDIO_DESTROY;
                break;
            default:
                response.notImplemented();
        }
        if(action != null){
            intent.setAction(action);
            intent.putExtra(RadioAmorisService.BUNDLED_LISTENER, createReceiver(action));
            ContextCompat.startForegroundService(this, intent);
        }
    }

    private ResultReceiver createReceiver(final String action){
        return new ResultReceiver(new Handler()) {
            @Override
            protected void onReceiveResult(int resultCode, Bundle resultData) {
                super.onReceiveResult(resultCode, resultData);
                channel.invokeMethod((resultCode == Activity.RESULT_OK) ? action :
                        RadioAmorisService.AUDIO_ERROR, 0);
            }
        };
    }
}
