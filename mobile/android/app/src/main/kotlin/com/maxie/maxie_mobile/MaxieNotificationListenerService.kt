package com.multimax.maxie

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

/** Sends app name/title events after the user enables Notification Access. */
class MaxieNotificationListenerService : NotificationListenerService() {
    override fun onNotificationPosted(notification: StatusBarNotification) {
        val title = notification.notification.extras
            .getCharSequence("android.title")?.toString().orEmpty()
        MaxieIntegrationBridge.emit("notification", notification.packageName, title)
    }
}
