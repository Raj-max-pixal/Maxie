const fields = {
  name: document.getElementById("name"),
  style: document.getElementById("style"),
  size: document.getElementById("size"),
  sizeValue: document.getElementById("sizeValue"),
  speed: document.getElementById("speed"),
  speedValue: document.getElementById("speedValue"),
  theme: document.getElementById("theme"),
  avatarUpload: document.getElementById("avatarUpload"),
  avatarPreview: document.getElementById("avatarPreview"),
  deleteAvatar: document.getElementById("deleteAvatar"),
  provider: document.getElementById("provider"),
  endpoint: document.getElementById("endpoint"),
  model: document.getElementById("model"),
  apiKey: document.getElementById("apiKey"),
  activeApp: document.getElementById("activeApp"),
  notifications: document.getElementById("notifications"),
  systemInfo: document.getElementById("systemInfo"),
  clickThroughIdle: document.getElementById("clickThroughIdle"),
  followMouse: document.getElementById("followMouse"),
  startup: document.getElementById("startup"),
  moveRandomWalking: document.getElementById("moveRandomWalking"),
  moveEdgeWalking: document.getElementById("moveEdgeWalking"),
  moveWindowEdgeWalking: document.getElementById("moveWindowEdgeWalking"),
  moveWallClimbing: document.getElementById("moveWallClimbing"),
  moveCeilingWalking: document.getElementById("moveCeilingWalking"),
  moveHanging: document.getElementById("moveHanging"),
  moveJumpBetweenWindows: document.getElementById("moveJumpBetweenWindows"),
  moveSlipAndFall: document.getElementById("moveSlipAndFall"),
  moveSitOnWindow: document.getElementById("moveSitOnWindow"),
  moveFollowMouse: document.getElementById("moveFollowMouse"),
  moveAvoidMouse: document.getElementById("moveAvoidMouse"),
  movePhysicsMode: document.getElementById("movePhysicsMode"),
  moveGravity: document.getElementById("moveGravity"),
  moveBounceLanding: document.getElementById("moveBounceLanding"),
  moveIdleExploration: document.getElementById("moveIdleExploration"),
  moveSpeed: document.getElementById("moveSpeed"),
  moveSpeedValue: document.getElementById("moveSpeedValue"),
  moveFrequency: document.getElementById("moveFrequency"),
  moveFrequencyValue: document.getElementById("moveFrequencyValue"),
  moveJump: document.getElementById("moveJump"),
  moveJumpValue: document.getElementById("moveJumpValue"),
  moveGravityStrength: document.getElementById("moveGravityStrength"),
  moveGravityValue: document.getElementById("moveGravityValue"),
  moveFallChance: document.getElementById("moveFallChance"),
  moveFallValue: document.getElementById("moveFallValue"),
  memoryText: document.getElementById("memoryText"),
  aiResult: document.getElementById("aiResult"),
  systemStatus: document.getElementById("systemStatus"),
  reminderStatus: document.getElementById("reminderStatus"),
  pomodoro: document.getElementById("pomodoro"),
  reminderText: document.getElementById("reminderText"),
  userName: document.getElementById("userName"),
  birthday: document.getElementById("birthday"),
  randomMoments: document.getElementById("randomMoments"),
  surpriseGifts: document.getElementById("surpriseGifts"),
  voice: document.getElementById("voice"),
  productivity: document.getElementById("productivity"),
  nightSleep: document.getElementById("nightSleep"),
  memeLines: document.getElementById("memeLines"),
  festivals: document.getElementById("festivals"),
  demoMode: document.getElementById("demoMode"),
  featureStatus: document.getElementById("featureStatus"),
  worldEnabled: document.getElementById("worldEnabled"),
  toysEnabled: document.getElementById("toysEnabled"),
  weatherEnabled: document.getElementById("weatherEnabled"),
  worldFrequency: document.getElementById("worldFrequency"),
  worldFrequencyValue: document.getElementById("worldFrequencyValue"),
  weatherMode: document.getElementById("weatherMode"),
  petInteractions: document.getElementById("petInteractions"),
  familySystem: document.getElementById("familySystem"),
  evolution: document.getElementById("evolution"),
  homeBuilder: document.getElementById("homeBuilder"),
  adventures: document.getElementById("adventures"),
  storyEngine: document.getElementById("storyEngine"),
  moodWheel: document.getElementById("moodWheel"),
  cinematicEvents: document.getElementById("cinematicEvents"),
  seasonalUpdates: document.getElementById("seasonalUpdates"),
  pluginMarketplace: document.getElementById("pluginMarketplace"),
  nextFrequency: document.getElementById("nextFrequency"),
  nextFrequencyValue: document.getElementById("nextFrequencyValue"),
  friendshipStatus: document.getElementById("friendshipStatus"),
  needsStatus: document.getElementById("needsStatus"),
  inventoryStatus: document.getElementById("inventoryStatus"),
  evolutionStatus: document.getElementById("evolutionStatus"),
  storyStatus: document.getElementById("storyStatus"),
  achievements: document.getElementById("achievements"),
  chatLog: document.getElementById("chatLog"),
  chatInput: document.getElementById("chatInput"),
  aiMemory: document.getElementById("aiMemory"),
  habitLearning: document.getElementById("habitLearning"),
  routineLearning: document.getElementById("routineLearning"),
  conversationMemory: document.getElementById("conversationMemory"),
  contextAwareness: document.getElementById("contextAwareness"),
  moodEngine: document.getElementById("moodEngine"),
  emotionEngine: document.getElementById("emotionEngine"),
  offlineAi: document.getElementById("offlineAi"),
  smartReminders: document.getElementById("smartReminders"),
  taskSuggestions: document.getElementById("taskSuggestions")
};

