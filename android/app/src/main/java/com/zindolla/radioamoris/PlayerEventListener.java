package com.zindolla.radioamoris;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.media3.common.Metadata;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.extractor.metadata.icy.IcyHeaders;
import androidx.media3.extractor.metadata.icy.IcyInfo;

import java.util.HashMap;
import java.util.Map;

public class PlayerEventListener implements Player.Listener {
    private final Context context;
    public MyPlayerCommand currCmd = MyPlayerCommand.IDLE;
    private IcyInfo icyInfo;
    private IcyHeaders icyHeaders;

    public PlayerEventListener(Context context) {
        this.context = context;
    }

    @Override
    public void onPlaybackStateChanged(int playbackState) {
        Intent RTReturn = new Intent(MainActivity.PLAYER_STATE_LISTENER);
        RTReturn.putExtra("state", playbackState);
        RTReturn.putExtra("command", currCmd.ordinal());
        LocalBroadcastManager.getInstance(context).sendBroadcast(RTReturn);
    }

    @Override
    public void onMetadata(Metadata metadata) {
        for (int i = 0; i < metadata.length(); i++) {
            final Metadata.Entry entry = metadata.get(i);
            if (entry instanceof IcyInfo) {
                icyInfo = (IcyInfo) entry;
                Intent RTReturn = new Intent(MainActivity.CURRENTLY_PLAYING);
                RTReturn.putExtra("title", icyInfo.title == null ? "" : icyInfo.title);
                RTReturn.putExtra("url",  icyInfo.url == null ? "" : icyInfo.url);
                LocalBroadcastManager.getInstance(context).sendBroadcast(RTReturn);
            }
        }
    }
}
