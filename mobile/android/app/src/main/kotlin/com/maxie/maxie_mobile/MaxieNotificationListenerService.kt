package com.multimax.maxie

import android.service.notification.NotificationListenerService

/** Enables media-session queries after explicit Notification Access approval. */
class MaxieNotificationListenerService : NotificationListenerService() {
    override fun onListenerConnected() { MaxieIntegrationBridge.start(this) }
}
