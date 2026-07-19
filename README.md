# MAXie

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

## 🚀 Download

👉 **[Download MAXie Beta](https://github.com/Raj-max-pixal/Maxie/releases/latest)**

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
