const pet = document.getElementById("pet");
const body = pet.querySelector(".body");
const customAvatar = document.getElementById("customAvatar");
const bubble = document.getElementById("speechBubble");
const quickMenu = document.getElementById("quickMenu");
const worldLayer = document.getElementById("worldLayer");
const homeLayer = document.getElementById("homeLayer");
const companionPet = document.getElementById("companionPet");
const brain = new window.PetBrain();

let physics;
let displays = [];
let appState;
let currentAnimation = "idle";
let lastActiveApp = "";
let lastActiveInfo;
let lastMediaApp = "";
let lastMediaReactionAt = 0;
let mouse = { x: 0, y: 0 };
let clickThroughTimer;
let windowBounds;
let lastMoveAt = 0;
let dragging = false;
let didDrag = false;
let dragStart = null;
let dragBounds = null;
let sequenceTimer;
let sequenceToken = 0;
let suppressNextClick = false;
let menuTimer;
let lastClickAt = 0;
let lastReactionAt = 0;
let demoTimer;
let movementTimer;
let activeMoveMode = "";
let lastSystemCheckAt = 0;
let lastSystemReaction = "";
let lastTimeGreeting = "";
let worldTimer;
let nextLevelTimer;
let adventureAway = false;
let lastStateSaveAt = 0;

async function boot() {
  appState = await window.maxie.state.get();
  brain.hydrate(appState);
  displays = await window.maxie.pet.getDisplays();
  const bounds = await window.maxie.pet.getBounds();
  windowBounds = bounds;
  physics = new window.PetPhysics(bounds || appState.pet);
  configurePhysics();
  document.documentElement.style.setProperty("--pet-size", `${appState.pet.size}px`);
  applyAvatar(appState.appearance?.avatar);
  setAnimation("idle");
  hideMenu();
  say(brain.greeting());
  keepInteractive();
  loop();
  setInterval(systemPulse, 5000);
  setInterval(randomWalk, 14000);
  setInterval(trackActiveMinute, 60000);
  scheduleAdvancedMovement(true);
  scheduleWorldMoment(true);
  renderHome();
  scheduleNextLevelMoment(true);
  scheduleClickThrough();
  syncDemoMode();
}

function setAnimation(name) {
  if (!window.MAXIE_ANIMATIONS[name]) name = "idle";
  currentAnimation = name;
  pet.classList.add("is-transitioning");
  for (const animation of Object.keys(window.MAXIE_ANIMATIONS)) {
    pet.classList.remove(`state-${animation}`);
  }
  pet.classList.add(`state-${name}`);
  setTimeout(() => pet.classList.remove("is-transitioning"), 180);
}

function playReactionSequence(steps, options = {}) {
  clearTimeout(sequenceTimer);
  sequenceToken += 1;
  const token = sequenceToken;
  let index = 0;
  const previousAnimation = currentAnimation;

  function next() {
    if (token !== sequenceToken) return;
    const step = steps[index];
    if (!step) {
      if (options.returnToPrevious) setAnimation(previousAnimation || "idle");
      return;
    }
    setAnimation(step.animation);
    say(step.line);
    index += 1;
    sequenceTimer = setTimeout(next, step.duration || 1200);
  }

  next();
}

function resizeWindowForPet(size) {
  if (!windowBounds) return;
  const nextSize = Number(size) + 140;
  windowBounds = {
    ...windowBounds,
    width: nextSize,
    height: nextSize
  };
  window.maxie.pet.setBounds(windowBounds);
}

function movementSettings() {
  return {
    randomWalking: true,
    idleExploration: true,
    speed: appState?.pet?.speed || 1,
    explorationFrequency: 0.45,
    jumpHeight: 0.55,
    gravityStrength: 0.35,
    fallChance: 0.08,
    ...(appState?.movement || {})
  };
}

function configurePhysics() {
  if (!physics) return;
  const movement = movementSettings();
  physics.configure({
    speed: Number(movement.speed || appState?.pet?.speed || 1),
    physicsMode: movement.physicsMode,
    gravity: movement.gravity,
    gravityStrength: movement.gravityStrength,
    bounceLanding: movement.bounceLanding
  });
  physics.setFloor(windowBounds?.y || physics.position.y);
}

function applyAvatar(dataUrl) {
  customAvatar.style.backgroundImage = dataUrl ? `url("${dataUrl}")` : "";
  body.classList.toggle("has-avatar", Boolean(dataUrl));
  const palette = appState?.appearance?.palette;
  document.documentElement.style.setProperty("--mint", palette?.primary || "#72d6b2");
  document.documentElement.style.setProperty("--sky", palette?.secondary || "#82b5f7");
}

function say(text) {
  if (!text) return;
  bubble.textContent = text;
  bubble.hidden = false;
  speak(text);
  clearTimeout(bubble.hideTimer);
  bubble.hideTimer = setTimeout(() => {
    bubble.hidden = true;
  }, 4200);
}

