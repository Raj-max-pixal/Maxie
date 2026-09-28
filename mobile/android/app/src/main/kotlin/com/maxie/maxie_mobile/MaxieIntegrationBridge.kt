package com.multimax.maxie

import io.flutter.plugin.common.EventChannel

/** Delivers only consented system events while the Flutter app is open. */
object MaxieIntegrationBridge {
    @Volatile var eventSink: EventChannel.EventSink? = null

    fun emit(type: String, packageName: String, title: String = "") {
        eventSink?.success(mapOf("type" to type, "package" to packageName, "title" to title))
    }
}
