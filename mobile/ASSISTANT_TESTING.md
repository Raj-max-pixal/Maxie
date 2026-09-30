# MAXie context assistant (version code 4)

## Enable on the phone

1. Update the previous release-signed MAXie APK. Keep app data.
2. Home > Across your apps: enable Android Notification Access for media metadata.
3. Enable **MAXie app awareness** in Accessibility Settings for foreground video/game identification. If the old service was already enabled, toggle it off and on after updating.
4. Switch the floating pet off and back on.
5. Tap the floating pet. Enable **AI** to send questions and media/app metadata to Gemini; enable **Voice** to hear replies. Both default off. Close chat with X to restore the non-focusable draggable overlay.

## Expected behavior

- A playing media session (Spotify or another compatible player) supplies track/title and artist, when the player publishes them.
- Supported video apps are YouTube, Netflix, Prime Video, Hotstar, VLC, and MX Player. Without published media metadata, only app identity is known.
- Apps Android categorizes as games receive a game reaction. Apps that omit this classification may not be recognized.
- The overlay receives a snapshot every three seconds. Automatic comments happen on activity/track changes, at most once per 45 seconds. Paused playback is not treated as playing.
- Automatic reactions pause while chat is open. Questions include the latest context and the last six exchanges of this overlay session.
- Switching off Android permissions removes the corresponding signal. Locking the phone suppresses activity metadata. Missing events expire after 12 seconds.
- No screenshots, typed text, private notification bodies, microphone recordings, lyrics or scene analysis are collected. No arbitrary phone controls are executed.
- Voice uses the installed Android TTS engine. It may duck media depending on that engine and device settings.
- Gemini errors show an explicit unavailable status. Local reactions remain available.

## Validation performed

- Activity model and widget tests cover metadata-driven reactions, exclusion of unsupported app data, native-message delivery, chat layout and focus restoration.
- Existing 120x120 / 240x254 / 180x200 overlay clipping and physical-pixel sizing tests are retained.
- A synthetic generateContent request to gemini-3.1-flash-lite succeeded with the configured credential.

## Device acceptance tests still required

Spotify play/pause/track change; YouTube and Netflix foreground changes; a categorized game; permission revocation; screen lock; AI off/on; voice off/on; keyboard dismissal and X-close; Back and volume in another app; battery/background behavior after several minutes. OEM restrictions and player metadata differ by phone.
