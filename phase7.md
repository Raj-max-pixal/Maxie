# Phase 7 — AI Companion Intelligence Technical Documentation

This document describes the complete architecture, modules, events, and state structures implemented for **Phase 7: AI Companion Intelligence** on MAXie Mobile.

---

## 1. Modular Directory Layout

The intelligence layer is organized into a modular design under the `/lib/` folder:

```text
lib/
├── companion/
│   ├── companionState.js            # Extends defaults, validates/sanitizes state shapes
│   ├── companionEngine.js           # Coordinates event loops, UI triggers, and AI queries
│   │
│   ├── personality/
│   │   └── personalityEngine.js     # Declares companion profiles, style filters, and prompts
│   │
│   ├── mood/
│   │   └── moodEngine.js            # Updates mood parameters and mapping to Shimeji actions
│   │
│   ├── memory/
│   │   ├── memoryStore.js           # Handles short/long-term context caps and companion milestones
│   │   └── importanceFilter.js      # Heuristic regex scanners capturing names and favorite topics
│   │
│   ├── relationship/
│   │   └── relationshipEngine.js     # Progression levels (Stranger -> Soul Companion) & unlocks
│   │
│   ├── reactions/
│   │   └── reactionEngine.js        # Maps app contexts to dialogue thoughts & animation states
│   │
│   └── activities/
│       └── activityEngine.js        # Runs interactive Quick Actions (Feed, Pet, Play, etc.)
│
├── ai/
│   ├── router/
│   │   └── aiRouter.js              # Routing with cascading fallback (Gemini -> Ollama -> Offline)
│   ├── providers/
│   │   ├── gemini.js                # Direct Gemini API fetch client
│   │   ├── ollama.js                # Local network Ollama fetch client
│   │   └── offline.js               # Dialogue simulator referencing mood, personality, and relationship
│   └── prompts/
│       └── characterPrompts.js      # dynamic prompt assembler with relevant memory recall
│
└── voice/
    ├── speech/
    │   └── speechRec.js             # Browser Web Speech API Speech-to-Text recorder
    └── tts/
        └── ttsSynthesis.js          # SpeechSynthesis Text-to-Speech audio reader
```

---

## 2. Event System

Events are dispatched via `window.companionEngine.handleEvent(eventName, payload)`. Supported companion events include:

| Event Name | Mood Target | Affection/Trust | Animation |
| :--- | :--- | :--- | :--- |
| `APP_OPENED` | `happy` / `calm` | — | `idle` |
| `USER_MESSAGE` | `curious` / `playful` | $+0.5$ | — |
| `PET_TAPPED` / `PET_PETTED` | `happy` | $+2.0$ affection, $+1.0$ trust | `happy` |
| `PET_DOUBLE_TAPPED` / `PET_DANCED` | `excited` | $+3.0$ affection, $+2.0$ trust | `dance` |
| `PET_FED` | `happy` | $+5.0$ affection, $+3.0$ trust | `eat` |
| `PET_PLAYED` | `playful` | $+4.0$ affection, $+1.0$ trust | `run` / `jump` |
| `PET_SLEPT` | `sleepy` | — | `sleep` |
| `TASK_COMPLETED` | `proud` | $+3.0$ affection, $+6.0$ trust | `celebrate` |
| `TASK_CREATED` | `curious` | — | — |
| `USER_IDLE` | `lonely` | — | `sit` |
| `CODING_DETECTED` | `curious` | — | `thinking` |
| `MUSIC_STARTED` | `playful` | — | `dance` |
| `LATE_NIGHT` | `sleepy` | — | `yawn` |
| `COMPANION_UNLOCKED` | `excited` | — | `celebrate` |
| `GIFT_RECEIVED` | `happy` | $+10.0$ affection, $+5.0$ trust | `excited` |
| `RELATIONSHIP_LEVEL_UP` | `proud` | — | `celebrate` |

---

## 3. Storage & State Integration

State variables persist using the app's existing serialization channel. The `shimeji` sub-object is hydrated on startup:

```javascript
shimeji: {
  relationships: {
    maxie: { level: 1, xp: 0, affection: 10, trust: 10, lastInteraction: timestamp, milestones: [] },
    ...
  },
  moods: {
    maxie: { mood: "happy", intensity: 1.0, cause: "SYSTEM", timestamp: timestamp },
    ...
  },
  voice: {
    speechEnabled: false,
    ttsEnabled: false
  }
}
```

---

## 4. Cascading AI Fallback

When a message is sent, the `AiRouter` executes:

1. **Gemini**: Attempted if provider is configured as `gemini` and a valid API key is present in user configuration.
2. **Ollama**: Attempted if Gemini is unavailable, or if configured as `ollama`. Performs local network requests to the Ollama endpoint.
3. **Offline Fallback**: Attempted if both online servers fail, or if fully offline. Returns templates that match the character's personality profile, mood, and relationship level.

---

## 5. Security & Privacy

1. **Untrusted AI Output**: All dialogue responses are validated, sanitized, and drawn as plain text. No execution of scripts inside speech bubbles is allowed.
2. **API Key Isolation**: Developer/commercial API keys are not hardcoded. User settings are handled locally on device.
3. **Local-First Privacy**: Memory database records do not sync to any cloud database, staying inside the local sandbox.
