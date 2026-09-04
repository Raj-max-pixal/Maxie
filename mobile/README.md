# MAXie Mobile

MAXie is an AI companion demo built for Shipathon: chat with MAXie, save meaningful facts into Memory Brain, and watch the companion grow through mood and XP changes.

Shipathon fit:

- RevenueCat requirement: `purchases_flutter` is integrated for MAXie Plus.
- HAMM Award: free companion loop with paid upgrades for voice, cloud memory sync, and premium companion styles.
- Most Viral App: shareable #BuildInPublic posts from the Home screen.
- RevenueCat Design Award: animated companion, Memory Brain, and Shimeji-style pet demo.

## Phase 1 Demo Loop

1. Open the app and enter Chat.
2. Send a personal prompt, for example: `my birthday is 12 March` or `I am building MAXie Mobile for Shipathon`.
3. Save the memory suggestion.
4. Return Home and see Memory Brain count, companion mood, and XP update.
5. Open Companion or Shimeji to show the interactive pet experience.

## What Works In This Phase

- Gemini chat when `GEMINI_API_KEY` is supplied with `--dart-define`.
- Local companion demo responses when no API key is supplied.
- Local conversation history and drafts.
- Memory extraction from chat for birthdays, interests, dream companies, and projects.
- Manual saving of assistant replies into Memory Brain.
- Companion mood, friendship XP, and last action updates from chat and memories.
- In-app Shimeji-style pet demo with movement, drag, interactions, settings, XP, and unlocks.
- RevenueCat-backed MAXie Plus screen with purchase and restore actions.
- Shareable launch post for the #BuildInPublic growth loop.

## Demo Command

```bash
flutter run --dart-define=GEMINI_API_KEY=your_key
```

Without a key, the app still runs in local companion demo mode.

For live RevenueCat purchase testing, pass the public app-specific SDK key from the RevenueCat dashboard:

```bash
flutter run --dart-define=REVENUECAT_ANDROID_API_KEY=googl_your_public_key --dart-define=GEMINI_API_KEY=your_key
```

Use `REVENUECAT_IOS_API_KEY` for iOS.

## Next Release Work

- Android native overlay service.
- Real voice input and voice output.
- Real notifications and reminders.
- App icon, release signing, privacy policy, and Play Store assets.
- Play Store product setup and RevenueCat offering/package configuration.
