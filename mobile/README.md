# MAXie Mobile - India's First AI Mobile Companion

MAXie Mobile is a beautiful Android application featuring an AI companion that lives on your phone like a virtual pet. It reacts to everything happening on the device, talks naturally, remembers the user, learns habits, entertains, motivates, and feels alive.

## 🎯 Vision

Create the world's most lovable AI companion for Android. The app feels alive, creating an emotional connection between the user and MAXie.

## ✨ Features Implemented

### Core Features
- ✅ Flutter project structure with all dependencies
- ✅ Premium Material 3 UI with themes and customization
- ✅ AI personality engine with Gemini API integration
- ✅ Local storage system using Hive for AI memory
- ✅ Friendship system with XP and levels (1-100)
- ✅ Emotion engine with mood states

### Android Native Features
- ✅ Overlay mode with Android system overlay permissions
- ✅ Accessibility Service for smart app detection
- ✅ Notification Listener Service for notification reactions
- ✅ Boot receiver for auto-start

### Smart Detection Modes
- ✅ Music mode with media session detection
- ✅ Gaming mode with game detection (BGMI, Free Fire, COD, etc.)
- ✅ Study mode with Pomodoro timer
- ✅ Coding mode with IDE detection

### Voice Features
- ✅ Text-to-Speech (TTS) with Flutter TTS
- ✅ Speech-to-Text (STT) with speech recognition
- ✅ Wake word detection ("Hey MAXie", "Hello MAXie")

### Health & Wellness
- ✅ Health reminders (water, stretch, eye rest, walk)
- ✅ Battery reactions (low, charging, full)
- ✅ Weather integration with location-based reactions
- ✅ Time-based reactions (morning, afternoon, evening, night)

### Entertainment
- ✅ Mini-games (Rock Paper Scissors, Memory Game, Catch MAXie)
- ✅ Secret features and easter eggs

## 📁 Project Structure

```
mobile/
├── lib/
│   ├── core/
│   │   ├── app.dart
│   │   ├── theme/
│   │   ├── config/
│   │   ├── providers/
│   │   └── services/
│   ├── features/
│   │   ├── onboarding/
│   │   ├── home/
│   │   ├── chat/
│   │   ├── settings/
│   │   ├── ai/
│   │   ├── emotions/
│   │   ├── music/
│   │   ├── games/
│   │   ├── study/
│   │   ├── coding/
│   │   ├── voice/
│   │   ├── health/
│   │   └── weather/
│   └── main.dart
├── android/
│   ├── app/
│   │   └── src/
│   │       └── main/
│   │           ├── kotlin/
│   │           │   └── com/maxie/mobile/
│   │           │       ├── MainActivity.kt
│   │           │       ├── services/
│   │           │       └── receivers/
│   │           ├── res/
│   │           │   ├── layout/
│   │           │   ├── values/
│   │           │   └── xml/
│   │           └── AndroidManifest.xml
│   └── build.gradle
└── pubspec.yaml
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio with Android SDK
- Gemini API Key (free tier available)

### Installation

1. Navigate to the mobile directory:
```bash
cd mobile
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
- Update `lib/core/config/firebase_options.dart` with your Firebase config
- Or remove Firebase dependencies if not needed

4. Configure Gemini API:
- Add your Gemini API key in the app settings
- Get a free API key from https://ai.google.dev/

5. Run the app:
```bash
flutter run
```

### Building for Release

```bash
flutter build apk --release
```

## 🔧 Configuration

### Android Permissions

The app requires the following permissions (configured in AndroidManifest.xml):
- `SYSTEM_ALERT_WINDOW` - For overlay mode
- `BIND_ACCESSIBILITY_SERVICE` - For app detection
- `BIND_NOTIFICATION_LISTENER_SERVICE` - For notification reactions
- `RECORD_AUDIO` - For voice input
- `POST_NOTIFICATIONS` - For sending notifications
- `FOREGROUND_SERVICE` - For background services

### Firebase Setup (Optional)

If you want to use Firebase features:
1. Create a Firebase project at https://console.firebase.google.com/
2. Add an Android app
3. Download `google-services.json`
4. Place it in `android/app/`
5. Update Firebase options in `lib/core/config/firebase_options.dart`

### Gemini API Setup

1. Get a free API key from https://ai.google.dev/
2. Open the app settings
3. Enter your API key in the AI Settings section

## 🎨 UI Features

- Material 3 design system
- Dark/Light theme support
- Smooth animations (60 FPS)
- Glassmorphism effects
- Premium onboarding flow
- Beautiful gradients
- Rounded corners
- Custom fonts (Poppins)

## 🎮 MAXie's Personality

MAXie behaves like a best friend:
- Funny and cute
- Supportive and motivating
- Playful and smart
- Emotionally expressive

MAXie has:
- Facial expressions
- Body language
- Dancing animations
- Sleeping animations
- Reactions to taps
- Context-aware responses

## 📱 Supported Apps

### Social
- WhatsApp, Instagram, Facebook, Twitter, Snapchat, Discord, LinkedIn, Reddit

### Music
- Spotify, YouTube Music, Apple Music

### Gaming
- BGMI, Free Fire, COD Mobile, Minecraft, Clash Royale, Pokemon Unite

### Productivity
- GitHub, VS Code, Android Studio, Stack Overflow, SoloLearn, Udemy, Coursera

## 🔒 Privacy

MAXie is privacy-first:
- Local storage for all data
- No data sent to cloud without permission
- User-controlled settings
- Optional cloud sync (future feature)

## 🛠 Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Riverpod
- **UI**: Material 3
- **Storage**: Hive
- **AI**: Google Gemini API
- **Animations**: Lottie
- **Voice**: Flutter TTS, Speech to Text
- **Firebase**: Authentication, Cloud Messaging, Firestore (optional)

## 📝 To-Do

### High Priority
- [ ] Create MAXie character animations using Lottie/Rive
- [ ] Add actual Lottie animation files to assets
- [ ] Test overlay permissions on real device
- [ ] Test accessibility service on real device

### Medium Priority
- [ ] Add more mini-games
- [ ] Implement secret features (shake phone, tap 10 times, etc.)
- [ ] Add festival themes (Pongal, Diwali, Christmas, etc.)
- [ ] Create customization options (skins, accessories)

### Low Priority
- [ ] Add cloud sync option
- [ ] Implement plugin system
- [ ] Add more language support
- [ ] Create iOS version

## 🤝 Contributing

Contributions are welcome! Please read the main project's CONTRIBUTING.md file.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Google for Flutter and Gemini API
- The open-source community for amazing packages
- All contributors to the MAXie project

---

**MAXie Mobile - More than just an app, it's a friend! 🐾**
