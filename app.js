const storeKey = "maxie-prototype-v1";
const isMobileShell = window.matchMedia("(max-width: 760px), (pointer: coarse)").matches;

const defaults = {
  name: "MAXie",
  personality: "Cute",
  context: "Desktop",
  mood: "Happy",
  xp: 0,
  needs: {
    energy: 82,
    food: 74,
    fun: 68,
    friendship: 52
  },
  memories: [],
  avatar: ""
};

const lines = {
  Cute: ["I saved a tiny happy spark for you.", "We can do this one small step at a time."],
  Funny: ["I am monitoring the vibes. Very scientific.", "That task blinked first. We win."],
  Chill: ["No rush. I'll keep the desk cozy.", "Soft focus mode engaged."],
  Motivational: ["You showed up. That counts. Now let's move.", "One focused sprint and future-you gets a gift."],
  Gamer: ["Quest accepted. XP is waiting.", "Let's clear this objective cleanly."],
  Nerd: ["I brought notes, curiosity, and exactly one dramatic pause.", "Debugging is just archaeology with snacks."],
  Mischievous: ["I may have hidden your procrastination button.", "Suspiciously productive behavior detected."],
  Professional: ["Priorities are organized. Ready when you are.", "I can help you turn this into a clean checklist."]
};

const contextLines = {
  Desktop: "I'm watching the workspace, with permission vibes only.",
  "VS Code": "Coding mode: I can track bugs, ideas, and tiny victories.",
  Chrome: "Browsing mode: save useful links as memories before they vanish.",
  Spotify: "Music mode: if the beat rises, I dance. That is the law.",
  Steam: "Gaming mode: hydrate before the next match.",
  "Study session": "Study mode: I can quiz you after this focus block."
};

let state = loadState();

const els = {
  avatarInput: document.getElementById("avatarInput"),
  resetButton: document.getElementById("resetButton"),
  companion: document.getElementById("companion"),
  petAvatar: document.getElementById("petAvatar"),
  speechBubble: document.getElementById("speechBubble"),
  nameInput: document.getElementById("nameInput"),
  personalitySelect: document.getElementById("personalitySelect"),
  contextSelect: document.getElementById("contextSelect"),
  talkButton: document.getElementById("talkButton"),
  feedButton: document.getElementById("feedButton"),
  playButton: document.getElementById("playButton"),
  moodBadge: document.getElementById("moodBadge"),
  stageBadge: document.getElementById("stageBadge"),
  energyMeter: document.getElementById("energyMeter"),
  foodMeter: document.getElementById("foodMeter"),
  funMeter: document.getElementById("funMeter"),
  friendshipMeter: document.getElementById("friendshipMeter"),
  xpLabel: document.getElementById("xpLabel"),
  xpProgress: document.getElementById("xpProgress"),
  taskForm: document.getElementById("taskForm"),
  memoryInput: document.getElementById("memoryInput"),
  memoryList: document.getElementById("memoryList")
};

function loadState() {
  try {
    return { ...defaults, ...JSON.parse(localStorage.getItem(storeKey) || "{}") };
  } catch {
    return { ...defaults };
  }
}

function saveState() {
  localStorage.setItem(storeKey, JSON.stringify(state));
}

function clamp(value) {
  return Math.max(0, Math.min(100, value));
}

function addXp(amount) {
  state.xp += amount;
  if (state.xp >= 500) state.mood = "Proud";
  else if (state.needs.energy < 25) state.mood = "Sleepy";
  else if (state.needs.fun > 82) state.mood = "Excited";
  else state.mood = "Happy";
}

function stageForXp(xp) {
  if (xp >= 900) return "Master";
  if (xp >= 500) return "Adult";
  if (xp >= 250) return "Teen";
  if (xp >= 100) return "Kid";
  return "Baby";
}

function nextLine() {
  const personalitySet = lines[state.personality] || lines.Cute;
  const pool = [contextLines[state.context], ...personalitySet];
  return pool[Math.floor(Math.random() * pool.length)];
}

