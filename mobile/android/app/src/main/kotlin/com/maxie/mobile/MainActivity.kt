package com.maxie.mobile

import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.maxie.mobile/native"
    private val OVERLAY_CHANNEL = "com.maxie.mobile/overlay"
    private val ACCESSIBILITY_CHANNEL = "com.maxie.mobile/accessibility"
    private val NOTIFICATION_CHANNEL = "com.maxie.mobile/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Main native channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkOverlayPermission" -> {
                    result.success(checkOverlayPermission())
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(null)
                }
                "checkAccessibilityPermission" -> {
                    result.success(checkAccessibilityPermission())
                }
                "openAccessibilitySettings" -> {
                    openAccessibilitySettings()
                    result.success(null)
                }
                "checkNotificationPermission" -> {
                    result.success(checkNotificationPermission())
                }
                "openNotificationSettings" -> {
                    openNotificationSettings()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        
        // Overlay service channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OVERLAY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startOverlay" -> {
                    com.maxie.mobile.services.MaxieOverlayService.startService(this)
                    result.success(null)
                }
                "stopOverlay" -> {
                    com.maxie.mobile.services.MaxieOverlayService.stopService(this)
                    result.success(null)
                }
                "updateOverlayPosition" -> {
                    val x = call.argument<Int>("x") ?: 100
                    val y = call.argument<Int>("y") ?: 100
                    val intent = Intent(this, com.maxie.mobile.services.MaxieOverlayService::class.java).apply {
                        action = com.maxie.mobile.services.MaxieOverlayService.ACTION_UPDATE_POSITION
                        putExtra(com.maxie.mobile.services.MaxieOverlayService.EXTRA_X, x)
                        putExtra(com.maxie.mobile.services.MaxieOverlayService.EXTRA_Y, y)
                    }
                    startService(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun checkOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }
    
    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                android.net.Uri.parse("package:$packageName")
            )
            startActivity(intent)
        }
    }
    
    private fun checkAccessibilityPermission(): Boolean {
        val service = com.maxie.mobile.services.MaxieAccessibilityService.getInstance()
        return com.maxie.mobile.services.MaxieAccessibilityService.isServiceEnabled()
    }
    
    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }
    
    private fun checkNotificationPermission(): Boolean {
        val service = com.maxie.mobile.services.MaxieNotificationListenerService.getInstance()
        return com.maxie.mobile.services.MaxieNotificationListenerService.isServiceEnabled()
    }
    
    private fun openNotificationSettings() {
        val intent = Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
        startActivity(intent)
    }
}
