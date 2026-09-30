package com.multimax.maxie

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

/** App identity only. Window contents and typed text are never retrieved. */
class MaxieYouTubeAccessibilityService : AccessibilityService() {
    override fun onServiceConnected() { MaxieIntegrationBridge.start(this) }
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val pkg = event.packageName?.toString() ?: return
        MaxieIntegrationBridge.foreground(this, pkg)
    }
    override fun onInterrupt() = Unit
}
