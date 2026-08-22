// ═══════════════ ACTIVITY ENGINE ═══════════════

(function() {
  window.ActivityEngine = {
    /**
     * Run an activity for a companion pet
     * @param {string} companionId 
     * @param {string} activityName 
     */
    run(companionId, activityName) {
      companionId = companionId.toLowerCase();
      if (!window.state) return;

      console.log(`[ActivityEngine] Executing ${activityName} for ${companionId}`);

      let message = "";
      let eventName = "";

      switch(activityName) {
        case "feed":
          window.state.needs.food = Math.min(100, (window.state.needs.food || 0) + 25);
          window.state.needs.energy = Math.min(100, (window.state.needs.energy || 0) + 15);
          eventName = "PET_FED";
          message = this.getFeedDialogue(companionId);
          break;

        case "pet":
          window.state.needs.fun = Math.min(100, (window.state.needs.fun || 0) + 10);
          eventName = "PET_PETTED";
          message = this.getPetDialogue(companionId);
          break;

        case "play":
          window.state.needs.fun = Math.min(100, (window.state.needs.fun || 0) + 25);
          window.state.needs.energy = Math.max(0, (window.state.needs.energy || 0) - 20);
          eventName = "PET_PLAYED";
          message = this.getPlayDialogue(companionId);
          break;

        case "dance":
          window.state.needs.fun = Math.min(100, (window.state.needs.fun || 0) + 15);
          eventName = "PET_DANCED";
          message = this.getDanceDialogue(companionId);
          break;

        case "sleep":
          window.state.needs.energy = Math.min(100, (window.state.needs.energy || 0) + 45);
          eventName = "PET_SLEPT";
          message = this.getSleepDialogue(companionId);
          break;

        case "gift":
          eventName = "GIFT_RECEIVED";
          message = this.getGiftDialogue(companionId);
          // Log milestone
          if (window.MemoryStore && typeof window.MemoryStore.addCompanionMemory === "function") {
            window.MemoryStore.addCompanionMemory("gift", "Received a lovely gift from user!", companionId);
          }
          break;

        case "training":
          eventName = "RELATIONSHIP_LEVEL_UP"; // simulates progress bump
          message = this.getTrainingDialogue(companionId);
          // Log milestone
          if (window.MemoryStore && typeof window.MemoryStore.addCompanionMemory === "function") {
            window.MemoryStore.addCompanionMemory("training", "Completed a focus training session!", companionId);
          }
          break;

        case "talk":
          eventName = "USER_MESSAGE";
          message = this.getTalkDialogue(companionId);
          break;
      }

      // Dispatch event to companion engine (which handles mood updates, animations, and saves state)
      if (window.companionEngine && typeof window.companionEngine.handleEvent === "function") {
        window.companionEngine.handleEvent(eventName, { companionId });
      }

      // Display dialogue bubble
      if (message && window.ReactionEngine && typeof window.ReactionEngine.triggerSpeechBubble === "function") {
        window.ReactionEngine.triggerSpeechBubble(companionId, message);
      }
    },

    getFeedDialogue(id) {
      const pool = {
        maxie: "Yummy! Thanks for the snack! Now my energy is refueled! 🍔",
        mimi: "Mimi loves this food! Thank you so much... purr... 🐱",
        kuro: "Not bad. Could use some fish, but I won't complain. 🐈",
        luna: "A mindful meal. Thank you, traveler. 🐰",
        nova: "SPICY SPARKLE SNACK! Power levels returning to maximum! ⚡"
      };
      return pool[id] || pool.maxie;
    },

    getPetDialogue(id) {
      const pool = {
        maxie: "Hehe, that tickles! You're the best! 🐾",
        mimi: "Purrr... Mimi feels so warm and safe with you. 🐱",
        kuro: "Fine, you may pet me. But only for three seconds. 🐈",
        luna: "A comforting touch. Let us remain calm. 🐰",
        nova: "PETTING BOOSTS MOVEMENT VELOCITY! Faster, faster! ⭐"
      };
      return pool[id] || pool.maxie;
    },

    getPlayDialogue(id) {
      const pool = {
        maxie: "Yeah! Let's chase some bugs or run around! 🐾",
        mimi: "Playing with you is so much fun! Yay! 🐱",
        kuro: "Catch me if you can. (Spoiler: you can't). 🐈",
        luna: "A playful pause. Let us enjoy the moment. 🐰",
        nova: "CRITICAL SPEED INITIATED! ZOOM ZOOM SPEED! ⭐"
      };
      return pool[id] || pool.maxie;
    },

    getDanceDialogue(id) {
      const pool = {
        maxie: "♪ Dun-dun-dun, look at my cool paws! 🐾",
        mimi: "Mimi is dancing! Do you like my steps? (｡◕ ‿ ◕｡)",
        kuro: "Fine, I will wiggle. Don't look too closely. 🐈",
        luna: "A gentle dance of peace. 🐰",
        nova: "DANCE CONTEST MODE ACTIVE! CHAOS SPIN SPARKLE! ⭐"
      };
      return pool[id] || pool.maxie;
    },

    getSleepDialogue(id) {
      const pool = {
        maxie: "Ah, recharge time! Goodnight! Zzz... 💤",
        mimi: "Mimi is curl-up and dream... (◡_◡✿) 🐱",
        kuro: "Finally, turn off the light. Zzz...",
        luna: "May you have peaceful dreams. Sleep well. 🐰",
        nova: "HYPERNATION MODE ACTIVE! Charging rockets... Zzz... 💤"
      };
      return pool[id] || pool.maxie;
    },

    getGiftDialogue(id) {
      const pool = {
        maxie: "Oh wow! Is this for me?! You are awesome! 🎁",
        mimi: "A gift?! Mimi is so touched... thank you! (｡♥‿♥｡)",
        kuro: "Hmm. Acceptable. I guess you do care. 🐈",
        luna: "A thoughtful offering. I appreciate your kindness. 🐰",
        nova: "🎁 COMPANION EXTREME GIFT BOMB! This is epic!"
      };
      return pool[id] || pool.maxie;
    },

    getTrainingDialogue(id) {
      const pool = {
        maxie: "Focus mode! Let's learn to be the best! 🐾",
        mimi: "Mimi is learning to help you better! 🐱",
        kuro: "Training? I am already perfect. 🐈",
        luna: "Focus is the path to wisdom. 🐰",
        nova: "EXPERIMENTAL TRAINING MODE! Rocket launch calibration! ⭐"
      };
      return pool[id] || pool.maxie;
    },

    getTalkDialogue(id) {
      const pool = {
        maxie: "I'm listening! What's on your mind? 🐾",
        mimi: "Tell Mimi anything! I'll always listen! 🐱",
        kuro: "Talk to me all you want. I might even listen. 🐈",
        luna: "Speak, traveler. Let us share our thoughts. 🐰",
        nova: "TALKING TIME! Tell me your wild ideas! ⭐"
      };
      return pool[id] || pool.maxie;
    }
  };
})();
