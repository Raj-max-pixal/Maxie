package com.multimax.maxie

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Native entry point for explicitly enabled Android integrations. */
class MainActivity : FlutterActivity() {
    private val nativeChannel = "com.maxie.mobile/native"
    private val eventsChannel = "com.maxie.mobile/integration_events"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, nativeChannel)
            .setMethodCallHandler(::handleMethod)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventsChannel)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    MaxieIntegrationBridge.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    MaxieIntegrationBridge.eventSink = null
                }
            })
    }

    private fun handleMethod(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkOverlayPermission" -> result.success(Settings.canDrawOverlays(this))
            "requestOverlayPermission" -> {
                startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION))
                result.success(null)
            }
            "checkAccessibilityPermission" -> result.success(isAccessibilityEnabled())
            "openAccessibilitySettings" -> {
                startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                result.success(null)
            }
            "checkNotificationPermission" -> result.success(isNotificationListenerEnabled())
            "openNotificationSettings" -> {
                startActivity(Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS"))
                result.success(null)
            }
            "getActiveMediaSessions" -> result.success(activeMediaSessions())
            else -> result.notImplemented()
        }
    }

    private fun isNotificationListenerEnabled(): Boolean {
        val enabled = Settings.Secure.getString(contentResolver, "enabled_notification_listeners") ?: return false
        return enabled.split(':').any { ComponentName.unflattenFromString(it)?.packageName == packageName }
    }

    private fun isAccessibilityEnabled(): Boolean {
        val enabled = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES) ?: return false
        return enabled.split(':').any {
            ComponentName.unflattenFromString(it)?.className == MaxieYouTubeAccessibilityService::class.java.name
        }
    }

    private fun activeMediaSessions(): List<Map<String, String>> {
        if (!isNotificationListenerEnabled()) return emptyList()
        val manager = getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager
        return manager.getActiveSessions(null).map { controller: MediaController ->
            mapOf(
                "package" to controller.packageName,
                "state" to (controller.playbackState?.state?.toString() ?: "unknown"),
                "title" to (controller.metadata?.getString("android.media.metadata.TITLE") ?: ""),
            )
        }
    }
}
