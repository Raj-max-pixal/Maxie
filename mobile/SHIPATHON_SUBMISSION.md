# MAXie Shipathon Submission

## One-Line Pitch

MAXie is a mobile AI companion that remembers what matters about you, grows with every chat, and turns real progress into a consent-based shareable moment.

## Why It Can Win

- RevenueCat is part of the core product loop, not an afterthought: MAXie Premium unlocks companion packs, cloud memory sync, and deeper personalization.
- The first demo is understandable in under one minute: chat, save a memory, return home, and watch the companion mood and XP change.
- The viral hook is built in: the Home screen generates a #BuildInPublic share post from the user journey.
- The startup path is clear: free emotional companion loop, paid subscription for deeper personalization, syncing, premium pets, voice, and overlays.

## Demo Flow For Judges

1. Launch MAXie.
2. Open Chat.
3. Send: `I am building MAXie for the RevenueCat Shipathon and my birthday is March 12.`
4. Save the suggested memory.
5. Return Home and show the Memory Brain count, recent memory, mood, XP, and share action.
6. Open MAXie Premium and show the configured offering, successful sandbox purchase, and restore.
7. Open Shimeji/Companion to show the interactive pet layer and Android floating-companion support.

## RevenueCat Setup

The RevenueCat dashboard must use the same entitlement and offering names supplied to the app. The current mobile default entitlement is `maxie_premium`; use `REVENUECAT_PREMIUM_ENTITLEMENT` if your dashboard uses a different name.

Run with:

```bash
flutter run --dart-define=REVENUECAT_ANDROID_API_KEY=googl_your_public_key --dart-define=GEMINI_API_KEY=your_key
```

The app also supports:

```bash
--dart-define=REVENUECAT_PREMIUM_ENTITLEMENT=maxie_premium
```

## Hackathon Video Script

MAXie is an AI companion for people who want an assistant that remembers them, not just answers questions. In this demo, I tell MAXie something personal, save it into Memory Brain, and the companion instantly grows with XP and mood changes. MAXie Spark turns that genuine progress into a caption the user explicitly chooses to share. RevenueCat powers MAXie Premium, where companion packs, cloud sync, and deeper personalization become the subscription layer. The result is a product built to grow beyond the hackathon.

## Phase Status

- Phase 1: Complete for hackathon demo.
- Phase 2: Needs native Android overlay service, voice input/output, and real notifications.
- Phase 3: Needs cloud sync, auth, production analytics, and App Store/Play Store launch assets.
- Phase 4: Needs retention experiments, referral loop, campus/community launch, and creator videos.
