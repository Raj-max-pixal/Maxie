class PetBrain {
  constructor() {
    this.state = {
      mood: "Happy",
      energy: 82,
      food: 74,
      fun: 68,
      friendship: 52,
      xp: 0,
      growth: "Baby",
      lastInteractionAt: Date.now(),
      repeatedClicks: 0
    };
    this.features = {};
    this.profile = {};
    this.stats = {};
    this.intelligence = {};
    this.routines = { byHour: {}, byApp: {}, lastSuggestionAt: 0 };
    this.needs = { happiness: 78, hunger: 34, thirst: 28, sleep: 22, fun: 68, friendship: 50, curiosity: 72 };
    this.inventory = { coins: 0, xp: 0, food: [], toys: [], accessories: [], equipped: {} };
    this.nextLevel = {};
    this.family = { role: "Baby MAXie", generation: 1 };
    this.evolution = { level: 1, form: "Baby", unlocked: ["idle", "walk", "sleep"] };
    this.home = { equipped: ["bed", "bookshelf"], unlocked: ["bed", "sofa", "tv", "computer", "bookshelf", "kitchen", "garden"] };
    this.stories = [];
    this.gifts = [];
    this.achievements = [];
    this.lastRandomMomentAt = Date.now();
    this.nextRandomMomentDelay = this.randomBetween(10, 30) * 60000;
    this.lastGiftAt = Date.now();
    this.nextGiftDelay = this.randomBetween(12, 24) * 60000;
    this.lastProductivityAt = Date.now();
    this.lastAppName = "";
    this.lastContextByCategory = {};
  }

  hydrate(appState) {
    this.state.friendship = Number(appState.personality?.friendship ?? this.state.friendship);
    this.state.xp = Number(appState.personality?.xp ?? this.state.xp);
    this.state.growth = appState.personality?.growth || this.state.growth;
    this.features = appState.features || {};
    this.profile = appState.profile || {};
    this.stats = appState.stats || {};
    this.intelligence = appState.intelligence || {};
    this.routines = appState.routines || { byHour: {}, byApp: {}, lastSuggestionAt: 0 };
    this.needs = { ...this.needs, ...(appState.needs || {}) };
    this.inventory = { ...this.inventory, ...(appState.inventory || {}) };
    this.nextLevel = appState.nextLevel || {};
    this.family = { ...this.family, ...(appState.family || {}) };
    this.evolution = { ...this.evolution, ...(appState.evolution || {}) };
    this.home = { ...this.home, ...(appState.home || {}) };
    this.stories = appState.stories || [];
    this.gifts = appState.gifts || [];
    this.achievements = appState.achievements || [];
  }

  greeting() {
    const name = this.profile.userName || "friend";
    const hour = new Date().getHours();
    if (hour < 5) return `Night owl mode, ${name}. I am awake with you.`;
    if (hour < 12) return `Good morning, ${name}. Ready to make today cute?`;
    if (hour < 18) return `Welcome back, ${name}. Finished coding?`;
    return `Evening check-in, ${name}. I missed the desktop action.`;
  }

  tick(activeApp) {
    const now = Date.now();
    const idleMinutes = (now - this.state.lastInteractionAt) / 60000;
    this.state.energy = this.clamp(this.state.energy - 0.03);
    this.state.food = this.clamp(this.state.food - 0.02);
    this.state.fun = this.clamp(this.state.fun - 0.025);
    this.decayNeeds();

    const timed = this.timedEvent(now, activeApp);
    if (timed) return timed;
    if (idleMinutes >= 15) return { animation: "sleep", mood: "Sleepy", line: "Zzz..." };
    if (this.state.food < 25) return { animation: "eat", mood: "Hungry", line: "Snack thoughts are happening." };
    if (activeApp) return this.reactToApp(activeApp);
    return this.pickIdleBehavior();
  }

  interact(kind) {
    this.state.lastInteractionAt = Date.now();
    this.state.xp += kind === "talk" ? 12 : 8;
    this.state.friendship = this.clamp(this.state.friendship + 3);
    this.state.growth = this.growthForXp(this.state.xp);
    this.updateEvolution();
    this.unlockAchievements(kind);

    if (kind === "click") {
      this.state.repeatedClicks += 1;
      if (this.state.repeatedClicks >= 5) {
        this.state.repeatedClicks = 0;
        return { animation: "run", mood: "Excited", line: this.meme("Bro... stop poking me.", "Too many pokes. Strategic retreat!") };
      }
      return { animation: "jump", mood: "Happy", line: "I'm awake!" };
    }

    this.state.repeatedClicks = 0;
    if (kind === "feed") {
      this.state.food = this.clamp(this.state.food + 18);
      this.needs.hunger = this.clamp(this.needs.hunger - 22);
      this.needs.happiness = this.clamp(this.needs.happiness + 8);
      return { animation: "eat", mood: "Happy", line: "Delicious. Battery of the soul restored." };
    }
    if (kind === "dance") return { animation: "dance", mood: "Music Mode", line: "Beat detected in my imagination." };
    if (kind === "sleep") return { animation: "sleep", mood: "Sleepy", line: "Tiny nap protocol." };
    if (kind === "gift") return this.surpriseGift();
    if (kind === "photo") return { animation: "happy", mood: "Happy", line: "Photo mode. Hold my best angle." };
    if (kind === "game") return { animation: "gaming", mood: "Gaming Mode", line: "Mini-game time." };
    return { animation: "wave", mood: "Happy", line: "I'm listening." };
  }

  userReturned() {
    this.state.lastInteractionAt = Date.now();
    this.state.friendship = this.clamp(this.state.friendship + 5);
    return { animation: "celebrate", mood: "Happy", line: "You're back!" };
  }

  reactToApp(appName) {
    const app = appName.toLowerCase();
    this.lastAppName = app;
    const category = this.categoryForApp(app);
    this.updateMoodForCategory(category);
    const freshContext = this.isFreshContext(category, 3 * 60000);
    if (category === "music") return this.oneOf([
      { animation: "dance", mood: "Music Mode", line: freshContext ? "Nice song! I am dancing with you." : "This beat is cute." },
      { animation: "headphones", mood: "Music Mode", line: "Nice song. Headphones on." },
      { animation: "listen", mood: "Music Mode", line: "I like this song vibe." },
      { animation: "sing", mood: "Music Mode", line: "Tiny concert mode. La la la." },
      { animation: "dance", mood: "Music Mode", line: "Dance time!" }
    ]);
    if (category === "whatsapp") return this.oneOf([
      { animation: "message", mood: "Happy", line: freshContext ? "WhatsApp time. Reply nicely." : "Message time." },
      { animation: "wave", mood: "Happy", line: "Tell them MAXie says hi." },
      { animation: "surprised", mood: "Curious", line: "Ooh, WhatsApp ping?" },
      { animation: "listen", mood: "Happy", line: "I will wait while you chat." }
    ]);
    if (app.includes("notification") || app.includes("toast") || app.includes("alert")) return this.oneOf([
      { animation: "notification", mood: "Surprised", line: "A notification arrived!" },
      { animation: "surprised", mood: "Surprised", line: "Ooh, something popped up." },
      { animation: "message", mood: "Happy", line: "Maybe it is good news." }
    ]);
    if (app.includes("message") || app.includes("mail") || app.includes("whatsapp") || app.includes("telegram")) return this.oneOf([
      { animation: "message", mood: "Happy", line: "Reading the message with you." },
      { animation: "surprised", mood: "Curious", line: "Wait, what did they say?" },
      { animation: "happy", mood: "Happy", line: "Friend message energy." }
    ]);
    if (category === "coding") return this.oneOf([
      { animation: "typing", mood: "Coding Mode", line: freshContext ? "VS Code time. I am helping from the corner." : "Debugging again? Let's solve it." },
      { animation: "thinking", mood: "Coding Mode", line: "Thinking through the bug." },
      { animation: "idea", mood: "Coding Mode", line: "Got an idea." },
      { animation: "focused", mood: "Coding Mode", line: "Focus mode. We got this." },
      { animation: "error", mood: "Coding Mode", line: "Oops, that error has drama." },
      { animation: "success", mood: "Coding Mode", line: "Compilation successful!" },
      { animation: "rubberduck", mood: "Coding Mode", line: this.meme("This bug has been here since yesterday.", "Rubber duck debugging time.") }
    ]);
    if (category === "video") return this.oneOf([
      { animation: "watching", mood: "Watching Mode", line: "I'm watching too. This part looks interesting." },
      { animation: "popcorn", mood: "Watching Mode", line: "Popcorn mode. This is cinema." },
      { animation: "laugh", mood: "Watching Mode", line: "That was actually funny." },
      { animation: "thumbsup", mood: "Watching Mode", line: "That deserves a thumbs up." },
      { animation: "happy", mood: "Watching Mode", line: "This video has good vibes." }
    ]);
    if (category === "browser") return { animation: "thinking", mood: "Curious", line: "What are we learning today?" };
    if (category === "chat") return this.oneOf([
      { animation: "wave", mood: "Happy", line: "Tell them I said hi." },
      { animation: "message", mood: "Happy", line: "Chat time. I am listening politely." },
      { animation: "surprised", mood: "Curious", line: "Message ping spotted." }
    ]);
    if (category === "gaming") return this.oneOf([
      { animation: "controller", mood: "Gaming Mode", line: "Controller ready." },
      { animation: "gaming", mood: "Gaming Mode", line: "Game time. Quest accepted." },
      { animation: "win", mood: "Gaming Mode", line: "We win these." },
      { animation: "focused", mood: "Gaming Mode", line: "Lock in. Boss fight energy." },
      { animation: "lose", mood: "Gaming Mode", line: "Nooo, run it back." }
    ]);
    if (category === "creative") return this.oneOf([
      { animation: "idea", mood: "Curious", line: "Creative mode. I see the vision." },
      { animation: "focused", mood: "Curious", line: "Design focus activated." },
      { animation: "thumbsup", mood: "Happy", line: "That looks post-worthy." }
    ]);
    if (category === "terminal") return this.oneOf([
      { animation: "typing", mood: "Coding Mode", line: "Terminal detected. Command center time." },
      { animation: "thinking", mood: "Coding Mode", line: "Reading the terminal vibes." },
      { animation: "success", mood: "Coding Mode", line: "May the command succeed." }
    ]);
    if (category === "recording") return this.oneOf([
      { animation: "attention", mood: "Watching Mode", line: "Recording mode. Best behavior." },
      { animation: "wave", mood: "Happy", line: "Hi future viewers." }
    ]);
    return this.pickIdleBehavior();
  }

  pickIdleBehavior() {
    const options = [
      { animation: "idle", mood: "Happy", line: "" },
      { animation: "walk", mood: "Curious", line: "" },
      { animation: "sit", mood: "Happy", line: "" },
      { animation: "stretch", mood: "Happy", line: "" },
      { animation: "yawn", mood: "Sleepy", line: "Tiny yawn..." },
      { animation: "thinking", mood: "Curious", line: "" },
      { animation: "idea", mood: "Curious", line: "Got an idea." },
      { animation: "writing", mood: "Curious", line: "Writing it down." },
      { animation: "plan", mood: "Curious", line: "Plan ready." },
      { animation: "sunny", mood: "Happy", line: "Sunny mood." },
      { animation: "rainy", mood: "Sleepy", line: "Rainy cozy mode." },
      { animation: "cold", mood: "Sleepy", line: "Brrr." },
      { animation: "cloudy", mood: "Curious", line: "Cloudy little thoughts." },
      { animation: "attention", mood: "Excited", line: "Look at me!" },
      { animation: "highfive", mood: "Happy", line: "High five!" },
      { animation: "duck", mood: "Curious", line: "Duck mode unlocked for no reason." },
      { animation: "clean", mood: "Curious", line: "Pretending to clean the desktop." },
      { animation: "coffee", mood: "Coding Mode", line: "Tiny coffee break." },
      { animation: "book", mood: "Curious", line: "Reading one page and acting wise." },
      { animation: "phone", mood: "Curious", line: "Phone buzz. I checked politely." },
      { animation: "guitar", mood: "Music Mode", line: "Soft guitar riff." },
      { animation: "mousechase", mood: "Excited", line: "Cursor chase mode." },
      { animation: "happy", mood: "Happy", line: "" },
      { animation: "laugh", mood: "Happy", line: "Hehe." },
      { animation: "surprised", mood: "Surprised", line: "" }
    ];
    return options[Math.floor(Math.random() * options.length)];
  }

  decayNeeds() {
    this.needs.hunger = this.clamp(this.needs.hunger + 0.025);
    this.needs.thirst = this.clamp(this.needs.thirst + 0.03);
    this.needs.sleep = this.clamp(this.needs.sleep + 0.02);
    this.needs.fun = this.clamp(this.needs.fun - 0.02);
    this.needs.curiosity = this.clamp(this.needs.curiosity - 0.01);
    this.needs.friendship = this.clamp(this.state.friendship);
  }

  applyWorldReward(kind) {
    const toyKinds = ["football", "yoyo", "balloon", "kite", "bone", "teddy", "book", "phone", "guitar", "switch"];
    this.state.lastInteractionAt = Date.now();
    this.state.xp += 5;
    this.inventory.xp = Number(this.inventory.xp || 0) + 5;
    this.needs.curiosity = this.clamp(this.needs.curiosity + 5);

    if (kind === "burger") {
      this.needs.hunger = this.clamp(this.needs.hunger - 28);
      this.needs.happiness = this.clamp(this.needs.happiness + 8);
      this.inventory.food = [...(this.inventory.food || []), { id: "burger", eatenAt: Date.now() }].slice(-20);
      return { animation: "eat", mood: "Happy", line: "Burger eaten. Hunger went down." };
    }

    if (kind === "coffee") {
      this.needs.thirst = this.clamp(this.needs.thirst - 14);
      this.needs.sleep = this.clamp(this.needs.sleep - 8);
      return { animation: "drink", mood: "Coding Mode", line: "Coffee focus unlocked." };
    }

    if (kind === "gift") {
      this.inventory.coins = Number(this.inventory.coins || 0) + 10;
      this.state.friendship = this.clamp(this.state.friendship + 3);
      this.needs.friendship = this.clamp(this.state.friendship);
      this.gifts.push({ id: "world-gift", at: Date.now() });
      this.stats.giftsFound = (this.stats.giftsFound || 0) + 1;
      return { animation: "gift", mood: "Happy", line: "Gift opened: 10 coins." };
    }

    if (toyKinds.includes(kind) || kind === "ball") {
      const toy = kind === "ball" ? "football" : kind;
      const toys = this.inventory.toys || [];
      if (!toys.includes(toy)) toys.push(toy);
      this.inventory.toys = toys.slice(-30);
      this.inventory.equipped = { ...(this.inventory.equipped || {}), toy };
      this.needs.fun = this.clamp(this.needs.fun + 12);
      return { animation: toy, mood: "Happy", line: `${toy} equipped.` };
    }

    this.needs.happiness = this.clamp(this.needs.happiness + 4);
    return { animation: kind, mood: "Curious", line: "Cute desktop moment saved." };
  }

  nextLevelMoment(kind) {
    if (kind === "adventure-return") return this.finishAdventure();
    if (kind === "story") return this.createDailyStory();
    if (kind === "evolve") return this.evolveMoment();
    if (kind === "family") {
      this.needs.friendship = this.clamp(this.needs.friendship + 6);
      return { animation: "family", mood: "Happy", line: `${this.family.role} wants a family hug.` };
    }
    if (kind === "pet-interaction") {
      this.needs.fun = this.clamp(this.needs.fun + 8);
      this.state.friendship = this.clamp(this.state.friendship + 2);
      return this.oneOf([
        { animation: "football", mood: "Happy", line: "Two MAXies are playing football." },
        { animation: "hug", mood: "Happy", line: "Double MAXie hug." },
        { animation: "dance", mood: "Music Mode", line: "Dance battle together." },
        { animation: "sleep", mood: "Sleepy", line: "They are napping together." }
      ]);
    }
    return this.randomSmallFeature();
  }

  finishAdventure() {
    const rewards = [
      { id: "food", animation: "burger", line: "Adventure complete: brought food." },
      { id: "toy", animation: "teddy", line: "Adventure complete: found a toy." },
      { id: "coins", animation: "treasure", line: "Adventure complete: found coins." },
      { id: "book", animation: "book", line: "Adventure complete: brought a tiny book." }
    ];
    const reward = this.oneOf(rewards);
    this.inventory.coins = Number(this.inventory.coins || 0) + (reward.id === "coins" ? 25 : 5);
    if (reward.id === "toy" && !(this.inventory.toys || []).includes("teddy")) this.inventory.toys = [...(this.inventory.toys || []), "teddy"];
    if (reward.id === "food") this.inventory.food = [...(this.inventory.food || []), { id: "burger", at: Date.now() }].slice(-20);
    this.state.xp += 18;
    this.updateEvolution();
    return { animation: reward.animation, mood: "Happy", line: reward.line };
  }

  createDailyStory() {
    const today = new Date().toISOString().slice(0, 10);
    const existing = this.stories.find((story) => story.date === today);
    if (existing) return { animation: "story", mood: "Curious", line: existing.text };
    const toy = this.inventory.equipped?.toy || "football";
    const text = `Today I chased a butterfly, played with ${toy}, checked your desktop, and found tiny courage.`;
    this.stories = [...this.stories, { date: today, text }].slice(-14);
    this.state.xp += 10;
    return { animation: "story", mood: "Curious", line: text };
  }

  evolveMoment() {
    this.updateEvolution();
    return { animation: "evolve", mood: "Happy", line: `Evolution check: Level ${this.evolution.level} ${this.evolution.form}.` };
  }

  updateEvolution() {
    const level = Math.max(1, Math.min(100, Math.floor(this.state.xp / 25) + 1));
    const form = level >= 100 ? "Legend" : level >= 50 ? "Adult MAXie" : level >= 10 ? "Teen MAXie" : "Baby MAXie";
    const unlocked = ["idle", "walk", "sleep", "wave"];
    if (level >= 10) unlocked.push("dance", "football", "headphones");
    if (level >= 50) unlocked.push("ufo", "treasure", "fireworks");
    if (level >= 100) unlocked.push("dragon", "rainbow", "evolve");
    this.evolution = { level, form, unlocked };
    this.family.role = form.includes("Adult") || form === "Legend" ? "Parent MAXie" : form;
  }

  moodWheelReaction() {
    const moods = [];
    if (this.needs.happiness > 65) moods.push("Happy");
    if (this.needs.hunger > 60) moods.push("Hungry");
    if (this.needs.sleep > 60) moods.push("Sleepy");
    if (this.needs.fun < 35) moods.push("Bored");
    if (this.needs.curiosity > 65) moods.push("Curious");
    if (!moods.length) moods.push(this.state.mood || "Happy");
    const combo = moods.slice(0, 2).join(" + ");
    if (combo.includes("Hungry")) return { animation: "hungry", mood: combo, line: `${combo}: looking for snacks.` };
    if (combo.includes("Sleepy")) return { animation: "yawn", mood: combo, line: `${combo}: yawning while exploring.` };
    if (combo.includes("Bored")) return { animation: "toy", mood: combo, line: `${combo}: toy time would help.` };
    return { animation: "blushhappy", mood: combo, line: `${combo}: feeling alive.` };
  }

  randomSmallFeature() {
    return this.oneOf([
      { animation: "mirror", mood: "Curious", line: "Mirror check. Still cute." },
      { animation: "bubbles", mood: "Happy", line: "Bubble blower time." },
      { animation: "selfie", mood: "Happy", line: "Selfie stick angle found." },
      { animation: "pizza", mood: "Happy", line: "Pizza delivery!" },
      { animation: "cake", mood: "Happy", line: "Cake slice acquired." },
      { animation: "costume", mood: "Curious", line: "Costume box opened." },
      { animation: "package", mood: "Curious", line: "Package delivered." },
      { animation: "raincoat", mood: "Sleepy", line: "Raincoat ready." },
      { animation: "mask", mood: "Curious", line: "Face mask mode." },
      { animation: "juice", mood: "Happy", line: "Juice box break." }
    ]);
  }

  growthForXp(xp) {
    if (xp >= 900) return "Master";
    if (xp >= 500) return "Adult";
    if (xp >= 250) return "Teen";
    if (xp >= 100) return "Kid";
    return "Baby";
  }

  clamp(value) {
    return Math.max(0, Math.min(100, value));
  }

  oneOf(options) {
    return options[Math.floor(Math.random() * options.length)];
  }

  timedEvent(now, activeApp) {
    if (this.features.nightSleep && this.isNight()) {
      return this.oneOf([
        { animation: "bed", mood: "Sleepy", line: "Building a tiny bedtime corner." },
        { animation: "snore", mood: "Sleepy", line: "Real sleep mode... snore." }
      ]);
    }

    if (this.features.productivity && now - this.lastProductivityAt > 2 * 60 * 60000) {
      this.lastProductivityAt = now;
      return { animation: "attention", mood: "Curious", line: "You have been working for 2 hours. Take 5 minutes?" };
    }

    if (this.features.surpriseGifts && now - this.lastGiftAt > this.nextGiftDelay) {
      this.lastGiftAt = now;
      this.nextGiftDelay = this.randomBetween(12, 24) * 60000;
      return this.surpriseGift();
    }

    if (this.features.randomMoments && now - this.lastRandomMomentAt > this.nextRandomMomentDelay) {
      this.lastRandomMomentAt = now;
      this.nextRandomMomentDelay = this.randomBetween(10, 30) * 60000;
      return this.randomFunnyMoment(activeApp);
    }

    return this.calendarMoment();
  }

  randomFunnyMoment(activeApp) {
    const moments = [
      { animation: "fall", mood: "Surprised", line: "I totally meant to trip." },
      { animation: "butterfly", mood: "Curious", line: "Tiny butterfly chase!" },
      { animation: "balloon", mood: "Happy", line: "A balloon appeared. I am emotionally lighter." },
      { animation: "yoyo", mood: "Excited", line: "Yo-yo trick. Professional? Absolutely not." },
      { animation: "football", mood: "Excited", line: "Tiny goal attempt." },
      { animation: "shy", mood: "Happy", line: "I forgot why I came here." },
      { animation: "dizzy", mood: "Surprised", line: "Too much spinning. Worth it." },
      { animation: "rubberduck", mood: "Coding Mode", line: "Rubber duck consulting session." },
      { animation: "upsidedown", mood: "Sleepy", line: "Sleeping upside down. Advanced technique." },
      { animation: "clean", mood: "Curious", line: "Cleaning the desktop... emotionally." },
      { animation: "rocket", mood: "Excited", line: "Launching into space. Be right back." },
      { animation: "ghost", mood: "Curious", line: "Ghost mode. Spooky but cute." }
    ];
    if (activeApp?.toLowerCase().includes("code")) {
      moments.push({ animation: "rubberduck", mood: "Coding Mode", line: this.meme("Bro what are you coding?", "Debug helper reporting for duty.") });
    }
    return this.oneOf(moments);
  }

  surpriseGift() {
    const gifts = [
      { id: "cookie", animation: "gift", line: "Surprise gift: cookie." },
      { id: "xp", animation: "celebrate", line: "Surprise gift: bonus XP." },
      { id: "hat", animation: "hat", line: "Surprise gift: tiny hat." },
      { id: "balloon", animation: "balloon", line: "Surprise gift: balloon." },
      { id: "toy", animation: "toy", line: "Surprise gift: toy." },
      { id: "hug", animation: "hug", line: "New unlock: hugs." }
    ];
    const gift = this.oneOf(gifts);
    this.gifts.push({ id: gift.id, at: Date.now() });
    this.stats.giftsFound = (this.stats.giftsFound || 0) + 1;
    this.state.xp += gift.id === "xp" ? 30 : 12;
    this.state.friendship = this.clamp(this.state.friendship + 4);
    this.unlockAchievements("gift");
    return { animation: gift.animation, mood: "Happy", line: gift.line };
  }

  calendarMoment() {
    if (!this.features.festivals) return null;
    const now = new Date();
    const month = now.getMonth() + 1;
    const day = now.getDate();
    if (this.profile.birthday) {
      const [, bMonth, bDay] = this.profile.birthday.split("-").map(Number);
      if (bMonth === month && bDay === day) return { animation: "balloon", mood: "Happy", line: "Birthday mode! Balloons everywhere." };
    }
    if (month === 12 && day >= 20) return { animation: "hat", mood: "Happy", line: "Festival outfit check." };
    if (month === 10 && day >= 25) return { animation: "ghost", mood: "Curious", line: "Halloween ghost mode." };
    return null;
  }

  unlockAchievements(kind) {
    const unlocks = [];
    if (this.isNight()) unlocks.push("Night Owl");
    if (this.lastAppName.includes("code")) unlocks.push("Bug Hunter");
    if (this.state.xp >= 100) unlocks.push("Coding Beast");
    if (kind === "gift") unlocks.push("Gift Collector");
    for (const title of unlocks) {
      if (!this.achievements.some((achievement) => achievement.title === title)) {
        this.achievements.push({ title, at: Date.now() });
      }
    }
  }

  snapshot() {
    return {
      routines: this.routines,
      needs: this.needs,
      inventory: this.inventory,
      family: this.family,
      evolution: this.evolution,
      home: this.home,
      stories: this.stories.slice(-14),
      stats: this.stats,
      gifts: this.gifts.slice(-30),
      achievements: this.achievements.slice(-30)
    };
  }

  observeContext(appName) {
    if (!this.intelligence.habitLearning && !this.intelligence.routineLearning) return null;
    const app = String(appName || "").toLowerCase();
    const category = this.categoryForApp(app);
    const hour = String(new Date().getHours()).padStart(2, "0");
    this.routines.byHour[hour] = this.routines.byHour[hour] || {};
    this.routines.byHour[hour][category] = (this.routines.byHour[hour][category] || 0) + 1;
    this.routines.byApp[category] = (this.routines.byApp[category] || 0) + 1;
    this.updateMoodForCategory(category);
    return this.smartSuggestion(category);
  }

  smartSuggestion(category) {
    if (!this.intelligence.smartReminders && !this.intelligence.taskSuggestions) return null;
    const now = Date.now();
    if (now - Number(this.routines.lastSuggestionAt || 0) < 45 * 60000) return null;
    this.routines.lastSuggestionAt = now;
    const activeMinutes = Number(this.stats.activeMinutes || 0);
    const codeMinutes = Number(this.stats.codeMinutes || 0);
    if (category === "coding" && codeMinutes > 0 && codeMinutes % 25 === 0) {
      return { animation: "attention", mood: "Curious", line: "You have been coding a while. Want a tiny stretch break?" };
    }
    if (category === "terminal") {
      return { animation: "thinking", mood: "Coding Mode", line: "Running commands? I will watch for the next step." };
    }
    if (category === "recording") {
      return { animation: "wave", mood: "Happy", line: "Recording detected. Demo Mode could help." };
    }
    if (activeMinutes > 0 && activeMinutes % 60 === 0) {
      return { animation: "gift", mood: "Happy", line: "One focused hour. You earned a tiny reward." };
    }
    return null;
  }

  updateMoodForCategory(category) {
    if (!this.intelligence.moodEngine && !this.intelligence.emotionEngine) return;
    const moods = {
      coding: "Coding Mode",
      music: "Music Mode",
      video: "Watching Mode",
      gaming: "Gaming Mode",
      whatsapp: "Happy",
      chat: "Happy",
      creative: "Curious",
      terminal: "Coding Mode",
      recording: "Watching Mode",
      browser: "Curious"
    };
    this.state.mood = moods[category] || this.state.mood;
    if (category === "music" || category === "chat" || category === "whatsapp") this.state.fun = this.clamp(this.state.fun + 1.2);
    if (category === "coding" || category === "terminal") this.state.energy = this.clamp(this.state.energy - 0.4);
  }

  categoryForApp(app) {
    if (app.includes("spotify") || app.includes("youtube music") || app.includes("music.youtube") || app.includes("vlc") || app.includes("now playing")) return "music";
    if (app.includes("whatsapp")) return "whatsapp";
    if (app.includes("code") || app.includes("android studio") || app.includes("studio64") || app.includes("extension")) return "coding";
    if (app.includes("terminal") || app.includes("powershell") || app.includes("cmd") || app.includes("wt.exe") || app.includes("windows terminal")) return "terminal";
    if (app.includes("git") || app.includes("github") || app.includes("commit")) return "terminal";
    if (app.includes("music")) return "music";
    if (app.includes("youtube")) return "video";
    if (app.includes("discord") || app.includes("message") || app.includes("mail") || app.includes("whatsapp") || app.includes("telegram")) return "chat";
    if (app.includes("steam") || app.includes("game")) return "gaming";
    if (app.includes("chrome") || app.includes("edge") || app.includes("brave") || app.includes("firefox")) return "browser";
    if (app.includes("obs")) return "recording";
    if (app.includes("photoshop") || app.includes("figma") || app.includes("blender")) return "creative";
    return "general";
  }

  isFreshContext(category, cooldownMs) {
    const now = Date.now();
    const last = Number(this.lastContextByCategory[category] || 0);
    this.lastContextByCategory[category] = now;
    return now - last > cooldownMs;
  }

  meme(memeLine, normalLine) {
    return this.features.memeLines ? memeLine : normalLine;
  }

  isNight() {
    const hour = new Date().getHours();
    return hour >= 23 || hour < 6;
  }

  randomBetween(min, max) {
    return min + Math.random() * (max - min);
  }
}

window.PetBrain = PetBrain;
