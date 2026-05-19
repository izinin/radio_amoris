package com.zindolla.radioamoris

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.ResultReceiver
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.media3.exoplayer.ExoPlayer
import com.google.common.collect.ImmutableMap
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    companion object {
        const val TOSERVICE_TUNE_ID = "tune.id"
        const val TOSERVICE_TUNE_NAME = "tune.name"
        const val TOSERVICE_TUNE_URL = "tune.url"
        const val TOSERVICE_TUNE_LOGO = "tune.logo"
        const val TOSERVICE_TUNE_ASSETLOGO = "tune.asset.logo"
        private const val PLAYER_CMD_METHOD_CHANNEL = "com.zindolla.radioamoris/audio"
        private const val PLAYER_STATE_STREAM_CHANNEL = "com.zindolla.radioamoris/player-state"
        private const val PLAYLIST_CTRL_STREAM_CHANNEL = "com.zindolla.radioamoris/playlist-ctrl"

        val LOGTAG: String = MainActivity::class.java.simpleName

        @JvmStatic
        var playerStateEvent: EventChannel.EventSink? = null
        @JvmStatic
        var currentlyPlayingEvent: EventChannel.EventSink? = null
        @JvmStatic
        var playlistCtrlEvent: EventChannel.EventSink? = null

        const val PLAYER_STATE_LISTENER = "com.zindolla.radioamoris.PLAYER_STATE"
        const val PLAYLIST_CTRL = "com.zindolla.radioamoris.PLAYLIST_CTRL"
    }

    private var channel: MethodChannel? = null
    private var playerStateNotifManager: LocalBroadcastManager? = null

    private val playerStateListener = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == PLAYER_STATE_LISTENER) {
                val state = intent.getIntExtra("state", ExoPlayer.STATE_ENDED)
                val command = intent.getIntExtra("command", MyPlayerCommand.PLAY.ordinal)
                playerStateEvent?.success(ImmutableMap.of("state", state, "command", command))
            }
        }
    }

    private val playlistCtrlListener = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val isForward = intent.getBooleanExtra("isForward", true)
            if (intent.action == PLAYLIST_CTRL) {
                playlistCtrlEvent?.success(isForward)
            }
        }
    }

    private fun foregroundService(intent: Intent) {
        Log.w(LOGTAG, "starting foreground service with SDK: ${Build.VERSION.SDK_INT}")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            this.startForegroundService(intent)
        } else {
            ContextCompat.startForegroundService(this, intent)
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PLAYER_CMD_METHOD_CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            val intent = Intent(applicationContext, MyRadioService::class.java)
            var action: String? = null
            when (call.method) {
                "exoPlayerStart" -> {
                    val tuneId = getMethodChannelVal<Int>("id", call, result)
                    val tuneUrl = getMethodChannelVal<String>("url", call, result)
                    val tuneName = getMethodChannelVal<String>("name", call, result)
                    val tuneLogo = call.argument<String>("logo") ?: ""
                    val tuneAssetLogo = call.argument<String>("assetLogo") ?: ""

                    intent.putExtra(TOSERVICE_TUNE_ID, tuneId)
                    intent.putExtra(TOSERVICE_TUNE_NAME, tuneName)
                    intent.putExtra(TOSERVICE_TUNE_URL, tuneUrl)
                    intent.putExtra(TOSERVICE_TUNE_LOGO, tuneLogo)
                    intent.putExtra(TOSERVICE_TUNE_ASSETLOGO, tuneAssetLogo)
                    action = MyRadioService.AUDIO_START
                    result.success(null)
                }
                "exoPlayerPause" -> {
                    action = MyRadioService.AUDIO_PAUSE
                    result.success(null)
                }
                "exoPlayerResume" -> {
                    action = MyRadioService.AUDIO_RESUME
                    result.success(null)
                }
                else -> result.notImplemented()
            }
            if (action != null) {
                intent.action = action
                intent.putExtra(MyRadioService.BUNDLED_LISTENER, createReceiver(action))
                foregroundService(intent)
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, PLAYER_STATE_STREAM_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, events: EventChannel.EventSink) {
                    Log.w(LOGTAG, "Adding listener: playerStateEvent")
                    playerStateEvent = events
                }

                override fun onCancel(args: Any?) {
                    Log.w(LOGTAG, "Cancelling listener: playerStateEvent")
                    playerStateEvent = null
                }
            }
        )

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, PLAYLIST_CTRL_STREAM_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, events: EventChannel.EventSink) {
                    Log.w(LOGTAG, "Adding listener: playlistCtrlEvent")
                    playlistCtrlEvent = events
                }

                override fun onCancel(args: Any?) {
                    Log.w(LOGTAG, "Cancelling listener: playlistCtrlEvent")
                    playlistCtrlEvent = null
                }
            }
        )

        playerStateNotifManager = LocalBroadcastManager.getInstance(this)
        val istate = IntentFilter()
        istate.addAction(PLAYER_STATE_LISTENER)
        playerStateNotifManager?.registerReceiver(playerStateListener, istate)
        val plylistCtrl = IntentFilter()
        plylistCtrl.addAction(PLAYLIST_CTRL)
        playerStateNotifManager?.registerReceiver(playlistCtrlListener, plylistCtrl)
    }

    override fun onDestroy() {
        super.onDestroy()
        playerStateNotifManager?.unregisterReceiver(playerStateListener)
        playerStateNotifManager?.unregisterReceiver(playlistCtrlListener)
        val intent = Intent(applicationContext, MyRadioService::class.java)
        intent.action = MyRadioService.EXIT_SERVICE
        foregroundService(intent)
    }

    private fun <T> getMethodChannelVal(key: String, call: MethodCall, result: MethodChannel.Result): T? {
        val valT = call.argument<T>(key)
        if (valT == null) {
            result.error(call.method, "no '$key' specified", null)
        }
        return valT
    }

    private fun createReceiver(action: String): ResultReceiver {
        return object : ResultReceiver(Handler()) {
            override fun onReceiveResult(resultCode: Int, resultData: Bundle?) {
                super.onReceiveResult(resultCode, resultData)
                channel?.invokeMethod(if (resultCode == Activity.RESULT_OK) action else MyRadioService.AUDIO_ERROR, 0)
            }
        }
    }
}
