package com.zindolla.myradio;

import static androidx.media3.common.C.WAKE_MODE_NETWORK;
import static com.zindolla.myradio.MainActivity.TOSERVICE_TUNE_ASSETLOGO;
import static com.zindolla.myradio.MainActivity.TOSERVICE_TUNE_ID;
import static com.zindolla.myradio.MainActivity.TOSERVICE_TUNE_LOGO;
import static com.zindolla.myradio.MainActivity.TOSERVICE_TUNE_NAME;
import static com.zindolla.myradio.MainActivity.TOSERVICE_TUNE_URL;
import static com.zindolla.myradio.MainApplication.CHANNEL_ID;

import android.app.Activity;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.IBinder;
import android.os.ResultReceiver;

import androidx.core.app.NotificationCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.media3.common.MediaItem;
import androidx.media3.common.util.Util;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

public class MyRadioService extends Service {
    private ExoPlayer exoPlayer;

    public static final String AUDIO_START = "audio.start";
    public static final String AUDIO_RESUME = "audio.resume";
    public static final String AUDIO_PAUSE = "audio.pause";
    public static final String AUDIO_ERROR = "audio.error";
    public static final String EXIT_SERVICE = "service.exit";


    public static final String ACTION_NEXT = "action_next";
    public static final String ACTION_PREVIOUS = "action_previous";

    private ResultReceiver playerCommandCallback = null;
    public final static String BUNDLED_LISTENER = "listener";
    private final static String TAG = MyRadioService.class.getSimpleName();
    private String _curMediaUrl =  "http://103.253.132.7:5006";

    private Integer    tuneId;
    private String tuneName;
    private String tuneLogo;
    private String tuneAssetLogo;

