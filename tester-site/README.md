# MAXie Mobile Test Site

This folder is a static download site for sharing the Android APK with testers before Play Store release.

## Deploy Free On Vercel

1. Create a free Vercel account.
2. Install the Vercel CLI or import this repository in the Vercel dashboard.
3. Use `tester-site` as the project root.
4. Deploy.
5. Share the generated URL with Android testers.

## Deploy From Command Line

```powershell
cd tester-site
npx vercel
```

When asked, choose this folder as the project root. The APK lives at `downloads/maxie-android-test.apk`.

## Safer Alternative

For a cleaner tester experience, upload the APK or AAB to Google Play Internal App Sharing and put that Play testing link on this page instead of the direct APK.
