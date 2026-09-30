# MAXie Play Store Release Checklist

## Local Validation

```bash
flutter pub get
dart analyze lib test
flutter test
flutter run
```

## Required Before Internal Testing

- Create final app icon and adaptive Android icon.
- Add privacy policy page at `https://maxie.app/privacy` or update `AppConstants.privacyPolicy`.
- Add terms page at `https://maxie.app/terms` or update `AppConstants.termsOfService`.
- Create RevenueCat products and entitlement in the RevenueCat dashboard.
- Create matching subscriptions in Google Play Console.
- Add the public RevenueCat Android SDK key when running or building.
- Create upload keystore and add `android/key.properties`.

Example `android/key.properties`:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=maxie
storeFile=C:\\path\\to\\maxie-upload-key.jks
```

Do not commit `key.properties` or `.jks` files.

## Build Commands

Debug emulator:

```bash
flutter run
```

RevenueCat/Gemini demo:

```bash
flutter run --dart-define=REVENUECAT_ANDROID_API_KEY=googl_your_public_key --dart-define=GEMINI_API_KEY=your_key
```

Play Store app bundle:

```bash
flutter build appbundle --release --dart-define=REVENUECAT_ANDROID_API_KEY=googl_your_public_key --dart-define=GEMINI_API_KEY=your_key
```

## Store Listing Draft

Short description:

MAXie is an AI companion that remembers you, grows with you, and turns daily chats into a living Memory Brain.

Full description:

Meet MAXie, your personal AI companion for memory, mood, and motivation. Chat with MAXie, save meaningful facts into Memory Brain, and watch your companion grow through friendship XP and mood changes. MAXie Plus adds premium companion features such as voice, cloud memory sync, and advanced personalization.

## Production Risks To Clear

- Native overlay/shimeji mode must be implemented with Android service permissions before it is marketed as always-on.
- Gemini and RevenueCat keys must be production dashboard keys, not test placeholders.
- Privacy policy must explain AI chat processing, local storage, purchases, and future cloud sync.
- Subscription wording must match the exact Play Console products.
