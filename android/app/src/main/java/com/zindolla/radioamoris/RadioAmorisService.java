package com.zindolla.radioamoris;

import android.app.Activity;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.session.MediaController;
import android.media.session.MediaSession;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.ResultReceiver;
import android.util.Log;

import java.io.IOException;
import java.util.List;

import android.support.v4.app.NotificationCompat;

import static com.zindolla.radioamoris.MainActivity.TOSERVICE_AVAILABLE_STATIONS;
import static com.zindolla.radioamoris.MainActivity.TOSERVICE_STATION_UID;
import static com.zindolla.radioamoris.NotificationWrapper.CHANNEL_ID;

public class RadioAmorisService extends Service {

    // see "lib/audioctl.dart" MethodChannel definitions
    public static final String AUDIO_CREATE = "audio.onCreate";
    public static final String AUDIO_DESTROY = "audio.onDestroy";
    public static final String AUDIO_ERROR = "audio.onError";
    public static final String AUDIO_RESUME = "audio.onResume";
    public static final String AUDIO_PAUSE = "audio.onPause";
    public static final String EXIT_SERVICE = "service.exit";


    public static final String ACTION_NEXT = "action_next";
    public static final String ACTION_PREVIOUS = "action_previous";

    private MediaSession mSession = null;
    private MediaController mController = null;
    private MediaPlayer mPlayer = null;
    private ResultReceiver ui_callback = null;
    private Boolean isMediaOpened = false;

    public final static String BUNDLED_LISTENER = "listener";
    private final static String TAG = RadioAmorisService.class.getSimpleName();
    private List<Station>  mAvailableChannels;
    private int mCurrIndex = 0;

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private Station moveForward(){
        if(mAvailableChannels.size() == 0){
            return null;
        }
        mCurrIndex++;
        if(mCurrIndex >= mAvailableChannels.size()){
            mCurrIndex = 0;
        }
        return mAvailableChannels.get(mCurrIndex);
    }

    private Station moveBackward(){
        if(mAvailableChannels.size() == 0){
            return null;
        }
        mCurrIndex--;
        if(mCurrIndex < 0){
            mCurrIndex = mAvailableChannels.size() - 1;
        }
        return  mAvailableChannels.get(mCurrIndex);
    }

    private void openAudioStream(Station current){
        if(current == null){
            return;
        }
        isMediaOpened = false;
        mPlayer.reset();
        mPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
        try {
            mPlayer.setDataSource(current.url);
            mPlayer.prepareAsync();
            delayedCall(4000);
        }catch (IllegalArgumentException e){
            Log.e(TAG, String.format("createPlayer, IllegalArgumentException: %s", e.getMessage()));
        }catch (SecurityException e){
            Log.e(TAG, String.format("createPlayer, SecurityException: %s", e.getMessage()));
        }catch (IllegalStateException e){
            Log.e(TAG, String.format("createPlayer, IllegalStateException: %s", e.getMessage()));
        }catch (IOException e){
            // Catch the exception
            e.printStackTrace();
        }
    }

    private void handleIntent(Intent intent) {
        if (intent == null || intent.getAction() == null)
            return;

        String action = intent.getAction();
        ui_callback = intent.getParcelableExtra(BUNDLED_LISTENER);

        if (action.equalsIgnoreCase(AUDIO_CREATE)) {
            mAvailableChannels = intent.getParcelableArrayListExtra(TOSERVICE_AVAILABLE_STATIONS);
            mCurrIndex = Integer.parseInt(intent.getStringExtra(TOSERVICE_STATION_UID));
            openAudioStream(mAvailableChannels.get(mCurrIndex));
        } else if (action.equalsIgnoreCase(AUDIO_RESUME)) {
            mController.getTransportControls().play();
        } else if (action.equalsIgnoreCase(AUDIO_PAUSE)) {
            mController.getTransportControls().pause();
        } else if (action.equalsIgnoreCase(AUDIO_DESTROY)) {
            mController.getTransportControls().stop();
        } else if (action.equalsIgnoreCase(ACTION_PREVIOUS)) {
            mController.getTransportControls().skipToPrevious();
        } else if (action.equalsIgnoreCase(ACTION_NEXT)) {
            mController.getTransportControls().skipToNext();
        } else if (action.equalsIgnoreCase(EXIT_SERVICE)) {
            if(isMediaOpened){
                mPlayer.stop();
            }
            mPlayer.reset();
            stopSelf();
        }
    }

    private NotificationCompat.Action generateAction(int icon, String title, String intentAction) {
        Intent intent = new Intent(getApplicationContext(), RadioAmorisService.class);
        intent.setAction(intentAction);
        PendingIntent pendingIntent = PendingIntent.getService(getApplicationContext(), 1, intent, 0);
        return new NotificationCompat.Action.Builder(icon, title, pendingIntent).build();
    }

