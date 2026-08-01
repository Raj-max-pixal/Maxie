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
  avatar: ""
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
  return {
    ...structuredClone(base),
    ...saved,
    needs: { ...base.needs, ...(saved.needs || {}) },
    tasks: Array.isArray(saved.tasks) ? saved.tasks : base.tasks,
    habits: saved.habits || base.habits,
    chat: Array.isArray(saved.chat) ? saved.chat : base.chat
  };
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

els.chatForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const text = els.chatInput.value.trim();
  if (!text) return;
  const answer = replyFor(text);
  state.chat.push({ role: "user", text }, { role: "bot", text: answer });
  els.chatInput.value = "";
  addXp(8);
  speak(answer);
  saveState();
  render();
});

els.contextSelect.addEventListener("change", () => {
  state.context = els.contextSelect.value;
  const line = contextLines[state.context];
  addXp(6);
  speak(line);
  state.chat.push({ role: "bot", text: line });
  saveState();
  render();
});

document.querySelectorAll("[data-context]").forEach((button) => {
  button.addEventListener("click", () => {
    state.context = button.dataset.context;
    const line = contextLines[state.context];
    speak(line);
    state.chat.push({ role: "bot", text: line });
    addXp(6);
    saveState();
    render();
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

els.resetButton.addEventListener("click", () => {
  state = structuredClone(defaults);
  saveState();
  speak("Fresh start. Still cute.");
  render();
  switchView("home");
});

setInterval(() => {
  state.needs.energy = clamp(state.needs.energy - 1);
  state.needs.food = clamp(state.needs.food - 1);
  state.needs.fun = clamp(state.needs.fun - 1);
  if (state.needs.energy < 25) state.mood = "Sleepy";
  saveState();
  render();
}, 60000);

render();
speak(contextLines[state.context]);

if ("serviceWorker" in navigator && !location.protocol.startsWith("file")) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("service-worker.js").catch(() => {});
  });
}
