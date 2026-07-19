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

module.exports = { ensureStartup, isStartupEnabled };