let state;
let reminderTimer;

async function boot() {
  state = await window.maxie.state.get();
  fields.name.value = state.personality.name;
  fields.style.value = state.personality.style;
  fields.size.value = state.pet.size;
  fields.speed.value = state.pet.speed;
  syncRangeLabels();
  fields.theme.value = state.theme;
  fields.avatarPreview.src = state.appearance?.avatar || "";
  fields.provider.value = state.ai.provider;
  fields.endpoint.value = state.ai.endpoint;
  fields.model.value = state.ai.model;
  fields.apiKey.value = state.ai.apiKey;
  fields.activeApp.checked = state.permissions.activeApp;
  fields.notifications.checked = state.permissions.notifications;
  fields.systemInfo.checked = state.permissions.systemInfo;
  fields.clickThroughIdle.checked = state.pet.clickThroughIdle;
  fields.followMouse.checked = state.pet.followMouse;
  hydrateMovementFields();
  fields.startup.checked = await window.maxie.system.getStartup();
  fields.userName.value = state.profile?.userName || "";
  fields.birthday.value = state.profile?.birthday || "";
  fields.randomMoments.checked = Boolean(state.features?.randomMoments);
  fields.surpriseGifts.checked = Boolean(state.features?.surpriseGifts);
  fields.voice.checked = Boolean(state.features?.voice);
  fields.productivity.checked = Boolean(state.features?.productivity);
  fields.nightSleep.checked = Boolean(state.features?.nightSleep);
  fields.memeLines.checked = Boolean(state.features?.memeLines);
  fields.festivals.checked = Boolean(state.features?.festivals);
  fields.demoMode.checked = Boolean(state.features?.demoMode);
  fields.memoryText.value = (state.memory || []).map((item) => item.text).join("\n");
  fields.chatLog.value = "";
  hydrateIntelligenceFields();
  hydrateWorldFields();
  hydrateNextLevelFields();
  refreshSystem();
  refreshFriendship();
}

