const { app, BrowserWindow, Tray, Menu, ipcMain, screen, Notification, nativeImage, shell } = require("electron");
const fs = require("fs");
const path = require("path");
const { createTray } = require("./tray/trayController");
const { createStore } = require("./storage/store");
const { getActiveApp } = require("./utils/activeApp");
const { getSystemSnapshot } = require("./utils/systemInfo");
const { ensureStartup, isStartupEnabled } = require("./utils/startup");
const { createAiClient } = require("./ai/aiClient");

const store = createStore("maxie-state.json");
let petWindow;
let settingsWindow;
let tray;

const singleInstanceLock = app.requestSingleInstanceLock();
if (!singleInstanceLock) {
  app.exit(0);
}

const defaultState = {
  pet: { x: 180, y: 220, size: 180, speed: 1, clickThroughIdle: false, followMouse: false },
  movement: {
    randomWalking: true,
    edgeWalking: false,
    windowEdgeWalking: false,
    wallClimbing: false,
    ceilingWalking: false,
    hanging: false,
    jumpBetweenWindows: false,
    slipAndFall: true,
    sitOnWindow: false,
    followMouse: false,
    avoidMouse: false,
    physicsMode: true,
    gravity: false,
    bounceLanding: true,
    idleExploration: true,
    speed: 1,
    explorationFrequency: 0.45,
    jumpHeight: 0.55,
    gravityStrength: 0.35,
    fallChance: 0.08
  },
  needs: { happiness: 78, hunger: 34, thirst: 28, sleep: 22, fun: 68, friendship: 50, curiosity: 72 },
  inventory: { coins: 0, xp: 0, food: [], toys: [], accessories: [], equipped: {} },
  world: { enabled: true, toysEnabled: true, weatherEnabled: true, frequency: 0.5, weatherMode: "auto" },
  nextLevel: {
    petInteractions: true,
    familySystem: true,
    evolution: true,
    homeBuilder: true,
    adventures: true,
    storyEngine: true,
    moodWheel: true,
    cinematicEvents: true,
    seasonalUpdates: true,
    pluginMarketplace: true,
    eventFrequency: 0.4
  },
  family: { role: "Baby MAXie", generation: 1 },
  evolution: { level: 1, form: "Baby", unlocked: ["idle", "walk", "sleep"] },
  home: { equipped: ["bed", "bookshelf"], unlocked: ["bed", "sofa", "tv", "computer", "bookshelf", "kitchen", "garden"] },
  stories: [],
  plugins: { folder: "plugins", installed: [] },
  appearance: { avatar: "" },
  ai: { provider: "ollama", endpoint: "http://localhost:11434", model: "llama3.2", apiKey: "" },
  permissions: { activeApp: true, notifications: true, systemInfo: true },
  personality: { name: "MAXie", style: "Cute", friendship: 50, xp: 0, growth: "Baby" },
  memory: [],
  stats: { openedAt: Date.now(), activeMinutes: 0, codeMinutes: 0, giftsFound: 0, gamesPlayed: 0 },
  features: {
    randomMoments: true,
    surpriseGifts: true,
    voice: false,
    productivity: true,
    nightSleep: true,
    memeLines: true,
    photoMode: true,
    festivals: true,
    demoMode: false
  },
  intelligence: {
    aiMemory: true,
    habitLearning: true,
    routineLearning: true,
    conversationMemory: true,
    contextAwareness: true,
    moodEngine: true,
    emotionEngine: true,
    offlineAi: true,
    smartReminders: true,
    taskSuggestions: true
  },
  routines: { byHour: {}, byApp: {}, lastSuggestionAt: 0 },
  gifts: [],
  achievements: [],
  profile: { userName: "", birthday: "" },
  theme: "mint"
};

function readState() {
  return sanitizeState(store.read(defaultState));
}

function writeState(nextState) {
  store.write(sanitizeState({ ...readState(), ...nextState }));
}

