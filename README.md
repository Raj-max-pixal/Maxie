# MAXie

<<<<<<< HEAD
MAXie is a Windows-first Electron desktop companion. The pet is the app: a
transparent, frameless, always-on-top desktop pet with an optional settings
window.

## Run locally

```bash
npm install
npm start
```

## Build installer

```bash
npm run release:check
npm run dist
```

The Windows installer is generated in `dist/`.

## Current Features

- Transparent always-on-top pet window with saved desktop position.
- Draggable pet, optional click-through idle mode, system tray controls.
- Modular CSS animation states for movement, moods, app reactions, toys, weather
  moments, and desktop-world moments.
- Active app awareness for common apps such as VS Code, browsers, Spotify,
  YouTube, Discord, Steam, OBS, Figma, Photoshop, Blender, and terminals.
- Optional settings window for appearance, AI provider, permissions, movement,
  world events, intelligence, memory, productivity, and startup.
- Offline-first state: memories, friendship, XP, growth, needs, inventory,
  stories, home props, and settings are stored locally.
- Image upload processing with background cleanup, crop, resize, sticker outline,
  and color extraction.
- AI adapters for Ollama, Gemini API, and OpenAI-compatible endpoints.

## Important Release Note

MAXie currently uses CSS-based character art and placeholder GIF files in
`assets/`. Before a public visual launch, replace those placeholders with a
consistent production sprite pack or remove the unused GIF assets from the
release package.

## Project Structure

```text
Maxie/
  package.json
  main.js
  preload.js
  renderer/
  settings/
  assets/
  animations/
  ai/
  utils/
  storage/
  tray/
  plugins/
  README.md
  LICENSE
```

## Privacy

MAXie is local-first. Active app awareness uses app names/window titles for
context; it does not capture typed text. See `PRIVACY.md` before publishing.
=======
MAXie is a free-budget, local-first prototype for a living AI desktop companion.

## Run

Open `index.html` in a browser. No install step is required.

## Current prototype

- Upload any image and use it as MAXie's companion avatar.
- Animated desktop pet with speech reactions.
- Personality, context, mood, needs, XP, and growth stage.
- Local memory/task list stored in browser `localStorage`.
- Quick coding, study, focus, and creative helper modes.

## Next fastest milestones

1. Package as a desktop app with Tauri or Electron.
2. Add optional Ollama chat integration for local AI replies.
3. Add SQLite storage once the desktop shell exists.
4. Add real active-window detection behind a clear permission toggle.
>>>>>>> 0e604ca4c5d19770d0e86d7fcb7effbe29738ea8