async function save() {
  state = {
    ...state,
    theme: fields.theme.value,
    pet: {
      ...state.pet,
      size: Number(fields.size.value),
      speed: Number(fields.speed.value),
      clickThroughIdle: fields.clickThroughIdle.checked,
      followMouse: fields.followMouse.checked
    },
    movement: readMovementFields(),
    personality: {
      ...state.personality,
      name: fields.name.value.trim() || "MAXie",
      style: fields.style.value
    },
    ai: {
      provider: fields.provider.value,
      endpoint: fields.endpoint.value.trim(),
      model: fields.model.value.trim(),
      apiKey: fields.apiKey.value
    },
    permissions: {
      activeApp: fields.activeApp.checked,
      notifications: fields.notifications.checked,
      systemInfo: fields.systemInfo.checked
    },
    features: {
      ...(state.features || {}),
      randomMoments: fields.randomMoments.checked,
      surpriseGifts: fields.surpriseGifts.checked,
      voice: fields.voice.checked,
      productivity: fields.productivity.checked,
      nightSleep: fields.nightSleep.checked,
      memeLines: fields.memeLines.checked,
      festivals: fields.festivals.checked,
      demoMode: fields.demoMode.checked
    },
    profile: {
      ...(state.profile || {}),
      userName: fields.userName.value.trim(),
      birthday: fields.birthday.value
    },
    world: readWorldFields(),
    nextLevel: readNextLevelFields(),
    intelligence: readIntelligenceFields()
  };
  await window.maxie.state.set(state);
  refreshFriendship();
}

document.querySelectorAll("input, select, textarea").forEach((input) => {
  if (input.id === "memoryText" || input.id === "importMemory") return;
  input.addEventListener("change", save);
});

fields.size.addEventListener("input", () => {
  syncRangeLabels();
  save();
});

fields.speed.addEventListener("input", () => {
  syncRangeLabels();
  save();
});

[
  fields.moveSpeed,
  fields.moveFrequency,
  fields.moveJump,
  fields.moveGravityStrength,
  fields.moveFallChance
].forEach((slider) => {
  slider.addEventListener("input", () => {
    syncMovementLabels();
    save();
  });
});

fields.worldFrequency.addEventListener("input", () => {
  syncWorldLabels();
  save();
});

fields.nextFrequency.addEventListener("input", () => {
  syncNextLevelLabels();
  save();
});

function syncRangeLabels() {
  fields.sizeValue.textContent = `${fields.size.value}px`;
  fields.speedValue.textContent = `${fields.speed.value}x`;
  syncMovementLabels();
}

function hydrateMovementFields() {
  const movement = {
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
    speed: state.pet?.speed || 1,
    explorationFrequency: 0.45,
    jumpHeight: 0.55,
    gravityStrength: 0.35,
    fallChance: 0.08,
    ...(state.movement || {})
  };
  fields.moveRandomWalking.checked = movement.randomWalking;
  fields.moveEdgeWalking.checked = movement.edgeWalking;
  fields.moveWindowEdgeWalking.checked = movement.windowEdgeWalking;
  fields.moveWallClimbing.checked = movement.wallClimbing;
  fields.moveCeilingWalking.checked = movement.ceilingWalking;
  fields.moveHanging.checked = movement.hanging;
  fields.moveJumpBetweenWindows.checked = movement.jumpBetweenWindows;
  fields.moveSlipAndFall.checked = movement.slipAndFall;
  fields.moveSitOnWindow.checked = movement.sitOnWindow;
  fields.moveFollowMouse.checked = movement.followMouse;
  fields.moveAvoidMouse.checked = movement.avoidMouse;
  fields.movePhysicsMode.checked = movement.physicsMode;
  fields.moveGravity.checked = movement.gravity;
  fields.moveBounceLanding.checked = movement.bounceLanding;
  fields.moveIdleExploration.checked = movement.idleExploration;
  fields.moveSpeed.value = movement.speed;
  fields.moveFrequency.value = movement.explorationFrequency;
  fields.moveJump.value = movement.jumpHeight;
  fields.moveGravityStrength.value = movement.gravityStrength;
  fields.moveFallChance.value = movement.fallChance;
  syncMovementLabels();
}

