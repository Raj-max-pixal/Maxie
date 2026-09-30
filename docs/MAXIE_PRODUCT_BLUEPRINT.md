# MAXie — Product Blueprint

MAXie is a **cross-platform AI companion ecosystem**: one identity across phone and desktop, with memory, personality, virtual-pet behavior, productivity hooks, games, and (eventually) the MAXie Universe.

## Core stack (mobile)

- **Client:** Flutter, Riverpod, GoRouter, Material 3, Hive / local persistence  
- **AI:** Provider abstraction (Gemini + local fallback), streaming chat  
- **Backend direction:** FastAPI → AI / memory / user services → DB + storage  
- **Sync (later):** Firebase / cloud companion state  

## Architecture layers

Build bottom-up; upper layers depend on stable lower layers:

1. Core (app shell, routing, storage)  
2. Character engine (state, animation, interaction)  
3. Pet / Shimeji (autonomous behavior, physics)  
4. AI (chat, context, providers)  
5. Memory (extract, rank, retrieve)  
6. Personality + emotion + friendship + XP  
7. Voice, desktop, cloud, universe  

**Client shape:** UI → controllers/providers → services → repositories → local/cloud storage.

## Primary mobile navigation

| Tab | Purpose |
|-----|---------|
| Home | Dashboard, companion, quick actions, Mission Control |
| Chat | AI conversation, memory hooks |
| Memory | What MAXie remembers |
| Pet | Virtual pet care and interaction |
| Profile | User, progression, settings entry |

Shimeji overlay demo: **Pet** tab and Home / Mission Control shortcuts (`/shimeji`).

## 18-phase roadmap

Tracked in-app via **Mission Control** (`mobile/lib/features/mission_control/`).

| # | Phase |
|---|--------|
| 1 | Core foundation |
| 2 | Generic character engine |
| 3 | Shimeji screen pets |
| 4 | MAXie character & intelligence *(in progress)* |
| 5–18 | Multi-character, AI depth, C2C, movement, customization, creator, personality, productivity, games, worlds, PC companion, cloud sync, social, universe |

## Repositories in this monorepo

| Path | Role |
|------|------|
| `mobile/` | Primary Flutter app (Shipathon / Play Store target) |
| `desktop/` | Electron desktop companion |
| `docs/` | Product and engineering docs |

## Run mobile

```bash
cd mobile
flutter pub get
flutter run --dart-define=GEMINI_API_KEY=your_key
```

See `mobile/README.md` for RevenueCat and release checklists.

## GitHub

https://github.com/Raj-max-pixal/Maxie
