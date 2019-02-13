package com.zindolla.radioamoris;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.session.MediaController;
import android.os.Handler;

import java.util.concurrent.TimeUnit;

class AudioFocusUtitlity implements AudioManager.OnAudioFocusChangeListener {
    private final Object focusLock = new Object();
    private final MediaController player;
    private boolean playbackDelayed = false;
    private boolean resumeOnFocusGain = false;
    private boolean playbackNowAuthorized = false;
    private AudioFocusRequest focusRequest = null;
    private AudioManager audioManager;
    private Handler handler = new Handler();
    private Runnable delayedStopRunnable = new Runnable() {
        @Override
        public void run() {
            player.getTransportControls().stop();
        }
    };

    public AudioFocusUtitlity(MediaController player) {
        this.player = player;
        audioManager = (AudioManager) MainActivity.getAppContext().getSystemService(Context.AUDIO_SERVICE);
        AudioAttributes playbackAttributes = new AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build();
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            focusRequest = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                    .setAudioAttributes(playbackAttributes)
                    .setAcceptsDelayedFocusGain(true)
                    .setOnAudioFocusChangeListener(this, handler)
                    .build();
        }
    }

    @Override
    public void onAudioFocusChange(int focusChange) {
        switch (focusChange) {
            case AudioManager.AUDIOFOCUS_GAIN:
                if (playbackDelayed || resumeOnFocusGain) {
                    synchronized (focusLock) {
                        playbackDelayed = false;
                        resumeOnFocusGain = false;
                    }
                    player.getTransportControls().play();
                }
                break;
            case AudioManager.AUDIOFOCUS_LOSS:
                synchronized (focusLock) {
                    resumeOnFocusGain = false;
                    playbackDelayed = false;
                }
                player.getTransportControls().pause();
                // Wait 30 seconds before stopping playback
                handler.postDelayed(delayedStopRunnable,
                        TimeUnit.SECONDS.toMillis(30));
                break;
            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                synchronized (focusLock) {
                    resumeOnFocusGain = true;
                    playbackDelayed = false;
                }
                player.getTransportControls().pause();
                break;
            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
                // ... pausing or ducking depends on your app
                break;
        }
    }

    public void finishPlayback(){
        // Abandon audio focus when playback complete
        audioManager.abandonAudioFocus(this);
    }

    public void tryPlayback() {
        int res;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            res = audioManager.requestAudioFocus(focusRequest);
            synchronized (focusLock) {
                if (res == AudioManager.AUDIOFOCUS_REQUEST_FAILED) {
                    playbackNowAuthorized = false;
                } else if (res == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                    playbackNowAuthorized = true;
                    player.getTransportControls().play();
                } else if (res == AudioManager.AUDIOFOCUS_REQUEST_DELAYED) {
                    playbackDelayed = true;
                    playbackNowAuthorized = false;
                }
            }
            if(playbackNowAuthorized){
                player.getTransportControls().play();
            }
        }else{
            res = audioManager.requestAudioFocus(this,
                    AudioManager.STREAM_MUSIC,
                    AudioManager.AUDIOFOCUS_GAIN);

            if (res == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                player.getTransportControls().play();
            }
        }
    }
}