function readMovementFields() {
  return {
    randomWalking: fields.moveRandomWalking.checked,
    edgeWalking: fields.moveEdgeWalking.checked,
    windowEdgeWalking: fields.moveWindowEdgeWalking.checked,
    wallClimbing: fields.moveWallClimbing.checked,
    ceilingWalking: fields.moveCeilingWalking.checked,
    hanging: fields.moveHanging.checked,
    jumpBetweenWindows: fields.moveJumpBetweenWindows.checked,
    slipAndFall: fields.moveSlipAndFall.checked,
    sitOnWindow: fields.moveSitOnWindow.checked,
    followMouse: fields.moveFollowMouse.checked,
    avoidMouse: fields.moveAvoidMouse.checked,
    physicsMode: fields.movePhysicsMode.checked,
    gravity: fields.moveGravity.checked,
    bounceLanding: fields.moveBounceLanding.checked,
    idleExploration: fields.moveIdleExploration.checked,
    speed: Number(fields.moveSpeed.value),
    explorationFrequency: Number(fields.moveFrequency.value),
    jumpHeight: Number(fields.moveJump.value),
    gravityStrength: Number(fields.moveGravityStrength.value),
    fallChance: Number(fields.moveFallChance.value)
  };
}

function syncMovementLabels() {
  fields.moveSpeedValue.textContent = `${fields.moveSpeed.value}x`;
  fields.moveFrequencyValue.textContent = `${Math.round(Number(fields.moveFrequency.value) * 100)}%`;
  fields.moveJumpValue.textContent = `${Math.round(Number(fields.moveJump.value) * 100)}%`;
  fields.moveGravityValue.textContent = `${fields.moveGravityStrength.value}x`;
  fields.moveFallValue.textContent = `${Math.round(Number(fields.moveFallChance.value) * 100)}%`;
}

function hydrateIntelligenceFields() {
  const intelligence = {
    aiMemory: true,
    habitLearning: true,
    routineLearning: true,
    conversationMemory: true,
    contextAwareness: true,
    moodEngine: true,
    emotionEngine: true,
    offlineAi: true,
    smartReminders: true,
    taskSuggestions: true,
    ...(state.intelligence || {})
  };
  fields.aiMemory.checked = intelligence.aiMemory;
  fields.habitLearning.checked = intelligence.habitLearning;
  fields.routineLearning.checked = intelligence.routineLearning;
  fields.conversationMemory.checked = intelligence.conversationMemory;
  fields.contextAwareness.checked = intelligence.contextAwareness;
  fields.moodEngine.checked = intelligence.moodEngine;
  fields.emotionEngine.checked = intelligence.emotionEngine;
  fields.offlineAi.checked = intelligence.offlineAi;
  fields.smartReminders.checked = intelligence.smartReminders;
  fields.taskSuggestions.checked = intelligence.taskSuggestions;
}

function readIntelligenceFields() {
  return {
    aiMemory: fields.aiMemory.checked,
    habitLearning: fields.habitLearning.checked,
    routineLearning: fields.routineLearning.checked,
    conversationMemory: fields.conversationMemory.checked,
    contextAwareness: fields.contextAwareness.checked,
    moodEngine: fields.moodEngine.checked,
    emotionEngine: fields.emotionEngine.checked,
    offlineAi: fields.offlineAi.checked,
    smartReminders: fields.smartReminders.checked,
    taskSuggestions: fields.taskSuggestions.checked
  };
}

function hydrateWorldFields() {
  const world = {
    enabled: true,
    toysEnabled: true,
    weatherEnabled: true,
    frequency: 0.5,
    weatherMode: "auto",
    ...(state.world || {})
  };
  fields.worldEnabled.checked = world.enabled;
  fields.toysEnabled.checked = world.toysEnabled;
  fields.weatherEnabled.checked = world.weatherEnabled;
  fields.worldFrequency.value = world.frequency;
  fields.weatherMode.value = world.weatherMode;
  syncWorldLabels();
}

function readWorldFields() {
  return {
    enabled: fields.worldEnabled.checked,
    toysEnabled: fields.toysEnabled.checked,
    weatherEnabled: fields.weatherEnabled.checked,
    frequency: Number(fields.worldFrequency.value),
    weatherMode: fields.weatherMode.value
  };
}

