package com.maxie.mobile.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.maxie.mobile.services.MaxieOverlayService

class BootReceiver : BroadcastReceiver() {
    
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED || 
            intent?.action == "android.intent.action.QUICKBOOT_POWERON") {
            
            context?.let {
                // Check if overlay was enabled before reboot
                val prefs = it.getSharedPreferences("maxie_settings", Context.MODE_PRIVATE)
                val overlayEnabled = prefs.getBoolean("overlayEnabled", false)
                
                if (overlayEnabled) {
                    MaxieOverlayService.startService(it)
                }
            }
        }
    }
}
