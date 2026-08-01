package com.example.ezmoov_partner_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val onlineChannel = NotificationChannel(
                "ezmoov_driver_online_channel",
                "EZMoov Driver Online Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Persistent notification for active online driver background service"
            }

            val incomingRideChannel = NotificationChannel(
                "incoming_ride_channel",
                "Incoming Ride Requests",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "High-priority notifications for incoming driver ride requests"
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager?.createNotificationChannel(onlineChannel)
            notificationManager?.createNotificationChannel(incomingRideChannel)
        }
    }
}