function syncWorldLabels() {
  fields.worldFrequencyValue.textContent = `${Math.round(Number(fields.worldFrequency.value) * 100)}%`;
}

function hydrateNextLevelFields() {
  const nextLevel = {
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
    ...(state.nextLevel || {})
  };
  fields.petInteractions.checked = nextLevel.petInteractions;
  fields.familySystem.checked = nextLevel.familySystem;
  fields.evolution.checked = nextLevel.evolution;
  fields.homeBuilder.checked = nextLevel.homeBuilder;
  fields.adventures.checked = nextLevel.adventures;
  fields.storyEngine.checked = nextLevel.storyEngine;
  fields.moodWheel.checked = nextLevel.moodWheel;
  fields.cinematicEvents.checked = nextLevel.cinematicEvents;
  fields.seasonalUpdates.checked = nextLevel.seasonalUpdates;
  fields.pluginMarketplace.checked = nextLevel.pluginMarketplace;
  fields.nextFrequency.value = nextLevel.eventFrequency;
  syncNextLevelLabels();
}

function readNextLevelFields() {
  return {
    petInteractions: fields.petInteractions.checked,
    familySystem: fields.familySystem.checked,
    evolution: fields.evolution.checked,
    homeBuilder: fields.homeBuilder.checked,
    adventures: fields.adventures.checked,
    storyEngine: fields.storyEngine.checked,
    moodWheel: fields.moodWheel.checked,
    cinematicEvents: fields.cinematicEvents.checked,
    seasonalUpdates: fields.seasonalUpdates.checked,
    pluginMarketplace: fields.pluginMarketplace.checked,
    eventFrequency: Number(fields.nextFrequency.value)
  };
}

function syncNextLevelLabels() {
  fields.nextFrequencyValue.textContent = `${Math.round(Number(fields.nextFrequency.value) * 100)}%`;
}

fields.avatarUpload.addEventListener("change", async (event) => {
  const file = event.target.files?.[0];
  if (!file) return;
  fields.avatarPreview.alt = "Processing image...";
  try {
    const avatar = await window.processPetImage(file, 512);
    const palette = window.extractPetPalette ? await window.extractPetPalette(file) : state.appearance?.palette;
    fields.avatarPreview.src = avatar;
    fields.avatarPreview.alt = "Processed pet preview";
    state.appearance = { ...(state.appearance || {}), avatar, palette };
    await window.maxie.state.set({ appearance: state.appearance });
  } catch (error) {
    fields.avatarPreview.alt = "Image processing failed";
    fields.featureStatus.textContent = `Image processing failed: ${error.message}`;
  }
});

fields.deleteAvatar.addEventListener("click", async () => {
  fields.avatarUpload.value = "";
  fields.avatarPreview.removeAttribute("src");
  fields.avatarPreview.alt = "Default MAXie restored";
  state.appearance = { ...(state.appearance || {}), avatar: "", palette: null };
  await window.maxie.state.set({ appearance: state.appearance });
});

document.getElementById("saveMemory").addEventListener("click", async () => {
  const memory = fields.memoryText.value
    .split("\n")
    .map((text) => text.trim())
    .filter(Boolean)
    .map((text, index) => ({ id: `${Date.now()}-${index}`, text }));
  await window.maxie.state.set({ memory });
});

document.getElementById("exportMemory").addEventListener("click", () => {
  const blob = new Blob([JSON.stringify(state.memory || [], null, 2)], { type: "application/json" });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = "maxie-memory.json";
  link.click();
  URL.revokeObjectURL(link.href);
});

document.getElementById("importMemory").addEventListener("change", async (event) => {
  const file = event.target.files?.[0];
  if (!file) return;
  const memory = JSON.parse(await file.text());
  await window.maxie.state.set({ memory });
  fields.memoryText.value = memory.map((item) => item.text).join("\n");
});

document.getElementById("testAi").addEventListener("click", async () => {
  fields.aiResult.textContent = "Testing...";
  await save();
  try {
    const reply = await window.maxie.ai.chat([{ role: "user", content: "Say hello as MAXie in one short sentence." }]);
    fields.aiResult.textContent = reply;
  } catch (error) {
    fields.aiResult.textContent = error.message;
  }
});

