package com.zindolla.radioamoris

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.NotificationManager.IMPORTANCE_LOW
import android.os.Build
import android.util.Log
import io.flutter.app.FlutterApplication

class MainApplication : FlutterApplication() {
    companion object {
        const val CHANNEL_ID = "myRadioServiceChannel"
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "MyRadio Service Channel",
                IMPORTANCE_LOW
            )

            val manager = getSystemService(NotificationManager::class.java)
            if (manager != null) {
                manager.createNotificationChannel(serviceChannel)
            } else {
                Log.e(MainActivity.LOGTAG, "cannot obtain NotificationManager")
            }
        }
    }
}