    private void buildNotification(NotificationCompat.Action action, int ui_res) {
        Intent showAppIntent = new Intent(this, MainActivity.class);
        PendingIntent showAppIntentPending = PendingIntent.getActivity(this,
                0, showAppIntent, 0);

        android.support.v4.media.app.NotificationCompat.MediaStyle style = new android.support.v4.media.app.NotificationCompat.MediaStyle();
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_radio)
                .setContentTitle(mAvailableChannels == null ? "" : mAvailableChannels.get(mCurrIndex).descr)
                .setContentText("Radio Amoris")
                .setContentIntent(showAppIntentPending)
                .setStyle(style);

        if(mAvailableChannels != null && mAvailableChannels.size() > 1){
            builder.addAction(generateAction(android.R.drawable.ic_media_previous, "Previous", ACTION_PREVIOUS));
        }
        builder.addAction(action);
        if(mAvailableChannels != null && mAvailableChannels.size() > 1){
            builder.addAction(generateAction(android.R.drawable.ic_media_next, "Next", ACTION_NEXT));
            style.setShowActionsInCompactView(0, 1, 2);
        }

        if(ui_callback != null){
            // update app
            ui_callback.send(ui_res, new Bundle());
            ui_callback = null;
        }
        // update notification
        startForeground(1, builder.build());
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (mController == null) {
            initMediaSessions();
        }
        handleIntent(intent);
        return START_NOT_STICKY;
    }

    private MediaPlayer createMediaPlayer() {
        MediaPlayer player = new MediaPlayer();

        player.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mediaPlayer) {
                mediaPlayer.reset();
            }
        });

        player.setOnErrorListener(new MediaPlayer.OnErrorListener() {
            @Override
            public boolean onError(MediaPlayer mediaPlayer, int what, int extra) {
                mediaPlayer.reset();
                buildNotification(generateAction(R.drawable.ic_block, "Error", AUDIO_ERROR), Activity.RESULT_OK);
                return false;
            }
        });

        player.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mediaPlayer) {
                mediaPlayer.start();
                isMediaOpened = true;
                // update notification
                buildNotification(generateAction(android.R.drawable.ic_media_pause, "Pause", AUDIO_PAUSE), Activity.RESULT_OK);
            }
        });

        return player;
    }

    private void initMediaSessions() {
        mPlayer = createMediaPlayer();

        mSession = new MediaSession(getApplicationContext(), "simple player session");
        mController = new MediaController(getApplicationContext(), mSession.getSessionToken());

        mSession.setCallback(
                new MediaSession.Callback() {
                    @Override
                    public void onStop() {
                        if(isMediaOpened){
                            mPlayer.stop();
                        }
                        mPlayer.reset();
                        Log.e(TAG, "onStop");
                        buildNotification(generateAction(R.drawable.ic_block, "Pause", AUDIO_DESTROY), Activity.RESULT_OK);
                    }

                    @Override
                    public void onPlay() {
                        if(isMediaOpened){
                            mPlayer.start();
                        }
                        Log.e(TAG, "onPlay");
                        buildNotification(generateAction(android.R.drawable.ic_media_pause, "Pause", AUDIO_PAUSE), Activity.RESULT_OK);
                    }

                    @Override
                    public void onPause() {
                        Log.e(TAG, "onPause");
                        if(isMediaOpened){
                            mPlayer.pause();
                        }
                        buildNotification(generateAction(android.R.drawable.ic_media_play, "Play", AUDIO_RESUME), Activity.RESULT_OK);
                    }

                    @Override
                    public void onSkipToNext() {
                        Log.e(TAG, "onSkipToNext");
                        openAudioStream(moveForward());
                    }

                    @Override
                    public void onSkipToPrevious() {
                        Log.e(TAG, "onSkipToPrevious");
                        openAudioStream(moveBackward());
                    }
                }
        );
    }

    @Override
    public boolean onUnbind(Intent intent) {
        mSession.release();
        return super.onUnbind(intent);
    }

    private void delayedCall(int msec){
        final Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                if(!isMediaOpened){
                    Log.i(TAG, "mPlayer canceling openning media");
                    buildNotification(generateAction(R.drawable.ic_block, "Error", AUDIO_ERROR), Activity.RESULT_OK);
                }
            }
        }, 100);
    }

//    public int onStartCommand_0(Intent intent, int flags, int startId) {
//        Intent notificationIntent = new Intent(this, MainActivity.class);
//        PendingIntent pendingIntent = PendingIntent.getActivity(this,
//                0, notificationIntent, 0);
//
//        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID);
//        builder.setContentTitle("audioplayer.getStationName()");
//        builder.setContentText("World Tunes Radio");
//        builder.setSmallIcon(R.drawable.ic_play);
//        builder.setContentIntent(pendingIntent);
//        builder.setStyle(new NotificationCompat.DecoratedCustomViewStyle());
//        Notification notification = builder.build();
//
//        startForeground(1, notification);
//
//        //do heavy work on a background thread
//        //stopSelf();
//
//        return START_NOT_STICKY;
//    }

}