document.getElementById("sendChat").addEventListener("click", sendChat);
fields.chatInput.addEventListener("keydown", (event) => {
  if (event.key === "Enter") sendChat();
});

document.getElementById("startReminder").addEventListener("click", () => {
  clearTimeout(reminderTimer);
  const minutes = Number(fields.pomodoro.value || 25);
  const text = fields.reminderText.value.trim() || "Time for a break.";
  fields.reminderStatus.textContent = `Reminder set for ${minutes} minutes.`;
  reminderTimer = setTimeout(() => {
    window.maxie.notify({ title: "MAXie reminder", body: text });
    fields.reminderStatus.textContent = "Reminder fired.";
  }, minutes * 60000);
});

document.getElementById("refreshSystem").addEventListener("click", refreshSystem);
document.getElementById("openFolder").addEventListener("click", () => window.maxie.project.openFolder());
document.getElementById("showPet").addEventListener("click", () => window.maxie.pet.show());
document.getElementById("hidePet").addEventListener("click", () => window.maxie.pet.hide());
document.getElementById("photoPet").addEventListener("click", async () => {
  const filePath = await window.maxie.pet.photo();
  fields.featureStatus.textContent = filePath ? `Photo saved: ${filePath}` : "Photo mode needs MAXie visible.";
});
document.getElementById("giftTest").addEventListener("click", () => {
  window.maxie.pet.command({ type: "gift" });
  fields.featureStatus.textContent = "Gift test sent to MAXie.";
});
document.getElementById("gameTest").addEventListener("click", async () => {
  await window.maxie.pet.command({ type: "game" });
  playMiniGame();
});
fields.startup.addEventListener("change", async () => {
  fields.startup.checked = await window.maxie.system.setStartup(fields.startup.checked);
});

async function refreshSystem() {
  const snapshot = await window.maxie.system.getSnapshot();
  fields.systemStatus.innerHTML = "";
  const rows = {
    Online: snapshot.online ? "Yes" : "No",
    "CPU usage": `${snapshot.cpuUsage}%`,
    "Free memory": `${Math.round(snapshot.memory.free / 1024 / 1024)} MB`,
    Battery: snapshot.battery.supported ? `${snapshot.battery.percent}%` : "Unavailable",
    Platform: snapshot.platform
  };
  for (const [key, value] of Object.entries(rows)) {
    const dt = document.createElement("dt");
    const dd = document.createElement("dd");
    dt.textContent = key;
    dd.textContent = value;
    fields.systemStatus.append(dt, dd);
  }
}

