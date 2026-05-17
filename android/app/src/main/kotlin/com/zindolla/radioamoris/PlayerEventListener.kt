package com.zindolla.radioamoris

import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.media3.common.Metadata
import androidx.media3.common.Player
import androidx.media3.extractor.metadata.icy.IcyInfo

class PlayerEventListener(private val context: Context) : Player.Listener {
    var currCmd = MyPlayerCommand.IDLE
    private var icyInfo: IcyInfo? = null

    companion object {
        val LOGTAG: String = PlayerEventListener::class.java.simpleName
    }

    override fun onPlaybackStateChanged(playbackState: Int) {
        val RTReturn = Intent(MainActivity.PLAYER_STATE_LISTENER)
        RTReturn.putExtra("state", playbackState)
        RTReturn.putExtra("command", currCmd.ordinal)
        LocalBroadcastManager.getInstance(context).sendBroadcast(RTReturn)
    }

    override fun onMetadata(metadata: Metadata) {
        for (i in 0 until metadata.length()) {
            val entry = metadata[i]
            if (entry is IcyInfo) {
                icyInfo = entry
                Log.w(LOGTAG, "received stream metadata: $icyInfo")
            }
        }
    }
}
