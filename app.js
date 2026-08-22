const storeKey = "maxie-mobile-suite-v1";

const defaults = {
  name: "MAXie",
  personality: "Cute",
  context: "Desktop",
  mood: "Happy",
  face: "glow",
  theme: "aurora",
  xp: 750,
  friendship: 5,
  needs: {
    energy: 82,
    food: 74,
    fun: 68
  },
  tasks: [],
  habits: {},
  chat: [
    { role: "bot", text: "Hi, I am MAXie. I can help with tasks, habits, focus, and cute app reactions." }
  ],
  pairedPc: "",
  avatar: "",
  memory: [],
  shimeji: {
    enabled: false,
    inAppEnabled: true,
    petSize: 100,
    petSpeed: 1.0,
    petOpacity: 1.0,
    soundEnabled: true,
    soundVolume: 50,
    batterySaver: false,
    activeCompanions: ["maxie"],
    relationships: {
      maxie: { level: 1, xp: 0, affection: 10, trust: 10, lastInteraction: Date.now(), milestones: [] },
      mimi: { level: 1, xp: 0, affection: 10, trust: 10, lastInteraction: Date.now(), milestones: [] },
      kuro: { level: 1, xp: 0, affection: 10, trust: 10, lastInteraction: Date.now(), milestones: [] },
      luna: { level: 1, xp: 0, affection: 10, trust: 10, lastInteraction: Date.now(), milestones: [] },
      nova: { level: 1, xp: 0, affection: 10, trust: 10, lastInteraction: Date.now(), milestones: [] }
    },
    moods: {
      maxie: { mood: "happy", intensity: 1.0, cause: "SYSTEM", timestamp: Date.now(), duration: 60000 },
      mimi: { mood: "happy", intensity: 1.0, cause: "SYSTEM", timestamp: Date.now(), duration: 60000 },
      kuro: { mood: "calm", intensity: 1.0, cause: "SYSTEM", timestamp: Date.now(), duration: 60000 },
      luna: { mood: "sleepy", intensity: 1.0, cause: "SYSTEM", timestamp: Date.now(), duration: 60000 },
      nova: { mood: "curious", intensity: 1.0, cause: "SYSTEM", timestamp: Date.now(), duration: 60000 }
    },
    voice: {
      speechEnabled: false,
      ttsEnabled: false
    }
  }
};

const lines = {
  Cute: ["Tiny win saved.", "I am here. One small step first."],
  Funny: ["Productivity detected. Suspicious but welcome.", "That task blinked first. We win."],
  Chill: ["No rush. Soft focus is still focus.", "I will keep the desk calm."],
  Motivational: ["You showed up. Now let us move.", "One clean sprint and future-you smiles."],
  Gamer: ["Quest accepted. XP is waiting.", "Objective marked. Clear it cleanly."],
  Nerd: ["Data says you are doing better than you think.", "Debug the day, one variable at a time."],
  Professional: ["Priorities are ready.", "Let us turn this into a clean checklist."]
};

const contextLines = {
  Desktop: "Desktop mode. I am floating nearby.",
  WhatsApp: "Nice chat. Reply kindly and keep your streak bright.",
  Music: "Nice song. I can vibe while you focus.",
  Chrome: "Search hard. Save useful links before they disappear.",
  "VS Code": "Coding mode. Paste the bug and I will help you think.",
  "Study session": "Study mode. Twenty minutes is enough to start.",
  Gaming: "Game mode. Win the match, then drink water."
};

let state = loadState();

const els = {
  shell: document.querySelector(".phone-shell"),
  views: [...document.querySelectorAll(".view")],
  navButtons: [...document.querySelectorAll("[data-nav]")],
  jumpButtons: [...document.querySelectorAll("[data-jump]")],
  notifyButton: document.getElementById("notifyButton"),
  connectionStatus: document.getElementById("connectionStatus"),
  companion: document.getElementById("companion"),
  speechBubble: document.getElementById("speechBubble"),
  petAvatar: document.getElementById("petAvatar"),
  petName: document.getElementById("petName"),
  moodBadge: document.getElementById("moodBadge"),
  friendshipLabel: document.getElementById("friendshipLabel"),
  xpProgress: document.getElementById("xpProgress"),
  xpLabel: document.getElementById("xpLabel"),
  nextLevelLabel: document.getElementById("nextLevelLabel"),
  talkButton: document.getElementById("talkButton"),
  feedButton: document.getElementById("feedButton"),
  playButton: document.getElementById("playButton"),
  chatLog: document.getElementById("chatLog"),
  chatForm: document.getElementById("chatForm"),
  chatInput: document.getElementById("chatInput"),
  contextSelect: document.getElementById("contextSelect"),
  taskForm: document.getElementById("taskForm"),
  memoryInput: document.getElementById("memoryInput"),
  memoryList: document.getElementById("memoryList"),
  taskCount: document.getElementById("taskCount"),
  streakLabel: document.getElementById("streakLabel"),
  energyMeter: document.getElementById("energyMeter"),
  foodMeter: document.getElementById("foodMeter"),
  funMeter: document.getElementById("funMeter"),
  pairForm: document.getElementById("pairForm"),
  pairInput: document.getElementById("pairInput"),
  pairBadge: document.getElementById("pairBadge"),
  fileInput: document.getElementById("fileInput"),
  fileStatus: document.getElementById("fileStatus"),
  copyClipboardButton: document.getElementById("copyClipboardButton"),
  clipboardStatus: document.getElementById("clipboardStatus"),
  exportButton: document.getElementById("exportButton"),
  importInput: document.getElementById("importInput"),
  nameInput: document.getElementById("nameInput"),
  personalitySelect: document.getElementById("personalitySelect"),
  avatarInput: document.getElementById("avatarInput"),
  resetButton: document.getElementById("resetButton")
};