async function refreshFriendship() {
  state = await window.maxie.state.get();
  fields.friendshipStatus.innerHTML = "";
  const rows = {
    Friendship: `${state.personality?.friendship || 0}/100`,
    XP: state.personality?.xp || 0,
    Growth: state.personality?.growth || "Baby",
    Gifts: state.gifts?.length || 0,
    "Active minutes": state.stats?.activeMinutes || 0,
    "Coding minutes": state.stats?.codeMinutes || 0
  };
  for (const [key, value] of Object.entries(rows)) {
    const dt = document.createElement("dt");
    const dd = document.createElement("dd");
    dt.textContent = key;
    dd.textContent = value;
    fields.friendshipStatus.append(dt, dd);
  }

  fields.needsStatus.innerHTML = "";
  const needs = state.needs || {};
  const needRows = {
    Happiness: `${Math.round(needs.happiness ?? 0)}/100`,
    Hunger: `${Math.round(needs.hunger ?? 0)}/100`,
    Thirst: `${Math.round(needs.thirst ?? 0)}/100`,
    Sleep: `${Math.round(needs.sleep ?? 0)}/100`,
    Fun: `${Math.round(needs.fun ?? 0)}/100`,
    Friendship: `${Math.round(needs.friendship ?? state.personality?.friendship ?? 0)}/100`,
    Curiosity: `${Math.round(needs.curiosity ?? 0)}/100`
  };
  for (const [key, value] of Object.entries(needRows)) {
    const dt = document.createElement("dt");
    const dd = document.createElement("dd");
    dt.textContent = key;
    dd.textContent = value;
    fields.needsStatus.append(dt, dd);
  }

  fields.inventoryStatus.innerHTML = "";
  const inventory = state.inventory || {};
  const inventoryRows = {
    Coins: inventory.coins || 0,
    XP: inventory.xp || 0,
    Food: inventory.food?.length || 0,
    Toys: inventory.toys?.length || 0,
    Equipped: inventory.equipped?.toy || "None"
  };
  for (const [key, value] of Object.entries(inventoryRows)) {
    const dt = document.createElement("dt");
    const dd = document.createElement("dd");
    dt.textContent = key;
    dd.textContent = value;
    fields.inventoryStatus.append(dt, dd);
  }

  fields.evolutionStatus.innerHTML = "";
  const evolution = state.evolution || {};
  const family = state.family || {};
  const evolutionRows = {
    Level: evolution.level || 1,
    Form: evolution.form || state.personality?.growth || "Baby",
    Role: family.role || "Baby MAXie",
    "Unlocked animations": evolution.unlocked?.length || 0,
    Home: state.home?.equipped?.join(", ") || "Bed, bookshelf"
  };
  for (const [key, value] of Object.entries(evolutionRows)) {
    const dt = document.createElement("dt");
    const dd = document.createElement("dd");
    dt.textContent = key;
    dd.textContent = value;
    fields.evolutionStatus.append(dt, dd);
  }

  const latestStory = state.stories?.[state.stories.length - 1];
  fields.storyStatus.textContent = latestStory?.text || "MAXie has not written today's tiny story yet.";

  fields.achievements.innerHTML = "";
  const achievements = state.achievements?.length ? state.achievements : [{ title: "Start using MAXie" }];
  for (const achievement of achievements) {
    const chip = document.createElement("span");
    chip.textContent = achievement.title;
    fields.achievements.append(chip);
  }
}

async function playMiniGame() {
  const choices = ["rock", "paper", "scissors"];
  const maxie = choices[Math.floor(Math.random() * choices.length)];
  const you = choices[Math.floor(Math.random() * choices.length)];
  const result = you === maxie ? "Tie" : (
    (you === "rock" && maxie === "scissors") ||
    (you === "paper" && maxie === "rock") ||
    (you === "scissors" && maxie === "paper") ? "You win" : "MAXie wins"
  );
  fields.featureStatus.textContent = `Mini game: you ${you}, MAXie ${maxie}. ${result}.`;
  const stats = { ...(state.stats || {}), gamesPlayed: Number(state.stats?.gamesPlayed || 0) + 1 };
  await window.maxie.state.set({ stats });
  refreshFriendship();
}

async function sendChat() {
  const message = fields.chatInput.value.trim();
  if (!message) return;
  fields.chatInput.value = "";
  appendChat("You", message);
  try {
    await save();
    const recentMemory = (state.memory || []).slice(-8).map((item) => item.text).join("\n");
    const reply = await window.maxie.ai.chat([
      { role: "user", content: `${recentMemory ? `Recent memory:\n${recentMemory}\n\n` : ""}${message}` }
    ]);
    appendChat("MAXie", reply);
    if (state.intelligence?.conversationMemory !== false && state.intelligence?.aiMemory !== false) {
      const memory = [
        ...(state.memory || []),
        { id: `${Date.now()}-user`, text: `User said: ${message}` },
        { id: `${Date.now()}-maxie`, text: `MAXie replied: ${reply}` }
      ].slice(-40);
      state = await window.maxie.state.set({ memory });
      fields.memoryText.value = memory.map((item) => item.text).join("\n");
    }
  } catch (error) {
    appendChat("MAXie", error.message);
  }
}

function appendChat(name, text) {
  fields.chatLog.value = `${fields.chatLog.value}${name}: ${text}\n`;
  fields.chatLog.scrollTop = fields.chatLog.scrollHeight;
}

boot();
