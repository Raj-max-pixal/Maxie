package com.maxie.mobile.services

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import com.maxie.mobile.R

class MaxieOverlayService : Service() {
    
    private lateinit var windowManager: WindowManager
    private lateinit var overlayView: View
    private var initialX: Int = 0
    private var initialY: Int = 0
    private var initialTouchX: Float = 0
    private var initialTouchY: Float = 0
    
    companion object {
        const val ACTION_SHOW = "com.maxie.mobile.SHOW_OVERLAY"
        const val ACTION_HIDE = "com.maxie.mobile.HIDE_OVERLAY"
        const val ACTION_UPDATE_POSITION = "com.maxie.mobile.UPDATE_POSITION"
        const val EXTRA_X = "extra_x"
        const val EXTRA_Y = "extra_y"
        
        fun startService(context: Context) {
            val intent = Intent(context, MaxieOverlayService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
        
        fun stopService(context: Context) {
            val intent = Intent(context, MaxieOverlayService::class.java)
            context.stopService(intent)
        }
    }
    
    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        createOverlay()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_SHOW -> showOverlay()
            ACTION_HIDE -> hideOverlay()
            ACTION_UPDATE_POSITION -> {
                val x = intent.getIntExtra(EXTRA_X, 100)
                val y = intent.getIntExtra(EXTRA_Y, 100)
                updateOverlayPosition(x, y)
            }
        }
        return START_STICKY
    }
    
    private fun createOverlay() {
        overlayView = LayoutInflater.from(this).inflate(R.layout.maxie_overlay, null)
        
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            },
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT
        )
        
        params.gravity = Gravity.TOP or Gravity.START
        params.x = 100
        params.y = 100
        
        overlayView.setOnTouchListener(object : View.OnTouchListener {
            override fun onTouch(view: View, event: MotionEvent): Boolean {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = params.x
                        initialY = params.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        params.x = initialX + (event.rawX - initialTouchX).toInt()
                        params.y = initialY + (event.rawY - initialTouchY).toInt()
                        windowManager.updateViewLayout(overlayView, params)
                        return true
                    }
                    MotionEvent.ACTION_UP -> {
                        // Save position to preferences
                        savePosition(params.x, params.y)
                        return true
                    }
                }
                return false
            }
        })
        
        windowManager.addView(overlayView, params)
    }
    
    private fun showOverlay() {
        if (!::overlayView.isInitialized || overlayView.windowToken == null) {
            createOverlay()
        }
        overlayView.visibility = View.VISIBLE
    }
    
    private fun hideOverlay() {
        overlayView.visibility = View.GONE
    }
    
    private fun updateOverlayPosition(x: Int, y: Int) {
        val params = overlayView.layoutParams as WindowManager.LayoutParams
        params.x = x
        params.y = y
        windowManager.updateViewLayout(overlayView, params)
    }
    
    private fun savePosition(x: Int, y: Int) {
        val prefs = getSharedPreferences("maxie_overlay", Context.MODE_PRIVATE)
        prefs.edit()
            .putInt("overlay_x", x)
            .putInt("overlay_y", y)
            .apply()
    }
    
    private fun loadPosition(): Pair<Int, Int> {
        val prefs = getSharedPreferences("maxie_overlay", Context.MODE_PRIVATE)
        val x = prefs.getInt("overlay_x", 100)
        val y = prefs.getInt("overlay_y", 100)
        return Pair(x, y)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        if (::overlayView.isInitialized && overlayView.windowToken != null) {
            windowManager.removeView(overlayView)
        }
    }
    
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
