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

    public  static final String TOSERVICE_STATION_UID = "Audio.station.name";
    public  static final String TOSERVICE_AVAILABLE_STATIONS = "Audio.station.list";

    private final static String TAG = MainActivity.class.getSimpleName();

    private MethodChannel channel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        channel = new MethodChannel(getFlutterView(), "com.zindolla.radio_amoris/audio");
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
                int mediaId = call.argument("id");
                intent.putExtra(TOSERVICE_STATION_UID, mediaId);
                List<Map< Integer, Map<String,String>>> rawFavs = call.argument("stations");
                ArrayList<Station> stations = new ArrayList<>();
                for (Map< Integer, Map<String,String>> el: rawFavs){
                    int id = el.keySet().iterator().next();
                    Map<String,String> value = el.get(id);
                    stations.add(new Station(id, value.get("descr"), value.get("url")));
                }
                intent.putParcelableArrayListExtra(TOSERVICE_AVAILABLE_STATIONS, stations);
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
