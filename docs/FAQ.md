# FAQ

## Is MAXie a website?

No. MAXie is an Electron desktop app. A website can market and distribute it,
but the pet itself runs on the user's desktop.

## Does MAXie need paid AI?

No. Ollama is supported for local/offline AI. Gemini and OpenAI-compatible
providers require the user's own API key.

## Does MAXie record keystrokes?

No. MAXie detects active applications/window titles for reactions. It does not
capture typed text.

## Why are some window-edge features marked experimental?

Electron cannot reliably attach to arbitrary third-party window borders across
all Windows apps. MAXie uses safe approximations near detected window bounds.

## Are the current sprites final?

No. Current visuals are CSS-based and the GIF files in `assets/` are placeholder
files. Replace them with a polished sprite pack before a public visual launch.
