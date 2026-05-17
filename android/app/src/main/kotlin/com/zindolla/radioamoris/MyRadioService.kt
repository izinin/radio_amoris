package com.zindolla.radioamoris

import android.app.Activity
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Bundle
import android.os.IBinder
import android.os.ResultReceiver
import androidx.core.app.NotificationCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.media3.common.C.WAKE_MODE_NETWORK
import androidx.media3.common.MediaItem
import androidx.media3.common.util.Util
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector
import com.zindolla.radioamoris.MainActivity.Companion.TOSERVICE_TUNE_ASSETLOGO
import com.zindolla.radioamoris.MainActivity.Companion.TOSERVICE_TUNE_ID
import com.zindolla.radioamoris.MainActivity.Companion.TOSERVICE_TUNE_LOGO
import com.zindolla.radioamoris.MainActivity.Companion.TOSERVICE_TUNE_NAME
import com.zindolla.radioamoris.MainActivity.Companion.TOSERVICE_TUNE_URL
import com.zindolla.radioamoris.MainApplication.Companion.CHANNEL_ID
import java.io.File
import java.io.IOException
import java.net.URL
import java.util.concurrent.ExecutionException
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.Future

class MyRadioService : Service() {
    private var exoPlayer: ExoPlayer? = null

    companion object {
        const val AUDIO_START = "audio.start"
        const val AUDIO_RESUME = "audio.resume"
        const val AUDIO_PAUSE = "audio.pause"
        const val AUDIO_ERROR = "audio.error"
        const val EXIT_SERVICE = "service.exit"

        const val ACTION_NEXT = "action_next"
        const val ACTION_PREVIOUS = "action_previous"

        const val BUNDLED_LISTENER = "listener"
    }

    private var playerCommandCallback: ResultReceiver? = null
    private val TAG = MyRadioService::class.java.simpleName
    private var _curMediaUrl = "http://103.253.132.7:5006"

    private var tuneId: Int? = null
    private var tuneName: String? = null
    private var tuneLogo: String? = null
    private var tuneAssetLogo: String? = null

