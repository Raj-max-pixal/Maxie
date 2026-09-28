package com.multimax.maxie

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

/** Emits YouTube presence only after the user enables it in Android Settings. */
class MaxieYouTubeAccessibilityService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val packageName = event?.packageName?.toString() ?: return
        if (packageName == "com.google.android.youtube") {
            MaxieIntegrationBridge.emit("youtube", packageName)
        }
    }

    override fun onInterrupt() = Unit
}
