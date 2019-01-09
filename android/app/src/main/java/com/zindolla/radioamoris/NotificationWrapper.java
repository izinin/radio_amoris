package com.zindolla.radioamoris;

import android.app.Application;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;
import android.util.Log;

public class NotificationWrapper extends io.flutter.app.FlutterApplication {
    public static final String CHANNEL_ID = "RadioAmorisServiceChannel";
    private final static String TAG = NotificationWrapper.class.getSimpleName();

    @Override
    public void onCreate() {
        super.onCreate();

        createNotificationChannel();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "Radio Amoris",
                    NotificationManager.IMPORTANCE_DEFAULT
            );

            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(serviceChannel);
            }else{
                Log.e(TAG, "cannot obtain NotificationManager");
            }
        }
    }
}