    private val playbackStateListener = PlayerEventListener(this)

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        handleIntent(intent)
        return START_NOT_STICKY
    }

    override fun onUnbind(intent: Intent?): Boolean {
        releasePlayer()
        return super.onUnbind(intent)
    }

    override fun onDestroy() {
        releasePlayer()
    }

    private fun initializePlayer(url: String) {
        val trackSelector = DefaultTrackSelector(this)
        trackSelector.parameters = trackSelector.buildUponParameters().setMaxVideoSizeSd().build()

        exoPlayer = ExoPlayer.Builder(this)
            .build()
        
        val mediaItem = MediaItem.fromUri(url)

        exoPlayer?.let {
            it.setWakeMode(WAKE_MODE_NETWORK)
            it.playWhenReady = true
            it.setMediaItem(mediaItem)
            it.seekToDefaultPosition()
            it.addListener(playbackStateListener)
            it.prepare()
        }
    }

    private fun playerStart(url: String) {
        _curMediaUrl = url
        playbackStateListener.currCmd = MyPlayerCommand.PLAY
        initializePlayer(url)
    }

    private fun playerResume() {
        playbackStateListener.currCmd = MyPlayerCommand.PLAY
        if (Util.SDK_INT <= 23 || exoPlayer == null) {
            initializePlayer(_curMediaUrl)
        } else {
            exoPlayer?.playWhenReady = true
            playbackStateListener.onPlaybackStateChanged(ExoPlayer.STATE_READY)
        }
    }

    private fun playerPause() {
        playbackStateListener.currCmd = MyPlayerCommand.PAUSE
        if (Util.SDK_INT <= 23) {
            releasePlayer()
        } else {
            exoPlayer?.playWhenReady = false
            playbackStateListener.onPlaybackStateChanged(ExoPlayer.STATE_READY)
        }
    }

    fun playerStop() {
        if (Util.SDK_INT > 23) {
            releasePlayer()
        }
    }

    private fun releasePlayer() {
        exoPlayer?.let {
            it.removeListener(playbackStateListener)
            it.release()
            exoPlayer = null
        }
    }

    private fun nextRadio(isForward: Boolean) {
        val RTReturn = Intent(MainActivity.PLAYLIST_CTRL)
        RTReturn.putExtra("isForward", isForward)
        LocalBroadcastManager.getInstance(this).sendBroadcast(RTReturn)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null || intent.action == null) return

        val action = intent.action
        playerCommandCallback = intent.getParcelableExtra(BUNDLED_LISTENER)

        when (action) {
            AUDIO_START -> {
                tuneId = intent.getIntExtra(TOSERVICE_TUNE_ID, -1)
                tuneName = intent.getStringExtra(TOSERVICE_TUNE_NAME)
                tuneLogo = intent.getStringExtra(TOSERVICE_TUNE_LOGO)
                tuneAssetLogo = intent.getStringExtra(TOSERVICE_TUNE_ASSETLOGO)
                playerStop()
                intent.getStringExtra(TOSERVICE_TUNE_URL)?.let { playerStart(it) }
                buildNotification(generateAction(android.R.drawable.ic_media_pause, "Pause", AUDIO_PAUSE), Activity.RESULT_OK)
            }
            AUDIO_RESUME -> {
                playerResume()
                buildNotification(generateAction(android.R.drawable.ic_media_pause, "Pause", AUDIO_PAUSE), Activity.RESULT_OK)
            }
            AUDIO_PAUSE -> {
                playerPause()
                buildNotification(generateAction(android.R.drawable.ic_media_play, "Play", AUDIO_RESUME), Activity.RESULT_OK)
            }
            ACTION_PREVIOUS -> nextRadio(false)
            ACTION_NEXT -> nextRadio(true)
            EXIT_SERVICE -> stopSelf()
        }
    }

    private fun generateAction(icon: Int, title: String, intentAction: String): NotificationCompat.Action {
        val intent = Intent(applicationContext, MyRadioService::class.java)
        intent.action = intentAction
        val requestCode = 1
        val pending = PendingIntent.getService(this, requestCode, intent, PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE)
        return NotificationCompat.Action.Builder(icon, title, pending).build()
    }

    private fun buildNotification(action: NotificationCompat.Action, ui_res: Int) {
        val showAppIntent = Intent(this, MainActivity::class.java)
        val requestCode = 0
        val showAppIntentPending = PendingIntent.getActivity(this, requestCode, showAppIntent, PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE)

        val style = androidx.media.app.NotificationCompat.MediaStyle()
        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_radio)
            .setContentTitle("Radio Amoris")
            .setContentText(tuneName)
            .setContentIntent(showAppIntentPending)
            .setStyle(style)

        var bm: Bitmap? = null
        if (tuneLogo != null && tuneLogo!!.length > 10) {
            val future = getBitmapFromUrl(tuneLogo!!)
            try {
                while (!future.isDone) {
                    Thread.sleep(300)
                }
                bm = future.get()
            } catch (e: ExecutionException) {
                e.printStackTrace()
            } catch (e: InterruptedException) {
                e.printStackTrace()
            }
            if (bm != null) {
                builder.setLargeIcon(bm)
            }
        }
        if (bm == null && tuneAssetLogo != null) {
            val artArr = tuneAssetLogo!!.split("/")
            bm = getBitmapFromFlutterResources(artArr[artArr.size - 1])
            if (bm != null) {
                builder.setLargeIcon(bm)
            }
        }
        builder.addAction(generateAction(android.R.drawable.ic_media_previous, "Previous", ACTION_PREVIOUS))
        builder.addAction(action)
        builder.addAction(generateAction(android.R.drawable.ic_media_next, "Next", ACTION_NEXT))
        style.setShowActionsInCompactView(0, 1, 2)

        playerCommandCallback?.let {
            it.send(ui_res, Bundle())
            playerCommandCallback = null
        }
        startForeground(1, builder.build())
    }

    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    fun getBitmapFromUrl(uri: String): Future<Bitmap?> {
        return executor.submit<Bitmap?> {
            try {
                val url = URL(uri)
                BitmapFactory.decodeStream(url.openConnection().getInputStream())
            } catch (e: IOException) {
                null
            }
        }
    }

    private fun getBitmapFromFlutterResources(fname: String): Bitmap? {
        val itemFile = File(this.filesDir, fname)
        if (!itemFile.exists()) {
            return null
        }
        return BitmapFactory.decodeFile(itemFile.absolutePath)
    }
}
