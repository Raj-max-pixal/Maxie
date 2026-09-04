# MAXie Shipathon Submission

## One-Line Pitch

MAXie is a mobile AI companion that remembers what matters about you, grows with every chat, and turns emotional memory into a paid companion experience.

## Why It Can Win

- RevenueCat is part of the core product loop, not an afterthought: MAXie Plus unlocks premium companion value through voice, cloud memory sync, and companion styles.
- The first demo is understandable in under one minute: chat, save a memory, return home, and watch the companion mood and XP change.
- The viral hook is built in: the Home screen generates a #BuildInPublic share post from the user journey.
- The startup path is clear: free emotional companion loop, paid subscription for deeper personalization, syncing, premium pets, voice, and overlays.

## Demo Flow For Judges

1. Launch MAXie.
2. Open Chat.
3. Send: `I am building MAXie for the RevenueCat Shipathon and my birthday is March 12.`
4. Save the suggested memory.
5. Return Home and show the Memory Brain count, recent memory, mood, XP, and share action.
6. Open MAXie Plus and show RevenueCat status, purchase, and restore.
7. Open Shimeji/Companion to show the pet layer and explain future Android overlay direction.

## RevenueCat Setup

Use these names unless the dashboard already has better production names:

- Entitlement: `maxie_plus`
- Offering: `default`
- Monthly product: `maxie_plus_monthly`
- Yearly product: `maxie_plus_yearly`

Run with:

```bash
flutter run --dart-define=REVENUECAT_ANDROID_API_KEY=googl_your_public_key --dart-define=GEMINI_API_KEY=your_key
```

The app also supports:

```bash
--dart-define=REVENUECAT_PREMIUM_ENTITLEMENT=maxie_plus
```

## Hackathon Video Script

MAXie is an AI companion for people who want an assistant that remembers them emotionally, not just answers questions. In this demo, I tell MAXie something personal, save it into Memory Brain, and the companion instantly grows with XP and mood changes. RevenueCat powers MAXie Plus, where premium memory, voice, cloud sync, and companion styles become the subscription layer. The result is a product that can start as a hackathon demo and grow into a real consumer startup.

## Phase Status

- Phase 1: Complete for hackathon demo.
- Phase 2: Needs native Android overlay service, voice input/output, and real notifications.
- Phase 3: Needs cloud sync, auth, production analytics, and App Store/Play Store launch assets.
- Phase 4: Needs retention experiments, referral loop, campus/community launch, and creator videos.