    PlayerEventListener playbackStateListener = new PlayerEventListener(this);

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        handleIntent(intent);
        return START_NOT_STICKY;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        releasePlayer();
        return super.onUnbind(intent);
    }

    @Override
    public void onDestroy() {
        releasePlayer();
    }

    private void initializePlayer(String url) {
        // adaptive streaming support
        // https://developer.android.com/codelabs/exoplayer-intro#4
        DefaultTrackSelector trackSelector = new DefaultTrackSelector(this);
        trackSelector.setParameters(trackSelector.buildUponParameters().setMaxVideoSizeSd());

        exoPlayer = new ExoPlayer.Builder(this)
        //        .setTrackSelector(trackSelector) not working for Shoutcast
                .build();
        /* adaptive stream is not supported by Shoutcast
        MediaItem mediaItem = new MediaItem.Builder()
                .setUri(url)
                .setMimeType(MimeTypes.APPLICATION_MPD)
                .build();
        */
        MediaItem mediaItem = MediaItem.fromUri(url);

        exoPlayer.setWakeMode(WAKE_MODE_NETWORK);
        exoPlayer.setPlayWhenReady(true);
        exoPlayer.setMediaItem(mediaItem);
        exoPlayer.seekToDefaultPosition();
        exoPlayer.addListener(playbackStateListener);
        exoPlayer.prepare();
    }

    private void playerStart(String url) {
        _curMediaUrl = url;
        playbackStateListener.currCmd = MyPlayerCommand.PLAY;
        initializePlayer(url);
    }

    private void playerResume() {
        playbackStateListener.currCmd = MyPlayerCommand.PLAY;
        if ((Util.SDK_INT <= 23 || exoPlayer == null)) {
            initializePlayer(_curMediaUrl);
        }else{
            exoPlayer.setPlayWhenReady(true);
            // kick the player since media state change callback is not trigerred
            playbackStateListener.onPlaybackStateChanged(ExoPlayer.STATE_READY);
        }
    }

    private void playerPause() {
        playbackStateListener.currCmd = MyPlayerCommand.PAUSE;
        if (Util.SDK_INT <= 23) {
            releasePlayer();
        }else{
            exoPlayer.setPlayWhenReady(false);
            playbackStateListener.onPlaybackStateChanged(ExoPlayer.STATE_READY);
        }
    }

    public void playerStop() {
        if (Util.SDK_INT > 23) {
            releasePlayer();
        }
    }

    private void releasePlayer() {
        if(exoPlayer == null){
            return;
        }
        exoPlayer.removeListener(playbackStateListener);
        exoPlayer.release();
        exoPlayer = null;
    }

    private void nextRadio(boolean isForward){
        Intent RTReturn = new Intent(MainActivity.PLAYLIST_CTRL);
        RTReturn.putExtra("isForward", isForward);
        LocalBroadcastManager.getInstance(this).sendBroadcast(RTReturn);
    }

    private void handleIntent(Intent intent) {
        if (intent == null || intent.getAction() == null)
            return;

        String action = intent.getAction();
        playerCommandCallback = intent.getParcelableExtra(BUNDLED_LISTENER);

        if (action.equals(AUDIO_START)) {
            tuneId = intent.getIntExtra(TOSERVICE_TUNE_ID, -1);
            tuneName = intent.getStringExtra(TOSERVICE_TUNE_NAME);
            tuneLogo = intent.getStringExtra(TOSERVICE_TUNE_LOGO);
            tuneAssetLogo = intent.getStringExtra(TOSERVICE_TUNE_ASSETLOGO);
            playerStop();
            playerStart(intent.getStringExtra(TOSERVICE_TUNE_URL));
            buildNotification(generateAction(android.R.drawable.ic_media_pause, "Pause", AUDIO_PAUSE), Activity.RESULT_OK);
        } else if (action.equals(AUDIO_RESUME)) {
            playerResume();
            buildNotification(generateAction(android.R.drawable.ic_media_pause, "Pause", AUDIO_PAUSE), Activity.RESULT_OK);
        } else if (action.equals(AUDIO_PAUSE)) {
            playerPause();
            buildNotification(generateAction(android.R.drawable.ic_media_play, "Play", AUDIO_RESUME), Activity.RESULT_OK);
        } else if (action.equals(ACTION_PREVIOUS)) {
            nextRadio(false);
        } else if (action.equals(ACTION_NEXT)) {
            nextRadio(true);
        } else if (action.equals(EXIT_SERVICE)) {
            stopSelf();
        }
    }

    private NotificationCompat.Action generateAction(int icon, String title, String intentAction) {
        Intent intent = new Intent(getApplicationContext(), MyRadioService.class);
        intent.setAction(intentAction);
        int requestCode = 1;
        PendingIntent pending = PendingIntent.getService(this, requestCode, intent, PendingIntent.FLAG_ONE_SHOT | PendingIntent.FLAG_IMMUTABLE);
        return new NotificationCompat.Action.Builder(icon, title, pending).build();
    }

    private void buildNotification(NotificationCompat.Action action, int ui_res) {
        Intent showAppIntent = new Intent(this, MainActivity.class);
        int requestCode = 0;
        PendingIntent showAppIntentPending = PendingIntent.getActivity(this, requestCode, showAppIntent, PendingIntent.FLAG_ONE_SHOT | PendingIntent.FLAG_IMMUTABLE);

        androidx.media.app.NotificationCompat.MediaStyle style = new androidx.media.app.NotificationCompat.MediaStyle();
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_radio)
                .setContentTitle("World Tunes Radio")
                .setContentText(tuneName)
                .setContentIntent(showAppIntentPending)
                .setStyle(style);

        Bitmap bm = null;
        if(tuneLogo != null && tuneLogo.length() > 10) {
            Future<Bitmap> future = getBitmapFromUrl(tuneLogo);
            try {
                while(!future.isDone()) {
                    Thread.sleep(300);
                }
                bm = future.get();
            } catch (ExecutionException e) {
                e.printStackTrace();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            if(bm != null) {
                builder.setLargeIcon(bm);
            }
        }
        if(bm == null) {
            String[] artArr = tuneAssetLogo.split("/");
            bm = getBitmapFromFlutterResources(artArr[artArr.length -1]);
            if(bm != null) {
                builder.setLargeIcon(bm);
            }
        }
        builder.addAction(generateAction(android.R.drawable.ic_media_previous, "Previous", ACTION_PREVIOUS));
        builder.addAction(action);
        builder.addAction(generateAction(android.R.drawable.ic_media_next, "Next", ACTION_NEXT));
        style.setShowActionsInCompactView(0, 1, 2);

        if(playerCommandCallback != null){
            // update app
            playerCommandCallback.send(ui_res, new Bundle());
            playerCommandCallback = null;
        }
        // update notification
        startForeground(1, builder.build());
    }

    private ExecutorService executor = Executors.newSingleThreadExecutor();
    public Future<Bitmap> getBitmapFromUrl(String uri) {
        return executor.submit(() -> {
            try {
                URL url = new URL(uri);
                Bitmap image = BitmapFactory.decodeStream(url.openConnection().getInputStream());
                return image;
            } catch(IOException e) {}
            return null;
        });
    }

    private Bitmap getBitmapFromFlutterResources(String fname) {
        File itemFile = new File(this.getFilesDir(), fname);
        if(!itemFile.exists()){
            return null;
        }
        Bitmap res = BitmapFactory.decodeFile(itemFile.getAbsolutePath());
        return res;
    }
}