function createPetWindow() {
  const state = readState();
  const display = screen.getDisplayNearestPoint({ x: state.pet.x, y: state.pet.y });
  const bounds = display.workArea;
  const size = state.pet.size + 140;
  const x = clamp(Number.isFinite(state.pet.x) ? state.pet.x : bounds.x + 80, bounds.x, bounds.x + bounds.width - size);
  const y = clamp(Number.isFinite(state.pet.y) ? state.pet.y : bounds.y + 80, bounds.y, bounds.y + bounds.height - size);

  petWindow = new BrowserWindow({
    width: size,
    height: size,
    x,
    y,
    frame: false,
    transparent: true,
    resizable: false,
    movable: true,
    hasShadow: false,
    skipTaskbar: true,
    alwaysOnTop: true,
    focusable: true,
    backgroundColor: "#00000000",
    show: false,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      contextIsolation: true,
      nodeIntegration: false,
      backgroundThrottling: false
    }
  });

  petWindow.setAlwaysOnTop(true, "screen-saver");
  petWindow.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true });
  petWindow.setIgnoreMouseEvents(false);
  petWindow.loadFile(path.join(__dirname, "renderer", "pet.html"));
  petWindow.once("ready-to-show", () => petWindow.showInactive());
  petWindow.on("moved", rememberPetBounds);
  petWindow.on("closed", () => {
    petWindow = null;
  });
}

function rememberPetBounds() {
  if (!petWindow || petWindow.isDestroyed()) return;
  const [x, y] = petWindow.getPosition();
  writeState({ pet: { ...readState().pet, x, y } });
}

