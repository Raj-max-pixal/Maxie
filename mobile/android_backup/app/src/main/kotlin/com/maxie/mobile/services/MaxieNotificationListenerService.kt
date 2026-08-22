package com.maxie.mobile.services

import android.app.Notification
import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

class MaxieNotificationListenerService : NotificationListenerService() {
    
    companion object {
        const val ACTION_NOTIFICATION_POSTED = "com.maxie.mobile.NOTIFICATION_POSTED"
        const val EXTRA_PACKAGE_NAME = "package_name"
        const val EXTRA_APP_NAME = "app_name"
        const val EXTRA_TITLE = "title"
        const val EXTRA_TEXT = "text"
        
        private lateinit var instance: MaxieNotificationListenerService
        
        fun getInstance(): MaxieNotificationListenerService {
            return instance
        }
        
        fun isServiceEnabled(): Boolean {
            return ::instance.isInitialized
        }
    }
    
    private val targetApps = listOf(
        "com.whatsapp",
        "com.instagram.android",
        "com.spotify.music",
        "com.facebook.katana",
        "com.discord",
        "com.google.android.gm",
        "com.linkedin.android",
        "com.reddit.frontpage",
        "com.twitter.android",
        "com.snapchat.android",
        "com.google.android.youtube"
    )
    
    override fun onCreate() {
        super.onCreate()
        instance = this
    }
    
    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        
        sbn?.let { notification ->
            val packageName = notification.packageName
            
            // Only react to notifications from target apps
            if (packageName in targetApps) {
                val extras = notification.notification.extras
                val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
                val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
                val appName = getAppName(packageName)
                
                // Send notification event to Flutter
                sendNotificationEvent(packageName, appName, title, text)
            }
        }
    }
    
    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        super.onNotificationRemoved(sbn)
    }
    
    private fun getAppName(packageName: String): String {
        val appNames = mapOf(
            "com.whatsapp" to "WhatsApp",
            "com.instagram.android" to "Instagram",
            "com.spotify.music" to "Spotify",
            "com.facebook.katana" to "Facebook",
            "com.discord" to "Discord",
            "com.google.android.gm" to "Gmail",
            "com.linkedin.android" to "LinkedIn",
            "com.reddit.frontpage" to "Reddit",
            "com.twitter.android" to "Twitter",
            "com.snapchat.android" to "Snapchat",
            "com.google.android.youtube" to "YouTube"
        )
        
        return appNames[packageName] ?: packageName.split(".").lastOrNull()?.capitalize() ?: "App"
    }
    
    private fun sendNotificationEvent(packageName: String, appName: String, title: String, text: String) {
        val intent = Intent(ACTION_NOTIFICATION_POSTED).apply {
            putExtra(EXTRA_PACKAGE_NAME, packageName)
            putExtra(EXTRA_APP_NAME, appName)
            putExtra(EXTRA_TITLE, title)
            putExtra(EXTRA_TEXT, text)
        }
        sendBroadcast(intent)
        
        Log.d("MAXie", "Notification from $appName: $title - $text")
    }
    
    private fun String.capitalize(): String {
        return this.replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
    }
    
    override fun onDestroy() {
        super.onDestroy()
    }
}
