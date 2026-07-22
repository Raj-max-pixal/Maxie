# Sounds Directory

This directory contains sound effects and audio files for MAXie Mobile.

## Required Sounds

### MAXie Voice Sounds
- `maxie_happy.mp3` - Happy sound
- `maxie_sad.mp3` - Sad sound
- `maxie_excited.mp3` - Excited sound
- `maxie_sleepy.mp3` - Sleepy sound
- `maxie_tap.mp3` - Tap reaction sound
- `maxie_double_tap.mp3` - Double tap sound

### UI Sounds
- `button_click.mp3` - Button click sound
- `notification.mp3` - Notification sound
- `achievement.mp3` - Achievement unlock sound
- `level_up.mp3` - Level up sound

### Ambient Sounds
- `ambient_calm.mp3` - Calm background
- `ambient_happy.mp3` - Happy background
- `ambient_focus.mp3` - Focus background

## Audio Specifications

### Format
- **Format**: MP3 or WAV
- **Bitrate**: 128-192 kbps for MP3
- **Sample Rate**: 44.1 kHz
- **Channels**: Stereo (recommended) or Mono

### Length
- **Short sounds**: 0.5-2 seconds
- **Medium sounds**: 2-5 seconds
- **Background sounds**: 30 seconds+ (loopable)

## Current Status

⚠️ **No sounds added yet**

Please add audio files to this directory.

## Resources

- **Free Sound Effects**: Freesound.org, Zapsplat.com
- **Audio Editing**: Audacity (free), Adobe Audition
- **Voice Recording**: Built-in recorder, professional mic for better quality

## Implementation

Use the `just_audio` package in Flutter:
```dart
final player = AudioPlayer();
await player.setAsset('assets/sounds/maxie_happy.mp3');
await player.play();
```
