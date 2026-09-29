package com.multimax.maxie

import android.app.KeyguardManager
import android.content.ComponentName
import android.content.Context
import android.content.pm.ApplicationInfo
import android.media.MediaMetadata
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.JSONMessageCodec
import io.flutter.plugin.common.EventChannel

/** Ephemeral metadata only; no screenshots, notification bodies or UI text. */
object MaxieIntegrationBridge {
    @Volatile var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())
    private var started = false
    private var foreground = ""
    private val videoApps = setOf("com.google.android.youtube", "com.netflix.mediaclient", "com.amazon.avod.thirdpartyclient", "in.startv.hotstar", "com.jio.hotstar", "org.videolan.vlc", "com.mxtech.videoplayer.ad")

    fun start(context: Context) {
        if (started) return
        started = true
        val app = context.applicationContext
        handler.post(object : Runnable {
            override fun run() {
                publish(app)
                handler.postDelayed(this, 3000)
            }
        })
    }

    fun foreground(context: Context, pkg: String) {
        if (pkg == context.packageName) return
        foreground = pkg
        start(context)
    }

    fun emit(type: String, packageName: String, title: String = "") {
        handler.post { eventSink?.success(mapOf("type" to type, "package" to packageName, "title" to title)) }
    }

    private fun publish(context: Context) {
        val engine = FlutterEngineCache.getInstance().get("myCachedEngine") ?: return
        val locked = (context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager).isKeyguardLocked
        val access = Settings.Secure.getString(context.contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES).orEmpty()
            .split(':').any { ComponentName.unflattenFromString(it)?.className == MaxieYouTubeAccessibilityService::class.java.name }
        var pkg = if (access && !locked) foreground else ""
        var title = ""
        var artist = ""
        var playing = false
        val listener = ComponentName(context, MaxieNotificationListenerService::class.java)
        val notifications = Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners").orEmpty()
            .split(':').any { ComponentName.unflattenFromString(it) == listener }
        if (notifications && !locked) {
            try {
                val manager = context.getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager
                val media = manager.getActiveSessions(listener).firstOrNull {
                    it.playbackState?.state == PlaybackState.STATE_PLAYING
                }
                if (media != null) {
                    pkg = media.packageName
                    title = media.metadata?.getString(MediaMetadata.METADATA_KEY_TITLE).orEmpty().take(160)
                    artist = media.metadata?.getString(MediaMetadata.METADATA_KEY_ARTIST).orEmpty().take(100)
                    playing = true
                }
            } catch (_: SecurityException) { /* Permission may be revoked between checks. */ }
        }
        var label = pkg
        var game = false
        if (pkg.isNotEmpty()) {
            try {
                val info = context.packageManager.getApplicationInfo(pkg, 0)
                label = context.packageManager.getApplicationLabel(info).toString().take(80)
                game = if (Build.VERSION.SDK_INT >= 26) info.category == ApplicationInfo.CATEGORY_GAME
                    else (info.flags and ApplicationInfo.FLAG_IS_GAME) != 0
            } catch (_: Exception) { }
        }
        val category = when {
            locked || pkg.isEmpty() -> "idle"
            game -> "game"
            videoApps.contains(pkg) -> "video"
            playing -> "music"
            else -> "app"
        }
        // Never forward arbitrary app names (banking, messages, etc.) to AI.
        val supported = category in setOf("music", "video", "game")
        BasicMessageChannel<Any>(engine.dartExecutor.binaryMessenger,
            "x-slayer/overlay_messenger", JSONMessageCodec.INSTANCE).send(mapOf(
                "type" to "activity_context", "category" to category,
                "app" to if (supported) label else "", "title" to title,
                "artist" to artist, "playing" to playing,
                "timestamp" to System.currentTimeMillis()
            ))
    }
}
