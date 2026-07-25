const { app } = require("electron");

function ensureStartup(enabled) {
  app.setLoginItemSettings({
    openAtLogin: Boolean(enabled),
    path: process.execPath,
    args: []
  });
}

function isStartupEnabled() {
  return app.getLoginItemSettings().openAtLogin;
}

function ensureStartupEnabled() {
  try {
    ensureStartup(true);
  } catch (error) {
    console.warn("Could not enable MAXie startup:", error.message);
  }
}

module.exports = { ensureStartup, ensureStartupEnabled, isStartupEnabled };