function openSettings() {
  if (settingsWindow && !settingsWindow.isDestroyed()) {
    settingsWindow.focus();
    return;
  }

  settingsWindow = new BrowserWindow({
    width: 880,
    height: 680,
    minWidth: 760,
    minHeight: 560,
    title: "MAXie Settings",
    backgroundColor: "#17181f",
    autoHideMenuBar: true,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  settingsWindow.loadFile(path.join(__dirname, "settings", "settings.html"));
  settingsWindow.on("closed", () => {
    settingsWindow = null;
  });
}

function sendToPet(channel, payload) {
  if (petWindow && !petWindow.isDestroyed()) petWindow.webContents.send(channel, payload);
}

function showPet() {
  if (!petWindow || petWindow.isDestroyed()) {
    createPetWindow();
    return;
  }
  petWindow.showInactive();
  petWindow.setAlwaysOnTop(true, "screen-saver");
  sendToPet("pet:command", { type: "wake" });
}

function setupIpc() {
  ipcMain.handle("state:get", () => readState());
  ipcMain.handle("state:set", (_event, partial) => {
    writeState(partial && typeof partial === "object" ? partial : {});
    const state = readState();
    if (partial.pet?.size && petWindow && !petWindow.isDestroyed()) {
      const [x, y] = petWindow.getPosition();
      const size = Number(partial.pet.size) + 140;
      petWindow.setBounds({ x, y, width: size, height: size }, false);
    }
    sendToPet("state:changed", state);
    return state;
  });

  ipcMain.handle("pet:get-displays", () => screen.getAllDisplays().map((display) => ({
    id: display.id,
    bounds: display.bounds,
    workArea: display.workArea,
    scaleFactor: display.scaleFactor
  })));

  ipcMain.handle("pet:set-bounds", (_event, bounds) => {
    if (!petWindow || petWindow.isDestroyed()) return;
    if (!isUsableBounds(bounds)) return petWindow.getBounds();
    const display = screen.getDisplayNearestPoint({ x: Math.round(bounds.x), y: Math.round(bounds.y) });
    const area = display.workArea;
    const width = Math.round(bounds.width);
    const height = Math.round(bounds.height);
    petWindow.setBounds({
      x: clamp(Math.round(bounds.x), area.x, area.x + area.width - width),
      y: clamp(Math.round(bounds.y), area.y, area.y + area.height - height),
      width,
      height
    }, false);
    rememberPetBounds();
    return petWindow.getBounds();
  });

  ipcMain.handle("pet:get-bounds", () => petWindow?.getBounds());
  ipcMain.handle("pet:set-click-through", (_event, enabled) => {
    if (!petWindow || petWindow.isDestroyed()) return;
    petWindow.setIgnoreMouseEvents(Boolean(enabled), { forward: true });
  });
  ipcMain.handle("pet:hide", () => {
    if (!petWindow || petWindow.isDestroyed()) return;
    petWindow.hide();
  });
  ipcMain.handle("pet:show", () => {
    showPet();
  });
  ipcMain.handle("pet:command", (_event, command) => {
    showPet();
    sendToPet("pet:command", command);
  });
  ipcMain.handle("pet:photo", async () => {
    if (!petWindow || petWindow.isDestroyed()) return null;
    const image = await petWindow.capturePage();
    const dir = path.join(app.getPath("pictures"), "MAXie");
    fs.mkdirSync(dir, { recursive: true });
    const filePath = path.join(dir, `maxie-${new Date().toISOString().replace(/[:.]/g, "-")}.png`);
    fs.writeFileSync(filePath, image.toPNG());
    shell.showItemInFolder(filePath);
    return filePath;
  });

  ipcMain.handle("settings:open", () => openSettings());
  ipcMain.handle("project:open-folder", () => shell.openPath(__dirname));

  ipcMain.handle("system:get-snapshot", async () => getSystemSnapshot());
  ipcMain.handle("system:get-active-app", async () => getActiveApp());
  ipcMain.handle("system:set-startup", (_event, enabled) => {
    ensureStartup(enabled);
    return isStartupEnabled();
  });
  ipcMain.handle("system:get-startup", () => isStartupEnabled());

  ipcMain.handle("notify", (_event, { title, body }) => {
    const state = readState();
    if (!state.permissions.notifications || !Notification.isSupported()) return false;
    new Notification({ title, body }).show();
    return true;
  });

  ipcMain.handle("ai:chat", async (_event, messages) => {
    const state = readState();
    const client = createAiClient(state.ai);
    return client.chat(messages, state);
  });
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function numberInRange(value, fallback, min, max) {
  const numeric = Number(value);
  if (!Number.isFinite(numeric)) return fallback;
  return clamp(numeric, min, max);
}

function isUsableBounds(bounds) {
  return Boolean(bounds) &&
    Number.isFinite(Number(bounds.x)) &&
    Number.isFinite(Number(bounds.y)) &&
    Number.isFinite(Number(bounds.width)) &&
    Number.isFinite(Number(bounds.height)) &&
    Number(bounds.width) >= 120 &&
    Number(bounds.height) >= 120;
}

function sanitizeState(state) {
  const safe = { ...defaultState, ...(state && typeof state === "object" ? state : {}) };
  safe.pet = { ...defaultState.pet, ...(safe.pet && typeof safe.pet === "object" ? safe.pet : {}) };
  safe.pet.x = numberInRange(safe.pet.x, defaultState.pet.x, -100000, 100000);
  safe.pet.y = numberInRange(safe.pet.y, defaultState.pet.y, -100000, 100000);
  safe.pet.size = numberInRange(safe.pet.size, defaultState.pet.size, 96, 320);
  safe.pet.speed = numberInRange(safe.pet.speed, defaultState.pet.speed, 0.5, 2);
  safe.pet.clickThroughIdle = Boolean(safe.pet.clickThroughIdle);
  safe.pet.followMouse = Boolean(safe.pet.followMouse);

  safe.movement = { ...defaultState.movement, ...(safe.movement && typeof safe.movement === "object" ? safe.movement : {}) };
  safe.movement.speed = numberInRange(safe.movement.speed, safe.pet.speed, 0.5, 2);
  safe.movement.explorationFrequency = numberInRange(safe.movement.explorationFrequency, defaultState.movement.explorationFrequency, 0, 1);
  safe.movement.jumpHeight = numberInRange(safe.movement.jumpHeight, defaultState.movement.jumpHeight, 0, 1);
  safe.movement.gravityStrength = numberInRange(safe.movement.gravityStrength, defaultState.movement.gravityStrength, 0, 2);
  safe.movement.fallChance = numberInRange(safe.movement.fallChance, defaultState.movement.fallChance, 0, 0.5);

  safe.world = { ...defaultState.world, ...(safe.world && typeof safe.world === "object" ? safe.world : {}) };
  safe.world.frequency = numberInRange(safe.world.frequency, defaultState.world.frequency, 0, 1);
  if (!["auto", "rain", "wind", "snow", "hot", "cold"].includes(safe.world.weatherMode)) safe.world.weatherMode = "auto";

  safe.nextLevel = { ...defaultState.nextLevel, ...(safe.nextLevel && typeof safe.nextLevel === "object" ? safe.nextLevel : {}) };
  safe.nextLevel.eventFrequency = numberInRange(safe.nextLevel.eventFrequency, defaultState.nextLevel.eventFrequency, 0, 1);
  safe.appearance = { ...defaultState.appearance, ...(safe.appearance && typeof safe.appearance === "object" ? safe.appearance : {}) };
  safe.ai = { ...defaultState.ai, ...(safe.ai && typeof safe.ai === "object" ? safe.ai : {}) };
  if (!["ollama", "gemini", "openai-compatible"].includes(safe.ai.provider)) safe.ai.provider = "ollama";
  safe.permissions = { ...defaultState.permissions, ...(safe.permissions && typeof safe.permissions === "object" ? safe.permissions : {}) };
  safe.personality = { ...defaultState.personality, ...(safe.personality && typeof safe.personality === "object" ? safe.personality : {}) };
  safe.personality.friendship = numberInRange(safe.personality.friendship, defaultState.personality.friendship, 0, 100);
  safe.personality.xp = numberInRange(safe.personality.xp, defaultState.personality.xp, 0, 1000000);
  safe.features = { ...defaultState.features, ...(safe.features && typeof safe.features === "object" ? safe.features : {}) };
  safe.intelligence = { ...defaultState.intelligence, ...(safe.intelligence && typeof safe.intelligence === "object" ? safe.intelligence : {}) };
  safe.needs = { ...defaultState.needs, ...(safe.needs && typeof safe.needs === "object" ? safe.needs : {}) };
  for (const key of Object.keys(defaultState.needs)) safe.needs[key] = numberInRange(safe.needs[key], defaultState.needs[key], 0, 100);
  safe.inventory = { ...defaultState.inventory, ...(safe.inventory && typeof safe.inventory === "object" ? safe.inventory : {}) };
  safe.stats = { ...defaultState.stats, ...(safe.stats && typeof safe.stats === "object" ? safe.stats : {}) };
  safe.family = { ...defaultState.family, ...(safe.family && typeof safe.family === "object" ? safe.family : {}) };
  safe.evolution = { ...defaultState.evolution, ...(safe.evolution && typeof safe.evolution === "object" ? safe.evolution : {}) };
  safe.home = { ...defaultState.home, ...(safe.home && typeof safe.home === "object" ? safe.home : {}) };
  if (!Array.isArray(safe.home.equipped)) safe.home.equipped = defaultState.home.equipped;
  if (!Array.isArray(safe.home.unlocked)) safe.home.unlocked = defaultState.home.unlocked;
  if (!Array.isArray(safe.memory)) safe.memory = [];
  if (!Array.isArray(safe.gifts)) safe.gifts = [];
  if (!Array.isArray(safe.achievements)) safe.achievements = [];
  if (!Array.isArray(safe.stories)) safe.stories = [];
  return safe;
}

if (singleInstanceLock) app.whenReady().then(() => {
  app.setAppUserModelId("MAXie.DesktopCompanion");
  setupIpc();
  createPetWindow();
  tray = createTray({
    Tray,
    Menu,
    nativeImage,
    app,
    iconPath: path.join(__dirname, "assets", "tray.png"),
    onOpenSettings: openSettings,
    onWakePet: showPet,
    onDance: () => sendToPet("pet:command", { type: "dance" })
  });

  app.on("activate", () => {
    if (!petWindow) createPetWindow();
  });
});

app.on("second-instance", () => {
  showPet();
  if (settingsWindow && !settingsWindow.isDestroyed()) settingsWindow.focus();
});

app.on("before-quit", rememberPetBounds);
app.on("window-all-closed", (event) => {
  event.preventDefault();
});
