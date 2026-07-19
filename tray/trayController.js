const path = require("path");

function createTray({ Tray, Menu, nativeImage, app, iconPath, onOpenSettings, onWakePet, onDance }) {
  let image = nativeImage.createFromPath(iconPath);
  if (image.isEmpty()) {
    image = nativeImage.createFromDataURL(makeTrayIconDataUrl());
  }

  const tray = new Tray(image.resize({ width: 16, height: 16 }));
  tray.setToolTip("MAXie");
  tray.setContextMenu(Menu.buildFromTemplate([
    { label: "Wake MAXie", click: onWakePet },
    { label: "Dance", click: onDance },
    { type: "separator" },
    { label: "Settings", click: onOpenSettings },
    { label: "Quit", click: () => app.exit(0) }
  ]));
  tray.on("double-click", onOpenSettings);
  return tray;
}

function makeTrayIconDataUrl() {
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32"><rect width="32" height="32" rx="8" fill="#72d6b2"/><circle cx="11" cy="14" r="3" fill="#17201e"/><circle cx="21" cy="14" r="3" fill="#17201e"/><path d="M10 21 Q16 26 22 21" fill="none" stroke="#17201e" stroke-width="3" stroke-linecap="round"/></svg>`;
  return `data:image/svg+xml;base64,${Buffer.from(svg).toString("base64")}`;
}

module.exports = { createTray };
