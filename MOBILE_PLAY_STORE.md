# MAXie Android / Play Store Release

MAXie mobile is packaged with Capacitor so the existing local-first companion UI can ship as a native Android app bundle.

## Build Locally

1. Install Android Studio with the Android SDK and JDK.
2. Run `npm install` if dependencies are missing.
3. Run `npm run mobile:sync` to prepare `mobile/www` and sync the Android project.
4. Open Android Studio with `npm run mobile:open`.
5. Create a release signing key in Android Studio.
6. Build a signed Android App Bundle (`.aab`) from Android Studio, or run `npm run mobile:build` after signing is configured.

## Command-Line Signing

Create or choose a Play upload keystore, then set these environment variables before running `npm run mobile:build`:

```powershell
$env:MAXIE_UPLOAD_STORE_FILE="C:\path\to\maxie-upload.keystore"
$env:MAXIE_UPLOAD_STORE_PASSWORD="your-store-password"
$env:MAXIE_UPLOAD_KEY_ALIAS="maxie-upload"
$env:MAXIE_UPLOAD_KEY_PASSWORD="your-key-password"
npm run mobile:build
```

Do not commit keystores or passwords. The generated unsigned validation bundle is useful for testing, but Play production upload should use your upload key.

## Play Console Checklist

- Package name: `com.maxie.mobile`.
- Target SDK: keep Android target at API 35 or higher for new Google Play submissions.
- Upload format: Android App Bundle (`.aab`).
- Start with Internal testing before production.
- Add store listing copy, screenshots, app icon, feature graphic, privacy policy URL, and data safety answers.
- Confirm MAXie does not claim background device monitoring on mobile unless that feature is implemented with explicit Android permissions.

## Notes

The Android version uses the browser-safe companion experience from `index.html`, `styles.css`, and `app.js`. Desktop-only Electron features such as system active-app detection, always-on-top transparent windows, tray controls, and startup launch remain desktop features unless implemented with native Android plugins later.
