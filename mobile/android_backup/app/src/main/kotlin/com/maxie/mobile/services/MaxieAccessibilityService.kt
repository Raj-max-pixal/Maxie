package com.maxie.mobile.services

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.content.Intent
import android.graphics.Path
import android.view.accessibility.AccessibilityEvent
import io.flutter.plugin.common.MethodChannel

class MaxieAccessibilityService : AccessibilityService() {
    
    private var currentPackage: String? = null
    private var currentApp: String? = null
    
    companion object {
        const val ACTION_APP_CHANGED = "com.maxie.mobile.APP_CHANGED"
        const val EXTRA_PACKAGE_NAME = "package_name"
        const val EXTRA_APP_NAME = "app_name"
        
        private lateinit var instance: MaxieAccessibilityService
        
        fun getInstance(): MaxieAccessibilityService {
            return instance
        }
        
        fun isServiceEnabled(): Boolean {
            return ::instance.isInitialized
        }
    }
    
    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }
    
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let {
            when (it.eventType) {
                AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                    val packageName = it.packageName?.toString()
                    if (packageName != null && packageName != currentPackage) {
                        currentPackage = packageName
                        currentApp = getAppName(packageName)
                        notifyAppChanged(packageName, currentApp ?: "Unknown")
                    }
                }
            }
        }
    }
    
    override fun onInterrupt() {
        // Not used
    }
    
    private fun getAppName(packageName: String): String {
        val appNames = mapOf(
            "com.whatsapp" to "WhatsApp",
            "com.instagram.android" to "Instagram",
            "com.spotify.music" to "Spotify",
            "com.google.android.youtube" to "YouTube",
            "com.facebook.katana" to "Facebook",
            "com.discord" to "Discord",
            "com.google.android.gm" to "Gmail",
            "com.linkedin.android" to "LinkedIn",
            "com.reddit.frontpage" to "Reddit",
            "com.twitter.android" to "Twitter",
            "com.snapchat.android" to "Snapchat",
            "com.tencent.ig" to "WeChat",
            "com.tencent.mm" to "WeChat",
            "com.netflix.mediaclient" to "Netflix",
            "com.amazon.avod.thirdpartyclient" to "Prime Video",
            "com.disney.disneyplus" to "Disney+",
            "com.google.android.apps.photos" to "Google Photos",
            "com.google.android.gallery3d" to "Gallery",
            "com.android.calculator2" to "Calculator",
            "com.android.calendar" to "Calendar",
            "com.android.deskclock" to "Clock",
            "com.google.android.apps.maps" to "Maps",
            "com.ubercab" to "Uber",
            "com.lyft.android" to "Lyft",
            "com.swiggy.android" to "Swiggy",
            "in.swiggy.android" to "Swiggy",
            "com.zomato.app" to "Zomato",
            "in.zomato.app" to "Zomato"
        )
        
        return appNames[packageName] ?: packageName.split(".").lastOrNull()?.capitalize() ?: "App"
    }
    
    private fun notifyAppChanged(packageName: String, appName: String) {
        val intent = Intent(ACTION_APP_CHANGED).apply {
            putExtra(EXTRA_PACKAGE_NAME, packageName)
            putExtra(EXTRA_APP_NAME, appName)
            // Send to Flutter via broadcast or method channel
        }
        sendBroadcast(intent)
        
        // Also send to Flutter if connected
        // This would typically use a MethodChannel or EventChannel
    }
    
    private fun String.capitalize(): String {
        return this.replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
    }
    
    fun getCurrentApp(): String? {
        return currentApp
    }
    
    fun getCurrentPackage(): String? {
        return currentPackage
    }
    
    override fun onDestroy() {
        super.onDestroy()
    }
}