function loadState() {
  try {
    return mergeState(defaults, JSON.parse(localStorage.getItem(storeKey) || "{}"));
  } catch {
    return structuredClone(defaults);
  }
}

function mergeState(base, saved) {
  const merged = {
    ...structuredClone(base),
    ...saved,
    needs: { ...base.needs, ...(saved.needs || {}) },
    shimeji: { ...base.shimeji, ...(saved.shimeji || {}) },
    tasks: Array.isArray(saved.tasks) ? saved.tasks : base.tasks,
    habits: saved.habits || base.habits,
    chat: Array.isArray(saved.chat) ? saved.chat : base.chat
  };

  if (!Array.isArray(merged.memory)) merged.memory = [];
  if (window.CompanionState && typeof window.CompanionState.validateAndSanitize === "function") {
    merged.shimeji = window.CompanionState.validateAndSanitize(merged.shimeji);
  }
  return merged;
}

function saveState() {
  localStorage.setItem(storeKey, JSON.stringify(state));
}

function clamp(value) {
  return Math.max(0, Math.min(100, value));
}

function makeId() {
  if (crypto?.randomUUID) return crypto.randomUUID();
  return `${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

function todayKey() {
  return new Date().toISOString().slice(0, 10);
}

function addXp(amount) {
  state.xp = Math.max(0, state.xp + amount);
  state.friendship = Math.max(1, Math.floor(state.xp / 150) + 1);
  if (state.needs.energy < 25) state.mood = "Sleepy";
  else if (state.needs.fun > 84) state.mood = "Excited";
  else if (state.xp >= 1000) state.mood = "Proud";
  else state.mood = "Happy";
}

function speak(text) {
  els.speechBubble.textContent = text;
}

function replyFor(text) {
  const lower = text.toLowerCase();
  if (lower.includes("task") || lower.includes("remind")) return "Add it in Tasks and I will keep it on your dashboard.";
  if (lower.includes("habit")) return "Pick one habit for today. Small streaks become big confidence.";
  if (lower.includes("chrome") || lower.includes("search")) return contextLines.Chrome;
  if (lower.includes("music") || lower.includes("song")) return contextLines.Music;
  if (lower.includes("whatsapp") || lower.includes("chat")) return contextLines.WhatsApp;
  if (lower.includes("sync") || lower.includes("pc")) return "Pair your PC on the same network, then use the transfer tiles.";
  const pool = lines[state.personality] || lines.Cute;
  return pool[Math.floor(Math.random() * pool.length)];
}

function switchView(view) {
  els.views.forEach((section) => section.classList.toggle("is-active", section.dataset.view === view));
  els.navButtons.forEach((button) => button.classList.toggle("is-active", button.dataset.nav === view));
}

function renderChat() {
  els.chatLog.innerHTML = "";
  state.chat.slice(-20).forEach((message) => {
    const item = document.createElement("div");
    item.className = `chat-message is-${message.role === "user" ? "user" : "bot"}`;
    item.textContent = message.text;
    els.chatLog.appendChild(item);
  });
  els.chatLog.scrollTop = els.chatLog.scrollHeight;
}

function renderTasks() {
  els.memoryList.innerHTML = "";
  const activeTasks = state.tasks.filter((task) => !task.done);
  els.taskCount.textContent = `${activeTasks.length} active`;

  state.tasks.forEach((task) => {
    const item = document.createElement("li");
    const check = document.createElement("input");
    const text = document.createElement("span");
    const remove = document.createElement("button");
    check.type = "checkbox";
    check.checked = task.done;
    text.textContent = task.text;
    remove.type = "button";
    remove.textContent = "Delete";
    check.addEventListener("change", () => {
      task.done = check.checked;
      addXp(check.checked ? 25 : -10);
      saveState();
      render();
      speak(check.checked ? "Task complete. XP added." : "Task reopened.");
    });
    remove.addEventListener("click", () => {
      state.tasks = state.tasks.filter((entry) => entry.id !== task.id);
      saveState();
      render();
    });
    item.append(check, text, remove);
    els.memoryList.appendChild(item);
  });
}

function renderHabits() {
  const today = todayKey();
  const todayHabits = state.habits[today] || {};
  document.querySelectorAll("[data-habit]").forEach((input) => {
    input.checked = Boolean(todayHabits[input.dataset.habit]);
  });
  const count = Object.values(todayHabits).filter(Boolean).length;
  els.streakLabel.textContent = `${count} / 3 today`;
}

function render() {
  els.shell.dataset.theme = state.theme;
  els.nameInput.value = state.name;
  els.personalitySelect.value = state.personality;
  els.contextSelect.value = state.context;
  els.petName.textContent = state.name;
  els.moodBadge.textContent = state.mood;
  els.friendshipLabel.textContent = `Lv. ${state.friendship} Friendship`;
  els.xpProgress.value = state.xp % 1000;
  els.xpLabel.textContent = `${state.xp % 1000} / 1000 XP`;
  els.nextLevelLabel.textContent = `Next lv. in ${1000 - (state.xp % 1000)}`;
  els.energyMeter.value = state.needs.energy;
  els.foodMeter.value = state.needs.food;
  els.funMeter.value = state.needs.fun;
  els.connectionStatus.textContent = state.pairedPc ? `Paired with ${state.pairedPc}` : "Local-first companion";
  els.pairBadge.textContent = state.pairedPc ? "Paired" : "Ready";
  els.companion.className = `companion face-${state.face}`;
  els.petAvatar.style.backgroundImage = state.avatar ? `url("${state.avatar}")` : "";
  renderChat();
  renderTasks();
  renderHabits();
  if (typeof renderShimeji === "function") {
    renderShimeji();
  }
}

els.navButtons.forEach((button) => button.addEventListener("click", () => switchView(button.dataset.nav)));
els.jumpButtons.forEach((button) => button.addEventListener("click", () => switchView(button.dataset.jump)));

els.companion.addEventListener("click", () => {
  state.needs.fun = clamp(state.needs.fun + 4);
  addXp(10);
  speak(contextLines[state.context] || replyFor(""));
  saveState();
  render();
});

els.talkButton.addEventListener("click", () => {
  addXp(12);
  speak(replyFor(""));
  saveState();
  render();
});

els.feedButton.addEventListener("click", () => {
  state.needs.food = clamp(state.needs.food + 12);
  state.needs.energy = clamp(state.needs.energy + 4);
  addXp(10);
  speak("Snack accepted. Friendship boosted.");
  saveState();
  render();
});

els.playButton.addEventListener("click", () => {
  state.needs.fun = clamp(state.needs.fun + 15);
  state.needs.energy = clamp(state.needs.energy - 5);
  addXp(15);
  speak("Play break complete. Back with sparkle.");
  saveState();
  render();
});

els.chatForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  const text = els.chatInput.value.trim();
  if (!text) return;
  els.chatInput.value = "";

  const companionId = String(state.personality || "maxie").toLowerCase();

  // 1. Instantly append user message
  state.chat.push({ role: "user", text, companionId, timestamp: Date.now() });
  addXp(8);
  saveState();
  render();

  // 2. Render typing indicator
  const typingMsg = { role: "bot", text: "...", companionId, typing: true };
  state.chat.push(typingMsg);
  render();

  try {
    // 3. Generate response asynchronously
    let answer = "";
    if (window.companionEngine && typeof window.companionEngine.generateResponse === "function") {
      answer = await window.companionEngine.generateResponse(text, companionId);
    } else {
      answer = window.OfflineAi ? window.OfflineAi.generate(text, companionId) : "Hello! (Offline)";
    }

    state.chat = state.chat.filter(m => !m.typing);
    state.chat.push({ role: "bot", text: answer, companionId, timestamp: Date.now() });
  } catch (e) {
    console.error("[app.js] Chat generation failed:", e);
    state.chat = state.chat.filter(m => !m.typing);
    const fallbackAnswer = window.OfflineAi ? window.OfflineAi.generate(text, companionId) : "I'm keeping focused here!";
    state.chat.push({ role: "bot", text: fallbackAnswer, companionId, timestamp: Date.now() });
  }

  saveState();
  render();
});

els.contextSelect.addEventListener("change", () => {
  state.context = els.contextSelect.value;
  saveState();
  
  const companionId = String(state.personality || "maxie").toLowerCase();
  const ctx = state.context.toLowerCase();

  if (ctx.includes("vs code") || ctx.includes("coding")) {
    if (window.companionEngine) window.companionEngine.handleEvent("CODING_DETECTED", { companionId });
  } else if (ctx.includes("music")) {
    if (window.companionEngine) window.companionEngine.handleEvent("MUSIC_STARTED", { companionId });
  } else {
    const line = contextLines[state.context];
    if (window.companionEngine) window.companionEngine.handleEvent("USER_MESSAGE", { companionId, message: `Switched context to ${state.context}` });
    state.chat.push({ role: "bot", text: line, companionId, timestamp: Date.now() });
    speak(line);
    saveState();
    render();
  }
});

document.querySelectorAll("[data-context]").forEach((button) => {
  button.addEventListener("click", () => {
    state.context = button.dataset.context;
    saveState();
    
    const companionId = String(state.personality || "maxie").toLowerCase();
    const ctx = state.context.toLowerCase();

    if (ctx.includes("vs code") || ctx.includes("coding")) {
      if (window.companionEngine) window.companionEngine.handleEvent("CODING_DETECTED", { companionId });
    } else if (ctx.includes("music")) {
      if (window.companionEngine) window.companionEngine.handleEvent("MUSIC_STARTED", { companionId });
    } else {
      const line = contextLines[state.context];
      if (window.companionEngine) window.companionEngine.handleEvent("USER_MESSAGE", { companionId, message: `Switched context to ${state.context}` });
      state.chat.push({ role: "bot", text: line, companionId, timestamp: Date.now() });
      speak(line);
      saveState();
      render();
    }
  });
});

els.taskForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const text = els.memoryInput.value.trim();
  if (!text) return;
  state.tasks.unshift({ id: makeId(), text, done: false, createdAt: Date.now() });
  els.memoryInput.value = "";
  addXp(18);
  speak("Saved. I will keep it on your task board.");
  saveState();
  render();
});

document.querySelectorAll("[data-habit]").forEach((input) => {
  input.addEventListener("change", () => {
    const today = todayKey();
    state.habits[today] = state.habits[today] || {};
    state.habits[today][input.dataset.habit] = input.checked;
    addXp(input.checked ? 20 : -8);
    speak(input.checked ? "Habit checked. Streak energy up." : "Habit unchecked.");
    saveState();
    render();
  });
});

els.pairForm.addEventListener("submit", (event) => {
  event.preventDefault();
  state.pairedPc = els.pairInput.value.trim();
  els.pairInput.value = "";
  speak(state.pairedPc ? "PC saved for same-network sync." : "Pairing cleared.");
  saveState();
  render();
});

els.fileInput.addEventListener("change", () => {
  const count = els.fileInput.files.length;
  els.fileStatus.textContent = count ? `${count} file queued locally` : "Choose files to queue";
  speak(count ? "File queue ready. Real sending needs the PC helper." : "No files selected.");
});

els.copyClipboardButton.addEventListener("click", async () => {
  const text = `${state.name} clipboard sync demo`;
  try {
    await navigator.clipboard.writeText(text);
    els.clipboardStatus.textContent = "Copied demo text";
    speak("Clipboard demo copied.");
  } catch {
    els.clipboardStatus.textContent = "Clipboard needs permission";
    speak("Clipboard permission is needed on this device.");
  }
});

els.exportButton.addEventListener("click", () => {
  const blob = new Blob([JSON.stringify(state, null, 2)], { type: "application/json" });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = "maxie-backup.json";
  link.click();
  URL.revokeObjectURL(link.href);
  speak("Backup exported.");
});

els.importInput.addEventListener("change", () => {
  const file = els.importInput.files?.[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = () => {
    try {
      state = mergeState(defaults, JSON.parse(reader.result));
      speak("Backup restored.");
      saveState();
      render();
    } catch {
      speak("That backup file did not look right.");
    }
  };
  reader.readAsText(file);
});

els.nameInput.addEventListener("input", () => {
  state.name = els.nameInput.value.trim() || "MAXie";
  saveState();
  render();
});

els.personalitySelect.addEventListener("change", () => {
  state.personality = els.personalitySelect.value;
  speak(`${state.personality} personality loaded.`);
  addXp(5);
  saveState();
  render();
});

document.querySelectorAll("[data-face]").forEach((button) => {
  button.addEventListener("click", () => {
    state.face = button.dataset.face;
    speak("New face loaded.");
    addXp(5);
    saveState();
    render();
  });
});

document.querySelectorAll("[data-theme-choice]").forEach((button) => {
  button.addEventListener("click", () => {
    state.theme = button.dataset.themeChoice;
    speak("Theme updated.");
    saveState();
    render();
  });
});

els.avatarInput.addEventListener("change", (event) => {
  const file = event.target.files?.[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = () => {
    state.avatar = reader.result;
    addXp(25);
    speak("Photo added. MAXie looks personal now.");
    saveState();
    render();
  };
  reader.readAsDataURL(file);
});

els.notifyButton.addEventListener("click", async () => {
  if (!("Notification" in window)) {
    speak("Notifications are not available here.");
    return;
  }
  const permission = await Notification.requestPermission();
  if (permission === "granted") {
    new Notification("MAXie is ready", { body: "Tasks, habits, and sync bubbles are on." });
    speak("Notifications enabled.");
  } else {
    speak("Notification permission was not enabled.");
  }
});

// ═══════════════ SHIMEJI ENGINE INTEGRATION ═══════════════

const Shimeji = window.Capacitor?.Plugins?.Shimeji || {
  checkOverlayPermission: () => Promise.resolve({ hasPermission: false }),
  requestOverlayPermission: () => Promise.resolve({ hasPermission: false }),
  startOverlay: () => Promise.resolve(),
  stopOverlay: () => Promise.resolve(),
  isOverlayRunning: () => Promise.resolve({ running: false }),
  updatePetSettings: () => Promise.resolve()
};

async function toggleOverlayMode(enable) {
  if (enable) {
    const res = await Shimeji.checkOverlayPermission();
    if (res.hasPermission) {
      state.shimeji.enabled = true;
      await Shimeji.startOverlay({ state: JSON.stringify(state.shimeji) });
    } else {
      alert("Floating pet overlay requires 'Draw over other apps' permission. We will open settings to enable it.");
      const reqRes = await Shimeji.requestOverlayPermission();
      if (reqRes.hasPermission) {
        state.shimeji.enabled = true;
        await Shimeji.startOverlay({ state: JSON.stringify(state.shimeji) });
      } else {
        alert("Permission denied. Falling back to In-App pet simulation.");
        state.shimeji.enabled = false;
      }
    }
  } else {
    state.shimeji.enabled = false;
    await Shimeji.stopOverlay();
  }
  saveState();
  render();
}

function syncOverlayState() {
  if (state.shimeji.enabled) {
    Shimeji.updatePetSettings({ state: JSON.stringify(state.shimeji) });
  }
}

const CHARACTERS = {
  maxie: { id: "maxie", name: "MAXie", displayName: "MAXie", personality: "Friendly", theme: "aurora" },
  mimi: { id: "mimi", name: "Mimi", displayName: "Mimi", personality: "Playful", theme: "candy" },
  kuro: { id: "kuro", name: "Kuro", displayName: "Kuro", personality: "Lazy", theme: "mono" },
  luna: { id: "luna", name: "Luna", displayName: "Luna", personality: "Curious", theme: "aurora" },
  nova: { id: "nova", name: "Nova", displayName: "Nova", personality: "Energetic", theme: "candy" }
};

function renderShimeji() {
  const container = document.getElementById("companionList");
  if (!container) return;
  container.innerHTML = "";

  const completedTasks = state.tasks.filter(t => t.done).length;
  const isMimiUnlocked = state.xp >= 1000;
  const isKuroUnlocked = state.friendship >= 8;
  const isLunaUnlocked = completedTasks >= 3;
  const isNovaUnlocked = state.xp >= 1500;

  const chars = [
    { id: "maxie", name: "MAXie", desc: "Friendly & Curious", theme: "aurora", unlocked: true },
    { id: "mimi", name: "Mimi", desc: "Playful Cat Pet", theme: "candy", unlocked: isMimiUnlocked, req: "Reach 1000 XP" },
    { id: "kuro", name: "Kuro", desc: "Lazy Charcoal Cat", theme: "mono", unlocked: isKuroUnlocked, req: "Friendship Level 8" },
    { id: "luna", name: "Luna", desc: "Curious Rabbit Pet", theme: "aurora", unlocked: isLunaUnlocked, req: "Complete 3 tasks" },
    { id: "nova", name: "Nova", desc: "Energetic Star Pet", theme: "candy", unlocked: isNovaUnlocked, req: "Reach 1500 XP" }
  ];

  let activeCount = 0;

  chars.forEach(char => {
    const card = document.createElement("div");
    card.className = `shimeji-companion-card ${char.unlocked ? "" : "is-locked"}`;
    
    const isActive = state.shimeji.activeCompanions.includes(char.id);
    if (isActive && char.unlocked) {
      card.classList.add("is-active");
      activeCount++;
    }

    const emojiMap = { maxie: "🐾", mimi: "🐱", kuro: "🐈", luna: "🐰", nova: "⭐" };
    const emoji = emojiMap[char.id] || "🐾";

    card.innerHTML = `
      <div class="shimeji-card-left">
        <div class="shimeji-card-avatar">${emoji}</div>
        <div class="shimeji-card-info">
          <strong>${char.name}</strong>
          <small>${char.unlocked ? char.desc : "Locked: " + char.req}</small>
        </div>
      </div>
      <div class="shimeji-card-right">
        ${char.unlocked 
          ? `<input type="checkbox" data-char-id="${char.id}" ${isActive ? "checked" : ""}>` 
          : `<span style="font-size:12px;">🔒</span>`
        }
      </div>
    `;

    if (char.unlocked) {
      const checkbox = card.querySelector("input");
      checkbox.addEventListener("change", () => {
        if (checkbox.checked) {
          if (!state.shimeji.activeCompanions.includes(char.id)) {
            state.shimeji.activeCompanions.push(char.id);
          }
        } else {
          state.shimeji.activeCompanions = state.shimeji.activeCompanions.filter(id => id !== char.id);
          if (state.shimeji.activeCompanions.length === 0) {
            state.shimeji.activeCompanions.push("maxie");
          }
        }
        saveState();
        render();
        
        if (state.shimeji.enabled) {
          syncOverlayState();
        }
        if (state.shimeji.inAppEnabled) {
          window.initInAppShimeji();
        }
      });
    }

    container.appendChild(card);
  });

  document.getElementById("shimejiActiveCount").textContent = `${activeCount} active`;

  document.getElementById("inAppShimejiToggle").value = String(state.shimeji.inAppEnabled);
  document.getElementById("overlayShimejiToggle").value = String(state.shimeji.enabled);
  document.getElementById("shimejiSize").value = state.shimeji.petSize;
  document.getElementById("petSizeVal").textContent = `${state.shimeji.petSize}px`;
  document.getElementById("shimejiSpeed").value = Math.round(state.shimeji.petSpeed * 10);
  document.getElementById("petSpeedVal").textContent = `${state.shimeji.petSpeed.toFixed(1)}x`;
  document.getElementById("shimejiOpacity").value = Math.round(state.shimeji.petOpacity * 100);
  document.getElementById("petOpacityVal").textContent = `${Math.round(state.shimeji.petOpacity * 100)}%`;
  document.getElementById("shimejiSound").checked = state.shimeji.soundEnabled;
  document.getElementById("shimejiBatterySaver").checked = state.shimeji.batterySaver;
  document.getElementById("shimejiSoundVol").value = state.shimeji.soundVolume;
  document.getElementById("soundVolVal").textContent = `${state.shimeji.soundVolume}%`;

  document.getElementById("soundVolField").style.display = state.shimeji.soundEnabled ? "grid" : "none";

  // ═══════════════ PHASE 7 UI RENDERING ═══════════════
  const activeCompId = String(state.personality || "maxie").toLowerCase();
  const profile = window.PersonalityEngine ? window.PersonalityEngine.getProfile(activeCompId) : { name: "MAXie" };
  const rStats = (state.shimeji.relationships && state.shimeji.relationships[activeCompId]) || { level: 1, xp: 0 };
  const mStats = (state.shimeji.moods && state.shimeji.moods[activeCompId]) || { mood: "happy" };
  
  const emojiMap = { maxie: "🐾", mimi: "🐱", kuro: "🐈", luna: "🐰", nova: "⭐" };
  const compEmoji = emojiMap[activeCompId] || "🐾";

  const chatAvatar = document.getElementById("chatCompanionAvatar");
  const chatName = document.getElementById("chatCompanionName");
  const chatMood = document.getElementById("chatCompanionMood");
  const chatRel = document.getElementById("chatCompanionRelationship");
  const chatHeading = document.getElementById("chatHeading");

  if (chatAvatar) chatAvatar.textContent = compEmoji;
  if (chatName) chatName.textContent = profile.name;
  if (chatMood) chatMood.textContent = mStats.mood;
  if (chatRel) {
    const tier = window.RelationshipEngine ? window.RelationshipEngine.getTier(rStats.level) : "Stranger";
    chatRel.textContent = `${tier} (Lv ${rStats.level})`;
  }
  if (chatHeading) chatHeading.textContent = `Chatting with ${profile.name}`;

  // Update voice synthesis button state
  const voiceSynthToggle = document.getElementById("voiceSynthToggle");
  if (voiceSynthToggle) {
    const voiceSettings = state.shimeji.voice || { ttsEnabled: false };
    if (voiceSettings.ttsEnabled) {
      voiceSynthToggle.textContent = "🔊";
      voiceSynthToggle.style.color = "var(--mint)";
      voiceSynthToggle.style.borderColor = "var(--mint)";
    } else {
      voiceSynthToggle.textContent = "🔇";
      voiceSynthToggle.style.color = "var(--muted)";
      voiceSynthToggle.style.borderColor = "var(--line)";
    }
  }

  // Update memories metrics
  const dashMemories = document.getElementById("dashMemories");
  const dashGoals = document.getElementById("dashGoals");
  const dashFavorites = document.getElementById("dashFavorites");
  const dashProjects = document.getElementById("dashProjects");
  const dashRelationship = document.getElementById("dashRelationship");
  const dashImportant = document.getElementById("dashImportant");
  const memoryCountBadge = document.getElementById("memoryCountBadge");
  const memoryRecordList = document.getElementById("memoryRecordList");

  if (dashMemories) dashMemories.textContent = state.memory.length;
  if (dashGoals) {
    dashGoals.textContent = state.memory.filter(m => m.type === "goals").length;
  }
  if (dashFavorites) {
    dashFavorites.textContent = state.memory.filter(m => m.type === "favorites").length;
  }
  if (dashProjects) {
    dashProjects.textContent = state.memory.filter(m => m.type === "projects").length;
  }
  if (dashRelationship) {
    const activeRel = (state.shimeji.relationships && state.shimeji.relationships[activeCompId]) || { level: 1 };
    dashRelationship.textContent = `Lv ${activeRel.level}`;
  }
  if (dashImportant) {
    dashImportant.textContent = state.memory.filter(m => m.type === "important").length;
  }
  if (memoryCountBadge) {
    memoryCountBadge.textContent = `${state.memory.length} saved`;
  }

  if (memoryRecordList) {
    memoryRecordList.innerHTML = "";
    if (state.memory.length === 0) {
      memoryRecordList.innerHTML = `
        <li class="mem-empty-state">
          <span>No memories yet.</span>
          <small>Chat with MAXie and I'll remember the important stuff automatically!</small>
        </li>
      `;
    } else {
      state.memory.slice(-30).reverse().forEach(m => {
        const li = document.createElement("li");
        li.className = "memory-record-item";
        li.style.display = "flex";
        li.style.justifyContent = "space-between";
        li.style.alignItems = "center";
        li.style.padding = "0.65rem 0.8rem";
        li.style.borderBottom = "1px solid rgba(107, 211, 255, 0.08)";
        li.style.fontSize = "0.85rem";
        
        const typeLabels = { goals: "🎯", favorites: "❤️", projects: "📚", important: "⭐", milestone: "🏆" };
        const label = typeLabels[m.type] || "🧠";
        
        li.innerHTML = `
          <div style="display: flex; align-items: center; gap: 0.6rem;">
            <span style="font-size: 1.1rem;">${label}</span>
            <div style="display: grid; gap: 0.15rem;">
              <span style="color: var(--text);">${m.content}</span>
              <small style="color: var(--muted); font-size: 0.7rem;">${new Date(m.timestamp).toLocaleDateString()} | Companion: ${m.companionId || "all"}</small>
            </div>
          </div>
          <button class="delete-mem-btn" data-mem-id="${m.id}" style="background: rgba(255,107,107,0.1); border: 1px solid rgba(255,107,107,0.3); border-radius: 4px; color: rgb(255,107,107); font-size: 10px; cursor: pointer; padding: 2px 6px;">Delete</button>
        `;

        li.querySelector(".delete-mem-btn").addEventListener("click", () => {
          state.memory = state.memory.filter(rec => rec.id !== m.id);
          saveState();
          render();
        });

        memoryRecordList.appendChild(li);
      });
    }
  }
}

function initShimejiEvents() {
  document.getElementById("inAppShimejiToggle").addEventListener("change", (e) => {
    state.shimeji.inAppEnabled = (e.target.value === "true");
    saveState();
    window.initInAppShimeji();
    render();
  });

  document.getElementById("overlayShimejiToggle").addEventListener("change", (e) => {
    toggleOverlayMode(e.target.value === "true");
  });

  document.getElementById("shimejiSize").addEventListener("input", (e) => {
    state.shimeji.petSize = Number(e.target.value);
    document.getElementById("petSizeVal").textContent = `${state.shimeji.petSize}px`;
  });
  document.getElementById("shimejiSize").addEventListener("change", () => {
    saveState();
    syncOverlayState();
    if (state.shimeji.inAppEnabled) window.initInAppShimeji();
  });

  document.getElementById("shimejiSpeed").addEventListener("input", (e) => {
    state.shimeji.petSpeed = Number(e.target.value) / 10;
    document.getElementById("petSpeedVal").textContent = `${state.shimeji.petSpeed.toFixed(1)}x`;
  });
  document.getElementById("shimejiSpeed").addEventListener("change", () => {
    saveState();
    syncOverlayState();
    if (state.shimeji.inAppEnabled) window.initInAppShimeji();
  });

  document.getElementById("shimejiOpacity").addEventListener("input", (e) => {
    state.shimeji.petOpacity = Number(e.target.value) / 100;
    document.getElementById("petOpacityVal").textContent = `${Math.round(state.shimeji.petOpacity * 100)}%`;
  });
  document.getElementById("shimejiOpacity").addEventListener("change", () => {
    saveState();
    syncOverlayState();
    if (state.shimeji.inAppEnabled) window.initInAppShimeji();
  });

  document.getElementById("shimejiSound").addEventListener("change", (e) => {
    state.shimeji.soundEnabled = e.target.checked;
    saveState();
    syncOverlayState();
    if (state.shimeji.inAppEnabled) window.initInAppShimeji();
    render();
  });

  document.getElementById("shimejiBatterySaver").addEventListener("change", (e) => {
    state.shimeji.batterySaver = e.target.checked;
    saveState();
    syncOverlayState();
    if (state.shimeji.inAppEnabled) window.initInAppShimeji();
  });

  document.getElementById("shimejiSoundVol").addEventListener("input", (e) => {
    state.shimeji.soundVolume = Number(e.target.value);
    document.getElementById("soundVolVal").textContent = `${state.shimeji.soundVolume}%`;
  });
  document.getElementById("shimejiSoundVol").addEventListener("change", () => {
    saveState();
    syncOverlayState();
    if (state.shimeji.inAppEnabled) window.initInAppShimeji();
  });

  const triggerAction = (actionName) => {
    const companionId = String(state.personality || "maxie").toLowerCase();
    if (window.ActivityEngine && typeof window.ActivityEngine.run === "function") {
      window.ActivityEngine.run(companionId, actionName);
    } else {
      state.shimeji.action = { name: actionName, timestamp: Date.now() };
      saveState();
      syncOverlayState();
      if (state.shimeji.inAppEnabled && window.inAppPets) {
        window.inAppPets.forEach(p => p.setAnimation(actionName));
      }
    }
  };

  document.getElementById("shimejiFeedBtn").addEventListener("click", () => triggerAction("feed"));
  document.getElementById("shimejiDanceBtn").addEventListener("click", () => triggerAction("dance"));
  document.getElementById("shimejiSleepBtn").addEventListener("click", () => triggerAction("sleep"));
  document.getElementById("shimejiListenBtn").addEventListener("click", () => triggerAction("talk"));
  document.getElementById("shimejiResetBtn").addEventListener("click", () => {
    if (window.inAppPets) {
      window.inAppPets.forEach(p => {
        p.physics.position.y = p.physics.floorY;
        p.physics.velocity = { x: 0, y: 0 };
        p.setAnimation("idle");
      });
    }
    state.shimeji.action = { name: "idle", timestamp: Date.now() };
    saveState();
    syncOverlayState();
  });

  // Bind voice synthesis toggle
  const voiceSynthToggle = document.getElementById("voiceSynthToggle");
  if (voiceSynthToggle) {
    voiceSynthToggle.addEventListener("click", () => {
      if (!state.shimeji.voice) state.shimeji.voice = { speechEnabled: false, ttsEnabled: false };
      state.shimeji.voice.ttsEnabled = !state.shimeji.voice.ttsEnabled;
      saveState();
      render();
      if (state.shimeji.voice.ttsEnabled) {
        if (window.TtsSynthesis && typeof window.TtsSynthesis.speak === "function") {
          window.TtsSynthesis.speak("Voice enabled!");
        }
      }
    });
  }

  // Bind speech recognition recording button
  const voiceRecBtn = document.getElementById("voiceRecBtn");
  if (voiceRecBtn) {
    if (window.SpeechRec && typeof window.SpeechRec.isSupported === "function" && window.SpeechRec.isSupported()) {
      window.SpeechRec.init(
        (text) => {
          const chatInput = document.getElementById("chatInput");
          if (chatInput) {
            chatInput.value = text;
          }
          voiceRecBtn.style.color = "var(--text)";
          voiceRecBtn.style.borderColor = "var(--line)";
        },
        (err) => {
          voiceRecBtn.style.color = "var(--text)";
          voiceRecBtn.style.borderColor = "var(--line)";
        },
        () => {
          voiceRecBtn.style.color = "var(--text)";
          voiceRecBtn.style.borderColor = "var(--line)";
        }
      );

      voiceRecBtn.addEventListener("click", () => {
        if (window.SpeechRec.isListening()) {
          window.SpeechRec.stop();
          voiceRecBtn.style.color = "var(--text)";
          voiceRecBtn.style.borderColor = "var(--line)";
        } else {
          window.SpeechRec.start();
          voiceRecBtn.style.color = "var(--mint)";
          voiceRecBtn.style.borderColor = "var(--mint)";
        }
      });
    } else {
      voiceRecBtn.style.opacity = "0.5";
      voiceRecBtn.title = "Voice input is not supported on this platform";
      voiceRecBtn.addEventListener("click", () => {
        alert("Voice recognition is not supported on this browser/environment.");
      });
    }
  }

  let titleClicks = 0;
  document.getElementById("shimejiTitle").addEventListener("click", () => {
    titleClicks++;
    if (titleClicks >= 5) {
      titleClicks = 0;
      document.getElementById("shimejiDebugPanel").style.display = "block";
      startDebugLoop();
    }
  });

  document.getElementById("shimejiDebugClose").addEventListener("click", () => {
    document.getElementById("shimejiDebugPanel").style.display = "none";
    stopDebugLoop();
  });

  document.getElementById("debugSpawnBtn").addEventListener("click", () => {
    const id = document.getElementById("debugSpawnSelect").value;
    if (state.shimeji.inAppEnabled && window.inAppPets) {
      window.inAppPets.push(new window.InAppPetInstance(id, {}));
    }
  });

  document.getElementById("debugAnimBtn").addEventListener("click", () => {
    const anim = document.getElementById("debugAnimSelect").value;
    if (window.inAppPets) {
      window.inAppPets.forEach(p => p.setAnimation(anim));
    }
  });

  document.getElementById("debugResetStateBtn").addEventListener("click", () => {
    state.shimeji = structuredClone(defaults.shimeji);
    saveState();
    render();
    window.initInAppShimeji();
    syncOverlayState();
  });
}

let debugInterval = null;
function startDebugLoop() {
  clearInterval(debugInterval);
  debugInterval = setInterval(() => {
    const activeCount = (window.inAppPets ? window.inAppPets.length : 0);
    document.getElementById("debugFps").textContent = state.shimeji.batterySaver ? "12 FPS" : (inAppIdle ? "15 FPS" : "45 FPS");
    document.getElementById("debugPets").textContent = `${activeCount} in-app / ${state.shimeji.activeCompanions.length} selected`;
    
    if (window.inAppPets && window.inAppPets[0]) {
      const p = window.inAppPets[0];
      document.getElementById("debugState").textContent = `Anim: ${p.currentAnimation} | Pos: (${Math.round(p.physics.position.x)}, ${Math.round(p.physics.position.y)})`;
      document.getElementById("debugStats").textContent = `Friendship: Lv.${state.friendship} | Total XP: ${state.xp}`;
    } else {
      document.getElementById("debugState").textContent = "No active pet instances";
    }
  }, 1000);
}

function stopDebugLoop() {
  clearInterval(debugInterval);
}

els.resetButton.addEventListener("click", () => {
  state = structuredClone(defaults);
  saveState();
  speak("Fresh start. Still cute.");
  render();
  switchView("home");
  if (state.shimeji?.inAppEnabled) window.initInAppShimeji();
});

setInterval(() => {
  state.needs.energy = clamp(state.needs.energy - 1);
  state.needs.food = clamp(state.needs.food - 1);
  state.needs.fun = clamp(state.needs.fun - 1);
  if (state.needs.energy < 25) state.mood = "Sleepy";
  saveState();
  render();
}, 60000);

initShimejiEvents();
render();
window.initInAppShimeji();
if (window.companionEngine) {
  const companionId = String(state.personality || "maxie").toLowerCase();
  window.companionEngine.handleEvent("APP_OPENED", { companionId });
}
speak(contextLines[state.context]);

if ("serviceWorker" in navigator && !location.protocol.startsWith("file")) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("service-worker.js").catch(() => {});
  });
}
