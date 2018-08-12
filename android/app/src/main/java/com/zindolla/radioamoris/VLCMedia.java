package com.zindolla.radioamoris;

import android.graphics.Point;
import android.net.Uri;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Toast;

import org.videolan.libvlc.IVLCVout;
import org.videolan.libvlc.LibVLC;
import org.videolan.libvlc.Media;
import org.videolan.libvlc.MediaPlayer;

import java.lang.ref.WeakReference;
import java.util.ArrayList;

import io.flutter.plugin.common.MethodChannel;

public class VLCMedia {
    private LibVLC libvlc;
    private MediaPlayer mMediaPlayer;
    private static final String TAG = "VLCMedia";
    private MethodChannel channel;
    public Boolean isReadyInit = false;

    public void createPlayer(MethodChannel channel) throws Exception {
        this.channel = channel;
        isReadyInit = false;
        releasePlayer();
        // Create LibVLC
        // TODO: make this more robust, and sync with audio demo
        ArrayList<String> options = new ArrayList<String>();
        //options.add("--subsdec-encoding <encoding>");
        options.add("--aout=opensles");
        options.add("--audio-time-stretch"); // time stretching
        options.add("-vvv"); // verbosity
        options.add("--http-reconnect");
        options.add("--network-caching="+6*1000);
        libvlc = new LibVLC(options);
        //libvlc.setOnHardwareAccelerationError(this);

        // Create media player
        mMediaPlayer = new MediaPlayer(libvlc);
        mMediaPlayer.setEventListener(mPlayerListener);
    }

    public void pause(){
        mMediaPlayer.pause();
    }

    public void setMedia(String media){
        Media m = new Media(libvlc, Uri.parse(media));
        mMediaPlayer.setMedia(m);
    }

    public void stop(){
        mMediaPlayer.stop();
    }

    public void resume(){
        mMediaPlayer.play();
    }

    public void releasePlayer() {
        if (libvlc == null)
            return;
        mMediaPlayer.stop();
        libvlc.release();
        libvlc = null;
    }

    /*************
     * Events
     *************/

    private MediaPlayer.EventListener mPlayerListener = new MyPlayerListener(this);


    private static class MyPlayerListener implements MediaPlayer.EventListener {

        private final VLCMedia player;

        public MyPlayerListener(VLCMedia player){
            this.player = player;
        }

        @Override
        public void onEvent(MediaPlayer.Event event) {
            Log.d(TAG, String.format("Player EVENT: 0x%x", event.type));
            switch(event.type) {
                case MediaPlayer.Event.EndReached:
                    Log.d(TAG, "MediaPlayerEndReached");
                    player.releasePlayer();
                    break;
                case MediaPlayer.Event.EncounteredError:
                    Log.d(TAG, "Error media open");
                    player.channel.invokeMethod("audio.onError", null);
                    break;
                case MediaPlayer.Event.Playing:
                    if(player.isReadyInit){
                        player.channel.invokeMethod("audio.onCreate", 0);
                        player.isReadyInit = false;
                    }else{
                        player.channel.invokeMethod("audio.onResume", null);
                    }
                    Log.d(TAG, "Media Player: playing");
                    break;
                case MediaPlayer.Event.Paused:
                    player.channel.invokeMethod("audio.onPause", null);
                    Log.d(TAG, "Media Player: paused");
                    break;
                case MediaPlayer.Event.Stopped:
                    player.channel.invokeMethod("audio.onDestroy", null);
                    Log.d(TAG, "Media Player: destroyed");
                    break;
                default:
                    break;
            }
        }
    }
}
