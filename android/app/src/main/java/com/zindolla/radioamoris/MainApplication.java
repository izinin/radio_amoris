package com.zindolla.radioamoris;

import static android.app.NotificationManager.IMPORTANCE_LOW;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;
import android.util.Log;

public class MainApplication extends io.flutter.app.FlutterApplication {
    public static final String CHANNEL_ID = "myRadioServiceChannel";

    @Override
    public void onCreate() {
        super.onCreate();

        createNotificationChannel();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "MyRadio Service Channel",
                    IMPORTANCE_LOW
            );

            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(serviceChannel);
            }else{
                Log.e(MainActivity.LOGTAG, "cannot obtain NotificationManager");
            }
        }
    }
}