function speak(text) {
  if (!appState?.features?.voice || !window.speechSynthesis) return;
  const spoken = String(text).replace(/[^\w\s.,!?'-]/g, "");
  if (!spoken) return;
  window.speechSynthesis.cancel();
  const utterance = new SpeechSynthesisUtterance(spoken);
  utterance.rate = 1.08;
  utterance.pitch = 1.35;
  window.speechSynthesis.speak(utterance);
}

function showMenu() {
  clearTimeout(menuTimer);
  quickMenu.hidden = false;
  keepInteractive();
  menuTimer = setTimeout(hideMenu, 3000);
}

function hideMenu() {
  clearTimeout(menuTimer);
  quickMenu.hidden = true;
}

function scheduleClickThrough() {
  clearTimeout(clickThroughTimer);
  window.maxie.pet.setClickThrough(false);
  if (!appState?.pet?.clickThroughIdle) return;
  clickThroughTimer = setTimeout(() => {
    if (!dragging && quickMenu.hidden) window.maxie.pet.setClickThrough(true);
  }, 30000);
}

function keepInteractive() {
  clearTimeout(clickThroughTimer);
  window.maxie.pet.setClickThrough(false);
}

function randomPoint() {
  const display = displays[Math.floor(Math.random() * displays.length)] || displays[0];
  const area = display.workArea;
  return {
    x: area.x + 20 + Math.random() * Math.max(80, area.width - 320),
    y: area.y + 20 + Math.random() * Math.max(80, area.height - 320)
  };
}

function randomWalk() {
  const movement = movementSettings();
  if (!movement.randomWalking) return;
  if (demoTimer) return;
  if (!quickMenu.hidden) return;
  if (!physics || ["sleep", "sit", "dance"].includes(currentAnimation)) return;
  const point = randomPoint();
  physics.setTarget(point.x, point.y);
  setAnimation(Math.random() > 0.9 ? "run" : "walk");
}

function followMouse() {
  if (!quickMenu.hidden) return;
  const movement = movementSettings();
  if (!movement.followMouse && !appState?.pet?.followMouse && !movement.avoidMouse) return;
  const dx = mouse.x - physics.position.x;
  const dy = mouse.y - physics.position.y;
  const distance = Math.hypot(dx, dy);
  if (movement.avoidMouse && distance < 230) {
    const awayX = physics.position.x - dx * 0.9;
    const awayY = physics.position.y - dy * 0.9;
    physics.setTarget(awayX, awayY);
    setAnimation("run");
  } else if ((movement.followMouse || appState?.pet?.followMouse) && distance < 300) {
    physics.setTarget(mouse.x - 110, mouse.y - 120);
    setAnimation("run");
  }
}

function runAway() {
  const point = randomPoint();
  physics.setTarget(point.x, point.y);
  playReactionSequence([
    { animation: "surprised", line: "Bro... stop poking me.", duration: 700 },
    { animation: "run", line: "Strategic retreat!", duration: 1300 }
  ]);
}

async function systemPulse() {
  const state = await window.maxie.state.get();
  appState = state;
  brain.hydrate(state);
  configurePhysics();
  document.documentElement.style.setProperty("--pet-size", `${state.pet.size}px`);
  applyAvatar(state.appearance?.avatar);
  renderHome();

  if (state.permissions.activeApp) {
    try {
      const active = await window.maxie.system.getActiveApp();
      lastActiveInfo = active;
      const activeKey = `${active?.name || ""} ${active?.title || ""}`.trim();
      const now = Date.now();
      if (activeKey && (activeKey !== lastActiveApp || now - lastReactionAt > 45000)) {
        lastActiveApp = activeKey;
        lastReactionAt = now;
        const suggestion = brain.observeContext(activeKey);
        moveTowardActiveWindow();
        playReactionSequence(sequenceForContext(activeKey, brain.tick(lastActiveApp)), { returnToPrevious: true });
        if (suggestion) setTimeout(() => playReactionSequence(sequenceForReaction(suggestion), { returnToPrevious: true }), 4200);
      }
    } catch {
      lastActiveInfo = null;
    }
  }

  if (state.permissions.activeApp && window.maxie.system.getMediaApp) {
    try {
      const media = await window.maxie.system.getMediaApp();
      const mediaKey = `${media?.name || ""} ${media?.title || ""}`.trim();
      const now = Date.now();
      if (mediaKey && (mediaKey !== lastMediaApp || now - lastMediaReactionAt > 4 * 60000)) {
        lastMediaApp = mediaKey;
        lastMediaReactionAt = now;
        lastReactionAt = now;
        playReactionSequence(sequenceForContext(mediaKey, brain.reactToApp(mediaKey)), { returnToPrevious: true });
      }
    } catch {
      lastMediaApp = "";
    }
  }

  await reactToSystemContext();

  if (!demoTimer && quickMenu.hidden && Date.now() - lastReactionAt > 15000) {
    const reaction = brain.tick(lastActiveApp);
    if (reaction.animation && Math.random() > 0.68) playReactionSequence(sequenceForReaction(reaction), { returnToPrevious: true });
    if (reaction.line && Math.random() > 0.86) say(reaction.line);
  }
  await saveBrain(false);
  syncDemoMode();
  scheduleAdvancedMovement();
  scheduleWorldMoment();
  scheduleNextLevelMoment();
}

function worldSettings() {
  return {
    enabled: true,
    toysEnabled: true,
    weatherEnabled: true,
    frequency: 0.5,
    weatherMode: "auto",
    ...(appState?.world || {})
  };
}

function scheduleWorldMoment(immediate = false) {
  if (worldTimer && !immediate) return;
  clearTimeout(worldTimer);
  const world = worldSettings();
  if (!world.enabled || demoTimer) return;
  const frequency = Math.max(0, Math.min(1, Number(world.frequency) || 0));
  const delay = immediate ? 2500 : 12000 + (1 - frequency) * 26000 + Math.random() * 9000;
  worldTimer = setTimeout(() => {
    worldTimer = null;
    performWorldMoment();
    scheduleWorldMoment();
  }, delay);
}

async function performWorldMoment() {
  if (!quickMenu.hidden || dragging || demoTimer) return;
  const world = worldSettings();
  const items = ["burger", "butterfly", "gift", "ball", "coffee", "bird"];
  if (world.toysEnabled) items.push("football", "yoyo", "balloon", "kite", "bone", "teddy", "book", "phone", "guitar", "switch");
  if (world.weatherEnabled && Math.random() > 0.45) return performWeatherMoment();
  const item = items[Math.floor(Math.random() * items.length)];
  spawnWorldItem(item);
  const result = brain.applyWorldReward(item);
  playReactionSequence(sequenceForWorldItem(item, result), { returnToPrevious: true });
  await saveBrain();
}

function performWeatherMoment() {
  const mode = currentWeatherMode();
  const sequences = {
    rain: [
      { animation: "rainy", line: "Rainy cozy mode.", duration: 700 },
      { animation: "umbrella", line: "Umbrella deployed.", duration: 1200 }
    ],
    wind: [
      { animation: "surprised", line: "Wind picked up.", duration: 650 },
      { animation: "wind", line: "Whoosh. Almost flew away.", duration: 1400 },
      { animation: "recover", line: "Recovered with style.", duration: 800 }
    ],
    snow: [
      { animation: "cold", line: "Snow mood.", duration: 700 },
      { animation: "snowman", line: "Built a tiny snowman.", duration: 1300 }
    ],
    hot: [
      { animation: "sunny", line: "It feels warm.", duration: 650 },
      { animation: "icecream", line: "Ice cream break.", duration: 1300 }
    ],
    cold: [
      { animation: "cold", line: "Brrr.", duration: 650 },
      { animation: "blanket", line: "Blanket mode.", duration: 1300 }
    ]
  };
  playReactionSequence(sequences[mode] || sequences.rain, { returnToPrevious: true });
}

function currentWeatherMode() {
  const mode = worldSettings().weatherMode || "auto";
  if (mode !== "auto") return mode;
  const month = new Date().getMonth() + 1;
  const hour = new Date().getHours();
  if (month >= 11 || month <= 2) return "cold";
  if (hour >= 12 && hour <= 16) return "hot";
  return ["rain", "wind", "cloudy"][Math.floor(Math.random() * 3)] === "cloudy" ? "rain" : ["rain", "wind"][Math.floor(Math.random() * 2)];
}

function spawnWorldItem(kind) {
  if (!worldLayer) return;
  const item = document.createElement("span");
  item.className = `world-item world-${kind}`;
  item.textContent = worldIcon(kind);
  item.style.left = `${20 + Math.random() * 58}%`;
  item.style.setProperty("--drift", `${Math.random() > 0.5 ? 1 : -1}`);
  worldLayer.append(item);
  item.addEventListener("animationend", () => item.remove(), { once: true });
}

function worldIcon(kind) {
  const icons = {
    burger: "\u{1F354}",
    butterfly: "\u{1F98B}",
    gift: "\u{1F381}",
    ball: "\u26BD",
    coffee: "\u2615",
    bird: "\u266A",
    football: "\u26BD",
    yoyo: "\u25CE",
    balloon: "\u{1F388}",
    kite: "\u25C7",
    bone: "\u{1F9B4}",
    teddy: "\u{1F9F8}",
    book: "\u{1F4DA}",
    phone: "\u{1F4F1}",
    guitar: "\u{1F3B8}",
    switch: "\u{1F3AE}",
    ufo: "\u25CE",
    dragon: "\u2726",
    meteor: "\u2604",
    rainbow: "\u25D2",
    treasure: "\u{1F381}",
    robot: "\u{1F916}",
    fireworks: "\u2736",
    package: "\u{1F4E6}",
    pizza: "\u{1F355}",
    cake: "\u{1F382}"
  };
  return icons[kind] || "\u2726";
}

function nextLevelSettings() {
  return {
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
    eventFrequency: 0.4,
    ...(appState?.nextLevel || {})
  };
}

function scheduleNextLevelMoment(immediate = false) {
  if (nextLevelTimer && !immediate) return;
  clearTimeout(nextLevelTimer);
  const settings = nextLevelSettings();
  const enabled = Object.entries(settings).some(([key, value]) => key !== "eventFrequency" && value === true);
  if (!enabled || demoTimer) return;
  const frequency = Math.max(0, Math.min(1, Number(settings.eventFrequency) || 0));
  const delay = immediate ? 4500 : 18000 + (1 - frequency) * 42000 + Math.random() * 14000;
  nextLevelTimer = setTimeout(() => {
    nextLevelTimer = null;
    performNextLevelMoment();
    scheduleNextLevelMoment();
  }, delay);
}

async function performNextLevelMoment() {
  if (!quickMenu.hidden || dragging || demoTimer) return;
  const settings = nextLevelSettings();
  const candidates = [];
  if (settings.petInteractions) candidates.push("pet-interaction");
  if (settings.familySystem) candidates.push("family");
  if (settings.evolution) candidates.push("evolve");
  if (settings.adventures) candidates.push("adventure");
  if (settings.storyEngine) candidates.push("story");
  if (settings.moodWheel) candidates.push("mood-wheel");
  if (settings.cinematicEvents) candidates.push("cinematic");
  if (settings.seasonalUpdates) candidates.push("seasonal");
  if (settings.homeBuilder) candidates.push("home");
  if (!candidates.length) return;
  const kind = candidates[Math.floor(Math.random() * candidates.length)];

  if (kind === "pet-interaction") {
    showCompanion(true);
    const reaction = brain.nextLevelMoment(kind);
    playReactionSequence([
      { animation: reaction.animation, line: reaction.line, duration: 1300 },
      { animation: "love", line: "Two-pet moment saved.", duration: 900 }
    ], { returnToPrevious: true });
    setTimeout(() => showCompanion(false), 4200);
  } else if (kind === "adventure") {
    await runAdventureMoment();
  } else if (kind === "mood-wheel") {
    playReactionSequence([brain.moodWheelReaction()], { returnToPrevious: true });
  } else if (kind === "cinematic") {
    runCinematicMoment();
  } else if (kind === "seasonal") {
    runSeasonalMoment();
  } else if (kind === "home") {
    renderHome(true);
    playReactionSequence([{ animation: "happy", line: "Home corner decorated.", duration: 1300 }], { returnToPrevious: true });
  } else {
    playReactionSequence([brain.nextLevelMoment(kind)], { returnToPrevious: true });
  }
  await saveBrain();
}

async function runAdventureMoment() {
  if (adventureAway) return;
  adventureAway = true;
  playReactionSequence([
    { animation: "adventure", line: "Going on a tiny adventure.", duration: 1200 },
    { animation: "run", line: "Back in a moment.", duration: 900 }
  ], { returnToPrevious: true });
  pet.classList.add("is-adventuring");
  setTimeout(async () => {
    const reward = brain.nextLevelMoment("adventure-return");
    pet.classList.remove("is-adventuring");
    spawnWorldItem(reward.animation);
    playReactionSequence([
      { animation: reward.animation, line: reward.line, duration: 1200 },
      { animation: "celebrate", line: "Adventure reward saved.", duration: 900 }
    ], { returnToPrevious: true });
    adventureAway = false;
    await saveBrain();
  }, 45000);
}

function runCinematicMoment() {
  const events = [
    { item: "ufo", animation: "ufo", line: "Rare event: UFO fly-by." },
    { item: "dragon", animation: "dragon", line: "Rare event: dragon shadow." },
    { item: "meteor", animation: "meteor", line: "Rare event: meteor shower." },
    { item: "rainbow", animation: "rainbow", line: "Rare event: rainbow appeared." },
    { item: "treasure", animation: "treasure", line: "Rare event: treasure chest." },
    { item: "robot", animation: "robot", line: "Rare event: tiny robot visit." },
    { item: "fireworks", animation: "fireworks", line: "Rare event: fireworks!" }
  ];
  const event = events[Math.floor(Math.random() * events.length)];
  spawnWorldItem(event.item);
  playReactionSequence([
    { animation: "surprised", line: "Wait, what is that?", duration: 700 },
    { animation: event.animation, line: event.line, duration: 1600 },
    { animation: "sparklehappy", line: "That was rare.", duration: 900 }
  ], { returnToPrevious: true });
}

function runSeasonalMoment() {
  const month = new Date().getMonth() + 1;
  const seasonal = month === 12 ? "hat" : month === 10 ? "ghost" : month >= 3 && month <= 5 ? "butterfly" : "rainbow";
  spawnWorldItem(seasonal);
  playReactionSequence([
    { animation: seasonal, line: "Seasonal update moment.", duration: 1200 },
    { animation: "costume", line: "Monthly freshness unlocked.", duration: 900 }
  ], { returnToPrevious: true });
}

function showCompanion(visible) {
  if (!companionPet) return;
  companionPet.classList.toggle("is-visible", visible);
}

function renderHome(animated = false) {
  if (!homeLayer) return;
  const settings = nextLevelSettings();
  homeLayer.innerHTML = "";
  if (!settings.homeBuilder) return;
  const equipped = appState?.home?.equipped || ["bed", "bookshelf"];
  for (const item of equipped.slice(0, 5)) {
    const node = document.createElement("span");
    node.className = "home-item";
    node.textContent = homeIcon(item);
    if (animated) node.style.animation = "prop-pop .9s ease-in-out";
    homeLayer.append(node);
  }
}

function homeIcon(item) {
  return {
    bed: "\u25AD",
    sofa: "\u25AC",
    tv: "\u25A3",
    computer: "\u{1F4BB}",
    bookshelf: "\u{1F4DA}",
    kitchen: "\u{1F354}",
    garden: "\u273F"
  }[item] || "\u25A1";
}

function scheduleAdvancedMovement(immediate = false) {
  if (movementTimer && !immediate) return;
  clearTimeout(movementTimer);
  if (!appState || demoTimer) return;
  const movement = movementSettings();
  const frequency = Math.max(0, Math.min(1, Number(movement.explorationFrequency) || 0));
  const hasAdvanced = movement.edgeWalking || movement.windowEdgeWalking || movement.wallClimbing ||
    movement.ceilingWalking || movement.hanging || movement.jumpBetweenWindows || movement.sitOnWindow ||
    movement.idleExploration || movement.slipAndFall;
  if (!hasAdvanced && !movement.randomWalking) return;
  const delay = immediate ? 1500 : 5000 + (1 - frequency) * 16000 + Math.random() * 4500;
  movementTimer = setTimeout(() => {
    movementTimer = null;
    performAdvancedMovement();
    scheduleAdvancedMovement();
  }, delay);
}

function performAdvancedMovement() {
  if (!physics || dragging || !quickMenu.hidden || demoTimer) return;
  const movement = movementSettings();
  const candidates = [];
  if (movement.idleExploration) candidates.push("explore");
  if (movement.edgeWalking) candidates.push("edgewalk");
  if (movement.windowEdgeWalking) candidates.push("windowedge");
  if (movement.wallClimbing) candidates.push("wallwalk");
  if (movement.ceilingWalking) candidates.push("ceilingwalk");
  if (movement.hanging) candidates.push("hang");
  if (movement.jumpBetweenWindows) candidates.push("leap");
  if (movement.sitOnWindow) candidates.push("sitwindow");
  if (movement.slipAndFall && Math.random() < Number(movement.fallChance || 0.08)) candidates.push("slip");
  if (!candidates.length) return;
  const mode = candidates[Math.floor(Math.random() * candidates.length)];
  activeMoveMode = mode;
  if (mode === "edgewalk") return moveToScreenEdge();
  if (mode === "windowedge" || mode === "sitwindow") return moveNearForegroundWindow(mode);
  if (mode === "wallwalk") return climbScreenWall();
  if (mode === "ceilingwalk") return walkCeiling();
  if (mode === "hang") return hangFromTop();
  if (mode === "leap") return jumpAcrossScreen();
  if (mode === "slip") return slipAndRecover();
  return idleExplore();
}

function currentWorkArea() {
  const display = displays.find((item) => {
    const area = item.workArea;
    return physics.position.x >= area.x && physics.position.x <= area.x + area.width &&
      physics.position.y >= area.y && physics.position.y <= area.y + area.height;
  }) || displays[0];
  return display?.workArea || { x: 0, y: 0, width: 1200, height: 800 };
}

function moveToScreenEdge() {
  const area = currentWorkArea();
  const size = windowBounds?.width || 320;
  const edges = [
    { x: area.x + 8, y: area.y + Math.random() * Math.max(80, area.height - size), animation: "edgewalk" },
    { x: area.x + area.width - size - 8, y: area.y + Math.random() * Math.max(80, area.height - size), animation: "edgewalk" },
    { x: area.x + Math.random() * Math.max(80, area.width - size), y: area.y + area.height - size - 8, animation: "edgewalk" }
  ];
  const target = edges[Math.floor(Math.random() * edges.length)];
  physics.setTarget(target.x, target.y);
  playReactionSequence([
    { animation: "walk", line: "Edge walk.", duration: 800 },
    { animation: target.animation, line: "Balancing carefully.", duration: 1600 }
  ], { returnToPrevious: true });
}

function moveNearForegroundWindow(mode) {
  const area = currentWorkArea();
  const size = windowBounds?.width || 320;
  const bounds = validWindowBounds(lastActiveInfo?.bounds) || {
    x: area.x + area.width * 0.28,
    y: area.y + area.height * 0.24,
    width: area.width * 0.45,
    height: area.height * 0.32
  };
  const target = mode === "sitwindow"
    ? { x: bounds.x + bounds.width * 0.52, y: bounds.y - size * 0.42 }
    : { x: bounds.x + bounds.width - size * 0.35, y: bounds.y + bounds.height * 0.16 };
  physics.setTarget(Math.min(target.x, area.x + area.width - size), Math.min(target.y, area.y + area.height - size));
  playReactionSequence([
    { animation: "walk", line: mode === "sitwindow" ? "Finding a window ledge." : "Checking the window edge.", duration: 850 },
    { animation: mode, line: mode === "sitwindow" ? "Sitting here for a tiny break." : "Experimental window-edge walk.", duration: 1800 }
  ], { returnToPrevious: true });
}

function climbScreenWall() {
  const area = currentWorkArea();
  const size = windowBounds?.width || 320;
  const sideX = Math.random() > 0.5 ? area.x + 8 : area.x + area.width - size - 8;
  physics.setTarget(sideX, area.y + area.height * 0.18);
  playReactionSequence([
    { animation: "grab", line: "Grab.", duration: 650 },
    { animation: "climb", line: "Wall climbing.", duration: 1300 },
    { animation: "wallwalk", line: "Tiny spider mode.", duration: 1200 }
  ], { returnToPrevious: true });
}

function walkCeiling() {
  const area = currentWorkArea();
  const size = windowBounds?.width || 320;
  physics.setTarget(area.x + Math.random() * Math.max(80, area.width - size), area.y + 8);
  playReactionSequence([
    { animation: "climb", line: "Climbing up.", duration: 900 },
    { animation: "ceilingwalk", line: "Ceiling walking.", duration: 1800 },
    { animation: "land", line: "Soft landing.", duration: 700 }
  ], { returnToPrevious: true });
}

function hangFromTop() {
  const area = currentWorkArea();
  const size = windowBounds?.width || 320;
  physics.setTarget(area.x + Math.random() * Math.max(80, area.width - size), area.y + 6);
  playReactionSequence([
    { animation: "grab", line: "Caught it.", duration: 650 },
    { animation: "hang", line: "Just hanging around.", duration: 1900 },
    { animation: "land", line: "Down safely.", duration: 700 }
  ], { returnToPrevious: true });
}

function jumpAcrossScreen() {
  const area = currentWorkArea();
  const size = windowBounds?.width || 320;
  const jumpHeight = Math.max(0, Math.min(1, Number(movementSettings().jumpHeight) || 0.55));
  const targetY = area.y + area.height * (0.18 + (1 - jumpHeight) * 0.35);
  physics.setTarget(area.x + Math.random() * Math.max(80, area.width - size), targetY);
  playReactionSequence([
    { animation: "grab", line: "Preparing jump.", duration: 500 },
    { animation: "leap", line: "Jump!", duration: 1000 },
    { animation: "land", line: "Bounce landing.", duration: 800 },
    { animation: "recover", line: "Recovered.", duration: 650 }
  ], { returnToPrevious: true });
}

function slipAndRecover() {
  const target = randomPoint();
  physics.setTarget(target.x, target.y);
  playReactionSequence([
    { animation: "edgewalk", line: "Careful...", duration: 700 },
    { animation: "slip", line: "Oops.", duration: 850 },
    { animation: "fall", line: "I am fine.", duration: 800 },
    { animation: "recover", line: "Recovered.", duration: 900 }
  ], { returnToPrevious: true });
}

function idleExplore() {
  const target = randomPoint();
  physics.setTarget(target.x, target.y);
  playReactionSequence([
    { animation: "explore", line: "Exploring quietly.", duration: 900 },
    { animation: "walk", line: "", duration: 900 },
    { animation: "sit", line: "Found a nice spot.", duration: 900 }
  ], { returnToPrevious: true });
}

function validWindowBounds(bounds) {
  if (!bounds || bounds.width < 160 || bounds.height < 120) return null;
  if (bounds.x < -32000 || bounds.y < -32000) return null;
  return bounds;
}

function moveTowardActiveWindow() {
  if (!physics || !lastActiveInfo?.bounds) return;
  const bounds = validWindowBounds(lastActiveInfo.bounds);
  if (!bounds) return;
  const area = currentWorkArea();
  const size = windowBounds?.width || 320;
  const x = Math.max(area.x, Math.min(bounds.x + 24, area.x + area.width - size));
  const y = Math.max(area.y, Math.min(bounds.y + bounds.height - size * 0.72, area.y + area.height - size));
  physics.setTarget(x, y);
  setAnimation("walk");
}

async function reactToSystemContext() {
  const now = Date.now();
  const hour = new Date().getHours();
  const dayKey = new Date().toISOString().slice(0, 10);

  if (hour === 23 && lastTimeGreeting !== `${dayKey}-night`) {
    lastTimeGreeting = `${dayKey}-night`;
    playReactionSequence([
      { animation: "yawn", line: "It is 11 PM.", duration: 900 },
      { animation: "stretch", line: "Getting sleepy.", duration: 900 },
      { animation: "bed", line: "Tiny bedtime mode.", duration: 1400 }
    ], { returnToPrevious: true });
    return;
  }

  if (hour >= 6 && hour <= 9 && lastTimeGreeting !== `${dayKey}-morning`) {
    lastTimeGreeting = `${dayKey}-morning`;
    playReactionSequence([
      { animation: "stretch", line: "Good morning!", duration: 1000 },
      { animation: "happy", line: "Fresh desktop day.", duration: 1000 }
    ], { returnToPrevious: true });
    return;
  }

  if (now - lastSystemCheckAt < 30000) return;
  lastSystemCheckAt = now;
  let snapshot;
  try {
    snapshot = await window.maxie.system.getSnapshot();
  } catch {
    return;
  }
  if (snapshot.battery?.supported && snapshot.battery.percent <= 10 && !snapshot.battery.charging && lastSystemReaction !== "battery-low") {
    lastSystemReaction = "battery-low";
    playReactionSequence([
      { animation: "surprised", line: "Battery is at 10%.", duration: 700 },
      { animation: "battery", line: "Please plug in soon.", duration: 1500 },
      { animation: "worry", line: "I am holding the tiny battery.", duration: 1200 }
    ], { returnToPrevious: true });
  } else if (snapshot.battery?.supported && snapshot.battery.charging && lastSystemReaction !== "battery-charging") {
    lastSystemReaction = "battery-charging";
    playReactionSequence([
      { animation: "battery", line: "Charging detected.", duration: 1000 },
      { animation: "happy", line: "Power restored.", duration: 900 }
    ], { returnToPrevious: true });
  }
}

async function saveBrain(force = true) {
  const now = Date.now();
  if (!force && now - lastStateSaveAt < 30000) return;
  lastStateSaveAt = now;
  const personality = {
    ...appState.personality,
    friendship: Math.round(brain.state.friendship),
    xp: Math.round(brain.state.xp),
    growth: brain.state.growth
  };
  await window.maxie.state.set({ personality, ...brain.snapshot() });
}

async function trackActiveMinute() {
  if (!appState) return;
  const stats = {
    ...(appState.stats || {}),
    activeMinutes: Number(appState.stats?.activeMinutes || 0) + 1
  };
  if (lastActiveApp.toLowerCase().includes("code")) {
    stats.codeMinutes = Number(stats.codeMinutes || 0) + 1;
  }
  await window.maxie.state.set({ stats });
}

async function moveWindowTo(x, y) {
  if (!windowBounds) windowBounds = await window.maxie.pet.getBounds();
  windowBounds = { ...windowBounds, x, y };
  physics.position = { x, y };
  physics.setTarget(x, y);
  await window.maxie.pet.setBounds(windowBounds);
}

async function loop() {
  if (physics) {
    if (!dragging && quickMenu.hidden) {
      followMouse();
      const next = physics.step();
      const now = performance.now();
      if (windowBounds && now - lastMoveAt > 66) {
        lastMoveAt = now;
        windowBounds = { ...windowBounds, x: next.x, y: next.y };
        await window.maxie.pet.setBounds(windowBounds);
      }
    }
    if (physics.isNearTarget() && ["walk", "run"].includes(currentAnimation)) {
      setAnimation(Math.random() > 0.5 ? "idle" : "sit");
    }
  }
  requestAnimationFrame(loop);
}

pet.addEventListener("pointerdown", async (event) => {
  if (event.button !== 0) return;
  keepInteractive();
  dragging = true;
  didDrag = false;
  hideMenu();
  dragStart = { x: event.screenX, y: event.screenY };
  dragBounds = await window.maxie.pet.getBounds();
  pet.setPointerCapture(event.pointerId);
});

pet.addEventListener("pointermove", async (event) => {
  if (!dragging || !dragStart || !dragBounds) return;
  const dx = event.screenX - dragStart.x;
  const dy = event.screenY - dragStart.y;
  if (Math.hypot(dx, dy) > 10) didDrag = true;
  if (!didDrag) return;
  hideMenu();
  setAnimation("walk");
  await moveWindowTo(dragBounds.x + dx, dragBounds.y + dy);
});

pet.addEventListener("pointerup", async (event) => {
  if (!dragging) return;
  dragging = false;
  if (pet.hasPointerCapture(event.pointerId)) pet.releasePointerCapture(event.pointerId);
  if (didDrag) {
    hideMenu();
    setAnimation("idle");
    suppressNextClick = true;
    setTimeout(() => {
      suppressNextClick = false;
    }, 180);
    await saveBrain();
    return;
  }
  const now = Date.now();
  if (now - lastClickAt < 650) {
    const reaction = brain.interact("click");
    await saveBrain();
    if (reaction.animation === "run") {
      hideMenu();
      runAway();
      return;
    }
  }
  lastClickAt = now;
  showMenu();
  scheduleClickThrough();
});

pet.addEventListener("click", () => {
  if (suppressNextClick) return;
  showMenu();
});

pet.addEventListener("contextmenu", (event) => {
  event.preventDefault();
  keepInteractive();
  showMenu();
});

quickMenu.addEventListener("click", async (event) => {
  const action = event.target.dataset.action;
  if (!action) return;
  hideMenu();
  keepInteractive();
  if (action === "settings") {
    await window.maxie.settings.open();
    scheduleClickThrough();
    return;
  }
  if (action === "hide") {
    await window.maxie.pet.hide();
    return;
  }
  if (action === "photo") {
    await window.maxie.pet.photo();
    playReactionSequence(sequenceForAction(action, brain.interact(action)));
    return;
  }
  const reaction = brain.interact(action);
  playReactionSequence(sequenceForAction(action, reaction));
  await saveBrain();
  scheduleClickThrough();
});

quickMenu.addEventListener("pointerenter", () => {
  clearTimeout(menuTimer);
});

quickMenu.addEventListener("pointerleave", () => {
  menuTimer = setTimeout(hideMenu, 1000);
});

function sequenceForAction(action, fallback) {
  const sequences = {
    feed: [
      { animation: "hungry", line: "Snack thoughts activated.", duration: 900 },
      { animation: "eat", line: "Eating yummy!", duration: 1200 },
      { animation: "drink", line: "Sip sip.", duration: 1000 },
      { animation: "full", line: "So full. Tiny burp.", duration: 1400 },
      { animation: "happy", line: "Thank you!", duration: 1200 }
    ],
    dance: [
      { animation: "headphones", line: "Headphones on.", duration: 900 },
      { animation: "listen", line: "Feeling the music.", duration: 900 },
      { animation: "sing", line: "Tiny concert mode.", duration: 1100 },
      { animation: "dance", line: "Dancing time!", duration: 1800 },
      { animation: "laugh", line: "Hehe, cute moves.", duration: 1200 }
    ],
    sleep: [
      { animation: "yawn", line: "Big tiny yawn.", duration: 1000 },
      { animation: "stretch", line: "Stretching...", duration: 1200 },
      { animation: "sleep", line: "Zzz...", duration: 2200 }
    ],
    listen: [
      { animation: "wave", line: "Hi hi!", duration: 900 },
      { animation: "listen", line: "I'm listening.", duration: 1300 },
      { animation: "surprised", line: "Wait, really?", duration: 1000 },
      { animation: "thinking", line: "Hmm... thinking.", duration: 1100 },
      { animation: "idea", line: "Got an idea.", duration: 1000 },
      { animation: "highfive", line: "High five!", duration: 1000 }
    ],
    gift: [
      { animation: "gift", line: "I found a surprise for you.", duration: 1100 },
      { animation: "celebrate", line: fallback.line, duration: 1300 }
    ],
    photo: [
      { animation: "happy", line: "Photo saved.", duration: 1200 },
      { animation: "thumbsup", line: "Ready to post.", duration: 1000 }
    ],
    game: [
      { animation: "controller", line: "Mini-game time.", duration: 1000 },
      { animation: "gaming", line: "Rock, paper, scissors?", duration: 1400 }
    ]
  };
  return sequences[action] || [fallback];
}

function sequenceForWorldItem(item, result) {
  const sequences = {
    burger: [
      { animation: "hungry", line: "Burger dropped!", duration: 700 },
      { animation: "eat", line: "Eating yummy.", duration: 1200 },
      { animation: "full", line: "Burger disappeared. XP gained.", duration: 1000 }
    ],
    butterfly: [
      { animation: "surprised", line: "Butterfly!", duration: 650 },
      { animation: "butterfly", line: "Chasing it softly.", duration: 1400 },
      { animation: "laugh", line: "That was adorable.", duration: 900 }
    ],
    gift: [
      { animation: "gift", line: "A tiny gift appeared.", duration: 950 },
      { animation: "sparklehappy", line: result.line, duration: 1100 },
      { animation: "celebrate", line: "Coins and XP added.", duration: 900 }
    ],
    ball: [
      { animation: "football", line: "Ball rolled in.", duration: 900 },
      { animation: "run", line: "Kick!", duration: 800 },
      { animation: "happy", line: "Goal energy.", duration: 850 }
    ],
    coffee: [
      { animation: "drink", line: "Coffee cup spotted.", duration: 900 },
      { animation: "focused", line: "Focus fuel.", duration: 1000 }
    ],
    bird: [
      { animation: "surprised", line: "A tiny tune landed.", duration: 700 },
      { animation: "listen", line: "Listening to the chirp.", duration: 1000 },
      { animation: "wave", line: "Bye bye.", duration: 800 }
    ],
    football: toySequence("football", "Football practice."),
    yoyo: toySequence("yoyo", "Yo-yo trick unlocked."),
    balloon: toySequence("balloon", "Balloon floaty mode."),
    kite: toySequence("kite", "Kite caught the wind."),
    bone: toySequence("bone", "Found a bone toy."),
    teddy: toySequence("teddy", "Teddy hug time."),
    book: toySequence("book", "Reading a tiny book."),
    phone: toySequence("phone", "Phone buzz buzz."),
    guitar: toySequence("guitar", "Guitar solo."),
    switch: toySequence("switch", "Switch game time.")
  };
  return sequences[item] || [{ animation: result.animation, line: result.line, duration: 1200 }];
}

function toySequence(animation, line) {
  return [
    { animation, line, duration: 1100 },
    { animation: animation === "guitar" ? "sing" : animation === "switch" ? "gaming" : "happy", line: "Toy equipped. Fun went up.", duration: 1000 }
  ];
}

function sequenceForReaction(reaction) {
  const sequences = {
    notification: [
      { animation: "sleep", line: "", duration: 350 },
      { animation: "surprised", line: "A notification arrived!", duration: 750 },
      { animation: "jump", line: reaction.line, duration: 800 },
      { animation: "wave", line: "I'm on it.", duration: 850 }
    ],
    message: [
      { animation: "surprised", line: "New message?", duration: 700 },
      { animation: "message", line: reaction.line, duration: 1100 },
      { animation: "happy", line: "Good news energy.", duration: 900 }
    ],
    typing: [
      { animation: "sit", line: "Opening tiny laptop.", duration: 650 },
      { animation: "typing", line: reaction.line, duration: 1300 },
      { animation: "thinking", line: "Checking logic.", duration: 900 }
    ],
    headphones: [
      { animation: "surprised", line: "I hear music.", duration: 650 },
      { animation: "headphones", line: "Headphones on.", duration: 900 },
      { animation: "dance", line: reaction.line, duration: 1400 }
    ],
    watching: [
      { animation: "sit", line: "Settling in.", duration: 600 },
      { animation: "popcorn", line: "Popcorn mode.", duration: 950 },
      { animation: "watching", line: reaction.line, duration: 1300 }
    ],
    sleep: [
      { animation: "yawn", line: "Tiny yawn...", duration: 850 },
      { animation: "stretch", line: "Stretching.", duration: 850 },
      { animation: "sleep", line: reaction.line || "Zzz...", duration: 1500 }
    ]
  };
  return sequences[reaction.animation] || [
    { animation: "thinking", line: "", duration: 350 },
    { animation: reaction.animation || "idle", line: reaction.line || "", duration: 1200 }
  ];
}

function sequenceForContext(activeKey, reaction) {
  const app = activeKey.toLowerCase();
  if (app.includes("code") || app.includes("android studio") || app.includes("studio64")) return [
    { animation: "walk", line: app.includes("android") || app.includes("studio64") ? "Android Studio time." : "VS Code time.", duration: 800 },
    { animation: "sit", line: "Walking over to help.", duration: 650 },
    { animation: "laptop", line: "Opening tiny laptop.", duration: 1000 },
    { animation: "typing", line: "MAXie coding mode.", duration: 1500 },
    { animation: "thinking", line: app.includes("extension") ? "Extension context noticed." : "Thinking through the bug.", duration: 900 },
    { animation: "success", line: reaction.line || "We can solve this.", duration: 900 }
  ];
  if (app.includes("terminal") || app.includes("powershell") || app.includes("cmd") || app.includes("windows terminal")) return [
    { animation: "walk", line: "Terminal detected.", duration: 700 },
    { animation: "laptop", line: "Command center mode.", duration: 1000 },
    { animation: "typing", line: "Watching the command flow.", duration: 1300 },
    { animation: "thinking", line: "No keylogging, just app context.", duration: 900 }
  ];
  if (app.includes("github") || app.includes("commit")) return [
    { animation: "surprised", line: "GitHub activity spotted.", duration: 700 },
    { animation: "typing", line: "Commit check energy.", duration: 1000 },
    { animation: "celebrate", line: "Ship it carefully.", duration: 900 }
  ];
  if (app.includes("spotify") || app.includes("youtube music") || app.includes("music.youtube") || app.includes("music") || app.includes("vlc") || app.includes("now playing")) return [
    { animation: "surprised", line: "Nice song!", duration: 650 },
    { animation: "headphones", line: "Headphones on.", duration: 1000 },
    { animation: "listen", line: "Feeling the beat.", duration: 1000 },
    { animation: "dance", line: reaction.line || "Dancing with you.", duration: 1700 }
  ];
  if (app.includes("youtube")) return [
    { animation: "walk", line: "YouTube time.", duration: 700 },
    { animation: "sit", line: "Sitting to watch.", duration: 650 },
    { animation: "popcorn", line: "Got popcorn.", duration: 1000 },
    { animation: "watching", line: reaction.line || "I'm watching too.", duration: 1500 },
    { animation: "laugh", line: "That part was funny.", duration: 850 }
  ];
  if (app.includes("chrome") || app.includes("edge") || app.includes("brave") || app.includes("firefox")) return [
    { animation: "walk", line: "Browser opened.", duration: 700 },
    { animation: "thinking", line: "What are we learning today?", duration: 1100 },
    { animation: "idea", line: "I am curious too.", duration: 900 }
  ];
  if (app.includes("whatsapp")) return [
    { animation: "surprised", line: "WhatsApp time.", duration: 700 },
    { animation: "message", line: "Reading the message vibe.", duration: 1000 },
    { animation: "wave", line: reaction.line || "Tell them MAXie says hi.", duration: 1000 },
    { animation: "listen", line: "I will wait while you chat.", duration: 900 }
  ];
  if (app.includes("discord") || app.includes("message") || app.includes("telegram") || app.includes("mail")) return [
    { animation: "surprised", line: "Message time.", duration: 700 },
    { animation: "message", line: "Reading the ping.", duration: 1000 },
    { animation: "wave", line: reaction.line || "Hi hi!", duration: 900 },
    { animation: "listen", line: "Back to listening.", duration: 900 }
  ];
  if (app.includes("steam") || app.includes("game")) return [
    { animation: "controller", line: "Game detected.", duration: 900 },
    { animation: "gaming", line: "Controller ready.", duration: 1300 },
    { animation: "focused", line: "Locked in.", duration: 900 }
  ];
  if (app.includes("obs")) return [
    { animation: "surprised", line: "OBS Studio detected.", duration: 700 },
    { animation: "wave", line: "Recording-ready.", duration: 900 },
    { animation: "happy", line: "Demo Mode could help.", duration: 900 }
  ];
  if (app.includes("photoshop") || app.includes("figma") || app.includes("blender")) return [
    { animation: "idea", line: app.includes("blender") ? "3D creation mode." : "Design mode.", duration: 900 },
    { animation: "focused", line: "Creative focus activated.", duration: 1100 },
    { animation: "thumbsup", line: "This can look amazing.", duration: 900 }
  ];
  return sequenceForReaction(reaction);
}

function syncDemoMode() {
  const enabled = Boolean(appState?.features?.demoMode);
  if (!enabled && demoTimer) {
    clearInterval(demoTimer);
    demoTimer = null;
    setAnimation("idle");
    return;
  }
  if (!enabled || demoTimer) return;
  const demo = [
    { animation: "walk", line: "Demo: walking.", duration: 1200 },
    { animation: "edgewalk", line: "Demo: edge walking.", duration: 1200 },
    { animation: "climb", line: "Demo: wall climbing.", duration: 1000 },
    { animation: "hang", line: "Demo: hanging.", duration: 1000 },
    { animation: "leap", line: "Demo: jumping.", duration: 900 },
    { animation: "land", line: "Demo: bounce landing.", duration: 700 },
    { animation: "wave", line: "Demo: waving hello.", duration: 1000 },
    { animation: "laptop", line: "Demo: laptop coding.", duration: 1200 },
    { animation: "typing", line: "Demo: coding mode.", duration: 1100 },
    { animation: "headphones", line: "Demo: music mode.", duration: 1000 },
    { animation: "dance", line: "Demo: dancing.", duration: 1300 },
    { animation: "popcorn", line: "Demo: YouTube snack.", duration: 1000 },
    { animation: "watching", line: "Demo: watching with you.", duration: 1000 },
    { animation: "battery", line: "Demo: battery reaction.", duration: 900 },
    { animation: "worry", line: "Demo: worried face.", duration: 800 },
    { animation: "blushhappy", line: "Demo: blush happy.", duration: 800 },
    { animation: "love", line: "Demo: friendship hearts.", duration: 800 },
    { animation: "shy", line: "Demo: shy face.", duration: 800 },
    { animation: "dizzy", line: "Demo: dizzy fall.", duration: 800 },
    { animation: "eat", line: "Demo: food time.", duration: 1000 },
    { animation: "football", line: "Demo: football toy.", duration: 900 },
    { animation: "yoyo", line: "Demo: yo-yo.", duration: 900 },
    { animation: "teddy", line: "Demo: teddy hug.", duration: 900 },
    { animation: "guitar", line: "Demo: guitar.", duration: 900 },
    { animation: "umbrella", line: "Demo: rainy umbrella.", duration: 900 },
    { animation: "wind", line: "Demo: blown by wind.", duration: 900 },
    { animation: "snowman", line: "Demo: snowman.", duration: 900 },
    { animation: "icecream", line: "Demo: ice cream.", duration: 900 },
    { animation: "blanket", line: "Demo: blanket cozy.", duration: 900 },
    { animation: "sleep", line: "Demo: sleepy.", duration: 1100 },
    { animation: "slip", line: "Demo: slip.", duration: 800 },
    { animation: "recover", line: "Demo: recover.", duration: 800 },
    { animation: "gift", line: "Demo: surprise gift.", duration: 1000 },
    { animation: "rocket", line: "Demo: rocket launch.", duration: 1000 },
    { animation: "ghost", line: "Demo: ghost mode.", duration: 1000 },
    { animation: "celebrate", line: "Demo complete.", duration: 1000 }
  ];
  playReactionSequence(demo);
  demoTimer = setInterval(() => playReactionSequence(demo), 24000);
}

window.addEventListener("mousemove", (event) => {
  mouse = { x: window.screenX + event.clientX, y: window.screenY + event.clientY };
  keepInteractive();
});

window.maxie.pet.onCommand((command) => {
  if (command.type === "wake") {
    const reaction = brain.userReturned();
    setAnimation(reaction.animation);
    say(reaction.line);
    keepInteractive();
    scheduleClickThrough();
  }
  if (command.type === "dance") {
    const reaction = brain.interact("dance");
    setAnimation(reaction.animation);
    say(reaction.line);
    keepInteractive();
    scheduleClickThrough();
  }
  if (command.type === "gift" || command.type === "photo" || command.type === "game") {
    const reaction = brain.interact(command.type);
    playReactionSequence(sequenceForAction(command.type, reaction));
    keepInteractive();
    saveBrain();
    scheduleClickThrough();
  }
});

window.maxie.state.onChanged((state) => {
  const previousSize = appState?.pet?.size;
  appState = state;
  brain.hydrate(state);
  configurePhysics();
  applyAvatar(state.appearance?.avatar);
  document.documentElement.style.setProperty("--pet-size", `${state.pet.size}px`);
  if (previousSize && previousSize !== state.pet.size) resizeWindowForPet(state.pet.size);
  syncDemoMode();
  scheduleClickThrough();
  scheduleAdvancedMovement(true);
  scheduleWorldMoment(true);
  renderHome();
  scheduleNextLevelMoment(true);
});

boot();
