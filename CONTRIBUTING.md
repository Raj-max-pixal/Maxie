# Contributing

## Principles

- Keep MAXie desktop-first. Do not turn the main experience into a dashboard.
- Keep default behavior free and offline-first.
- Prefer stable, low-CPU animations over many half-finished reactions.
- Do not capture typed text or private file contents.

## Development

```bash
npm install
npm run check
npm start
```

## Pull Request Checklist

- Run `npm run release:check`.
- Test click menu, drag, settings, size changes, and startup behavior.
- Verify the pet is visible after every timed event.
- Update docs when behavior, privacy, or packaging changes.
