# Release Checklist

## Must Pass

- `npm run release:check` passes.
- MAXie starts from `npm start`.
- Click opens the quick menu and menu hides after 3 seconds.
- Dragging moves the pet and does not open the menu.
- Settings opens in a separate window.
- Pet size changes apply immediately.
- Hide/Show controls work from Settings and tray.
- Active app detection can be disabled.
- AI chat handles missing local Ollama/API gracefully.
- Uploaded image can be deleted and default MAXie returns.
- Pet never becomes invisible during adventures or timed events.

## Website Publishing

- Provide a clear Windows download button.
- Explain that this is a desktop app, not a browser pet.
- Link to `PRIVACY.md`, `LICENSE`, `FAQ.md`, `CHANGELOG.md`, and `ROADMAP.md`.
- Show real screenshots/GIFs from the current build.
- Do not advertise final high-quality sprites until placeholder GIFs are replaced.
- Mention that Ollama is the free/offline AI path.

## Packaging

- Replace placeholder files in `assets/`.
- Add final app icon and tray icon.
- Build with `npm run dist`.
- Install on a clean Windows account.
- Verify uninstall removes the app cleanly.
- Consider code signing before broad public distribution.
