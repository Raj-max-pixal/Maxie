package com.maxie.mobile;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.graphics.Region;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.view.Gravity;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.WindowManager;
import android.webkit.WebSettings;
import android.webkit.WebView;
import androidx.core.app.NotificationCompat;
import org.json.JSONArray;
import org.json.JSONObject;

public class ShimejiService extends Service {
    private static final String CHANNEL_ID = "MAXieShimejiChannel";
    private static final int NOTIFICATION_ID = 9527;

    private WindowManager windowManager;
    private WebView webView;
    private WindowManager.LayoutParams params;
    private final Region petRegion = new Region();

    @Override
    public void onCreate() {
        super.onCreate();
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
        
        // Show persistent notification to keep service alive in foreground
        showForegroundNotification();

        // Create WebView
        webView = new WebView(this);
        webView.setBackgroundColor(0); // Transparent background
        
        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setAllowFileAccess(true);
        settings.setAllowContentAccess(true);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            settings.setMediaPlaybackRequiresUserGesture(false);
        }
        
        // Transparent drawing layer
        webView.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        
        // Expose bridge interface to JS overlay
        webView.addJavascriptInterface(new ShimejiBridge(), "AndroidShimeji");
        
        // Set layout parameters for full screen transparent window overlay
        int layoutType;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            layoutType = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else {
            layoutType = WindowManager.LayoutParams.TYPE_PHONE;
        }

        params = new WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            layoutType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE |
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        );
        params.gravity = Gravity.TOP | Gravity.LEFT;
        params.x = 0;
        params.y = 0;

        // Add view to window manager
        windowManager.addView(webView, params);

        // Touch interception optimization using Java Reflection to access hidden ViewTreeObserver APIs
        try {
            final Class<?> listenerClass = Class.forName("android.view.ViewTreeObserver$OnComputeInternalInsetsListener");
            Class<?> insetsInfoClass = Class.forName("android.view.ViewTreeObserver$InternalInsetsInfo");
            final java.lang.reflect.Method setTouchableInsetsMethod = insetsInfoClass.getMethod("setTouchableInsets", int.class);
            final java.lang.reflect.Field touchableRegionField = insetsInfoClass.getField("touchableRegion");

            Object listener = java.lang.reflect.Proxy.newProxyInstance(
                getClass().getClassLoader(),
                new Class<?>[]{listenerClass},
                new java.lang.reflect.InvocationHandler() {
                    @Override
                    public Object invoke(Object proxy, java.lang.reflect.Method method, Object[] args) throws Throwable {
                        if (method.getName().equals("onComputeInternalInsets")) {
                            Object insetsInfo = args[0];
                            // 3 corresponds to TOUCHABLE_INSETS_REGION in InternalInsetsInfo
                            setTouchableInsetsMethod.invoke(insetsInfo, 3);
                            Region region = (Region) touchableRegionField.get(insetsInfo);
                            if (region != null) {
                                region.set(petRegion);
                            }
                        }
                        return null;
                    }
                }
            );

            java.lang.reflect.Method addListenerMethod = ViewTreeObserver.class.getMethod(
                "addOnComputeInternalInsetsListener",
                listenerClass
            );
            addListenerMethod.invoke(webView.getViewTreeObserver(), listener);
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Load overlay page from assets
        webView.loadUrl("file:///android_asset/public/shimeji.html");
    }

    private void showForegroundNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                CHANNEL_ID,
                "MAXie Screen Pet Service",
                NotificationManager.IMPORTANCE_LOW
            );
            NotificationManager manager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
        }

        // Action intent to stop pet overlay from notification
        Intent stopIntent = new Intent(this, ShimejiService.class);
        stopIntent.putExtra("action", "STOP_SERVICE");
        
        int flag = PendingIntent.FLAG_UPDATE_CURRENT;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            flag |= PendingIntent.FLAG_IMMUTABLE;
        }
        
        PendingIntent pendingStop = PendingIntent.getService(this, 1, stopIntent, flag);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("MAXie screen pet is active")
            .setContentText("Your companion is walking on your screen.")
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .setOngoing(true)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Remove Pet", pendingStop);

        startForeground(NOTIFICATION_ID, builder.build());
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null) {
            String action = intent.getStringExtra("action");
            if ("STOP_SERVICE".equals(action)) {
                stopSelf();
                return START_NOT_STICKY;
            }

            // Sync state from plugin
            final String state = intent.getStringExtra("state");
            if (state != null) {
                getSharedPreferences("ShimejiPrefs", MODE_PRIVATE).edit().putString("state", state).apply();
                webView.post(new Runnable() {
                    @Override
                    public void run() {
                        webView.evaluateJavascript("if (window.onStateUpdated) window.onStateUpdated(" + state + ");", null);
                    }
                });
            }
        }
        return START_STICKY;
    }

    private class ShimejiBridge {
        @android.webkit.JavascriptInterface
        public void updatePetRegions(final String json) {
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    try {
                        JSONArray array = new JSONArray(json);
                        Region newRegion = new Region();
                        for (int i = 0; i < array.length(); i++) {
                            JSONObject obj = array.getJSONObject(i);
                            int x = obj.getInt("x");
                            int y = obj.getInt("y");
                            int w = obj.getInt("width");
                            int h = obj.getInt("height");
                            newRegion.op(x, y, x + w, y + h, Region.Op.UNION);
                        }
                        petRegion.set(newRegion);
                        webView.postInvalidate();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });
        }

        @android.webkit.JavascriptInterface
        public void saveState(String jsonState) {
            getSharedPreferences("ShimejiPrefs", MODE_PRIVATE).edit().putString("state", jsonState).apply();
        }

        @android.webkit.JavascriptInterface
        public String loadState() {
            return getSharedPreferences("ShimejiPrefs", MODE_PRIVATE).getString("state", "{}");
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (windowManager != null && webView != null) {
            windowManager.removeView(webView);
            webView.destroy();
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