function makeId() {
  if (crypto?.randomUUID) return crypto.randomUUID();
  return `${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

function speak(text) {
  els.speechBubble.textContent = text;
}

function render() {
  els.nameInput.value = state.name;
  els.personalitySelect.value = state.personality;
  els.contextSelect.value = state.context;
  els.moodBadge.textContent = state.mood;
  els.stageBadge.textContent = stageForXp(state.xp);
  els.energyMeter.value = state.needs.energy;
  els.foodMeter.value = state.needs.food;
  els.funMeter.value = state.needs.fun;
  els.friendshipMeter.value = state.needs.friendship;
  els.xpProgress.value = state.xp % 100;
  els.xpLabel.textContent = `${state.xp % 100} / 100`;
  els.petAvatar.style.backgroundImage = state.avatar ? `url("${state.avatar}")` : "";

  els.companion.classList.toggle("is-excited", state.mood === "Excited" || state.mood === "Proud");
  els.companion.classList.toggle("is-sleepy", state.mood === "Sleepy");

  els.memoryList.innerHTML = "";
  state.memories.slice().reverse().forEach((memory) => {
    const item = document.createElement("li");
    const text = document.createElement("span");
    const remove = document.createElement("button");
    text.textContent = memory.text;
    remove.type = "button";
    remove.textContent = "Delete";
    remove.addEventListener("click", () => {
      state.memories = state.memories.filter((entry) => entry.id !== memory.id);
      saveState();
      render();
    });
    item.append(text, remove);
    els.memoryList.appendChild(item);
  });
}

els.avatarInput.addEventListener("change", (event) => {
  const file = event.target.files?.[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = () => {
    state.avatar = reader.result;
    state.needs.friendship = clamp(state.needs.friendship + 8);
    addXp(20);
    speak(`${state.name} is alive on your desktop.`);
    saveState();
    render();
  };
  reader.readAsDataURL(file);
});

els.nameInput.addEventListener("input", () => {
  state.name = els.nameInput.value.trim() || "MAXie";
  saveState();
});

els.personalitySelect.addEventListener("change", () => {
  state.personality = els.personalitySelect.value;
  speak(`${state.personality} personality loaded.`);
  addXp(5);
  saveState();
  render();
});

els.contextSelect.addEventListener("change", () => {
  state.context = els.contextSelect.value;
  speak(contextLines[state.context]);
  addXp(5);
  saveState();
  render();
});

els.talkButton.addEventListener("click", () => {
  state.needs.friendship = clamp(state.needs.friendship + 6);
  state.needs.energy = clamp(state.needs.energy - 2);
  addXp(12);
  speak(nextLine());
  saveState();
  render();
});

els.companion.addEventListener("click", () => {
  state.needs.fun = clamp(state.needs.fun + 4);
  addXp(8);
  speak(nextLine());
  saveState();
  render();
});

els.feedButton.addEventListener("click", () => {
  state.needs.food = clamp(state.needs.food + 14);
  state.needs.energy = clamp(state.needs.energy + 5);
  addXp(10);
  speak("Snack acquired. Happiness restored.");
  saveState();
  render();
});

els.playButton.addEventListener("click", () => {
  state.needs.fun = clamp(state.needs.fun + 15);
  state.needs.energy = clamp(state.needs.energy - 7);
  addXp(15);
  speak("Tiny dance break!");
  saveState();
  render();
});

document.querySelectorAll("[data-mode]").forEach((button) => {
  button.addEventListener("click", () => {
    const mode = button.dataset.mode;
    const prompts = {
      Coding: "Paste an error or save the bug as a memory.",
      Study: "Focus for 25 minutes, then I can quiz you.",
      Focus: "I will stay quiet and keep your streak warm.",
      Creative: "Give me a theme and I will help make ideas."
    };
    addXp(10);
    speak(prompts[mode]);
    saveState();
    render();
  });
});

els.taskForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const text = els.memoryInput.value.trim();
  if (!text) return;
  state.memories.push({ id: makeId(), text });
  els.memoryInput.value = "";
  state.needs.knowledge = clamp((state.needs.knowledge || 50) + 4);
  addXp(18);
  speak("Saved. You can delete that memory anytime.");
  saveState();
  render();
});

els.resetButton.addEventListener("click", () => {
  state = { ...defaults, needs: { ...defaults.needs }, memories: [] };
  saveState();
  speak("Fresh start. Still cute.");
  render();
});

setInterval(() => {
  state.needs.energy = clamp(state.needs.energy - 1);
  state.needs.food = clamp(state.needs.food - 1);
  state.needs.fun = clamp(state.needs.fun - 1);
  if (state.needs.energy < 25) {
    state.mood = "Sleepy";
    speak("I might curl up soon. A tiny break sounds nice.");
  }
  saveState();
  render();
}, 45000);

render();
speak(`Hey! I'm ${state.name}.`);

if ("serviceWorker" in navigator && !location.protocol.startsWith("file")) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("service-worker.js").catch(() => {});
  });
}

document.body.classList.toggle("is-mobile-shell", isMobileShell);
