package com.maxie.mobile;

import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.provider.Settings;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "Shimeji")
public class ShimejiPlugin extends Plugin {
    private static final int OVERLAY_PERMISSION_REQ_CODE = 8848;

    @PluginMethod
    public void checkOverlayPermission(PluginCall call) {
        boolean hasPermission = true;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            hasPermission = Settings.canDrawOverlays(getContext());
        }
        JSObject ret = new JSObject();
        ret.put("hasPermission", hasPermission);
        call.resolve(ret);
    }

    @PluginMethod
    public void requestOverlayPermission(PluginCall call) {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(getContext())) {
                Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:" + getContext().getPackageName()));
                getActivity().startActivityForResult(intent, OVERLAY_PERMISSION_REQ_CODE);
                saveCall(call);
                return;
            }
        }
        JSObject ret = new JSObject();
        ret.put("hasPermission", true);
        call.resolve(ret);
    }

    @Override
    protected void handleOnActivityResult(int requestCode, int resultCode, Intent data) {
        super.handleOnActivityResult(requestCode, resultCode, data);
        if (requestCode == OVERLAY_PERMISSION_REQ_CODE) {
            PluginCall savedCall = getSavedCall();
            if (savedCall != null) {
                boolean hasPermission = true;
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                    hasPermission = Settings.canDrawOverlays(getContext());
                }
                JSObject ret = new JSObject();
                ret.put("hasPermission", hasPermission);
                savedCall.resolve(ret);
            }
        }
    }

    @PluginMethod
    public void startOverlay(PluginCall call) {
        String state = call.getString("state", "{}");
        Intent intent = new Intent(getContext(), ShimejiService.class);
        intent.putExtra("state", state);
        getContext().startService(intent);
        call.resolve();
    }

    @PluginMethod
    public void stopOverlay(PluginCall call) {
        Intent intent = new Intent(getContext(), ShimejiService.class);
        getContext().stopService(intent);
        call.resolve();
    }

    @PluginMethod
    public void isOverlayRunning(PluginCall call) {
        boolean isRunning = false;
        ActivityManager manager = (ActivityManager) getContext().getSystemService(Context.ACTIVITY_SERVICE);
        if (manager != null) {
            for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
                if (ShimejiService.class.getName().equals(service.service.getClassName())) {
                    isRunning = true;
                    break;
                }
            }
        }
        JSObject ret = new JSObject();
        ret.put("running", isRunning);
        call.resolve(ret);
    }

    @PluginMethod
    public void updatePetSettings(PluginCall call) {
        String state = call.getString("state", "{}");
        Intent intent = new Intent(getContext(), ShimejiService.class);
        intent.putExtra("state", state);
        getContext().startService(intent);
        call.resolve();
    }
}
