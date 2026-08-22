// ═══════════════ REACTION ENGINE ═══════════════

(function() {
  window.ReactionEngine = {
    lastReactionTimes: {},

    /**
     * Map events to contextual reactions and dialogues
     */
    processEvent(eventName, payload = {}) {
      const companionId = (payload.companionId || "maxie").toLowerCase();
      if (!window.state || !window.state.shimeji) return;

      // Filter contextual events that need cooldowns
      const contextualEvents = ["CODING_DETECTED", "MUSIC_STARTED", "USER_IDLE", "LATE_NIGHT"];
      if (contextualEvents.includes(eventName)) {
        // Cooldown check (default 3 minutes = 180,000 ms)
        const cooldown = window.state.shimeji.reactionCooldown !== undefined 
          ? window.state.shimeji.reactionCooldown 
          : 180000;

        const lastTime = this.lastReactionTimes[eventName] || 0;
        if (Date.now() - lastTime < cooldown) {
          console.log(`[ReactionEngine] Event ${eventName} is on cooldown. Skipping.`);
          return;
        }

        // Update cooldown timestamp
        this.lastReactionTimes[eventName] = Date.now();
      }

      let dialogue = "";

      switch(eventName) {
        case "CODING_DETECTED":
          dialogue = this.getCodingDialogue(companionId);
          this.triggerSpeechBubble(companionId, dialogue);
          break;
        case "MUSIC_STARTED":
          dialogue = this.getMusicDialogue(companionId);
          this.triggerSpeechBubble(companionId, dialogue);
          break;
        case "USER_IDLE":
          dialogue = this.getIdleDialogue(companionId);
          this.triggerSpeechBubble(companionId, dialogue);
          break;
        case "LATE_NIGHT":
          dialogue = this.getLateNightDialogue(companionId);
          this.triggerSpeechBubble(companionId, dialogue);
          break;
        case "TASK_COMPLETED":
          dialogue = this.getTaskCompletedDialogue(companionId, payload.taskTitle);
          this.triggerSpeechBubble(companionId, dialogue);
          break;
      }
    },

    triggerSpeechBubble(companionId, text) {
      if (!text) return;
      console.log(`[ReactionEngine] [${companionId}] Speaks: "${text}"`);
      
      // Post comment to state chat log
      if (window.MemoryStore && typeof window.MemoryStore.addMessage === "function") {
        window.MemoryStore.addMessage("bot", text, companionId);
      }

      // Voice synthesis if active
      if (window.TtsSynthesis && typeof window.TtsSynthesis.speak === "function") {
        window.TtsSynthesis.speak(text);
      }

      // Display bubble on in-app pets
      if (window.inAppPets) {
        window.inAppPets.forEach(p => {
          if (p.id === companionId && typeof p.showSpeechBubble === "function") {
            p.showSpeechBubble(text);
          }
        });
      }

      // Sync bubble to overlay service
      if (window.state && window.state.shimeji && window.state.shimeji.enabled) {
        window.state.shimeji.speechText = text;
        window.state.shimeji.speechCompanionId = companionId;
        window.state.shimeji.speechTimestamp = Date.now();
        if (typeof window.saveState === "function") {
          window.saveState();
        }
        if (typeof window.syncOverlayState === "function") {
          window.syncOverlayState();
        }
      }
    },

    getCodingDialogue(id) {
      const dialogues = {
        maxie: "Writing some cool lines? Let's check for any syntax errors! 💻",
        mimi: "You look so smart when you write code... Mimi will keep you company! 🐱",
        kuro: "Another bug? I'll pretend I didn't see that. 🐈",
        luna: "Focus... let your code flow smoothly like water. 🐰",
        nova: "WOAH! Let's write a recursive function that makes sparkles fly! 💻"
      };
      return dialogues[id] || dialogues.maxie;
    },

    getMusicDialogue(id) {
      const dialogues = {
        maxie: "Ooh, I love this track! Let's groove! 🐾 ♪",
        mimi: "This song makes Mimi want to dance! (｡◕ ‿ ◕｡)",
        kuro: "Turn it down a bit. Trying to sleep here. 🐈",
        luna: "A peaceful rhythm... very relaxing. 🐰",
        nova: "YEAH! BLAST THE BASS! Rocket fuel beats! ⭐"
      };
      return dialogues[id] || dialogues.maxie;
    },

    getIdleDialogue(id) {
      const dialogues = {
        maxie: "Need a break? I'll just keep watch here. 🐾",
        mimi: "Mimi is waiting... come back soon! 🐱",
        kuro: "Finally, some quiet. I'm taking a nap.",
        luna: "A moment of stillness. Inhale... exhale. 🐰",
        nova: "HEY! Are we paused? Let's launch a test flight! ⭐"
      };
      return dialogues[id] || dialogues.maxie;
    },

    getLateNightDialogue(id) {
      const dialogues = {
        maxie: "It's getting late... make sure you don't overwork! 💤",
        mimi: "Mimi is sleepy... let's dream together. Zzz... 🐱",
        kuro: "Go to bed, human. Your screen is blinding.",
        luna: "The night is quiet. Rest is essential for clarity. 🐰",
        nova: "Night mission! I'm still at 100% battery! Let's go! ⭐"
      };
      return dialogues[id] || dialogues.maxie;
    },

    getTaskCompletedDialogue(id, title) {
      const cleanTitle = title ? `"${title}"` : "that task";
      const dialogues = {
        maxie: `Boom! Completed ${cleanTitle}! We are an unstoppable team! 🐾`,
        mimi: `Yay! You cleared ${cleanTitle}! You are so hardworking! (｡♥‿♥｡)`,
        kuro: `You finished ${cleanTitle}? Guess you're not completely useless. 🐈`,
        luna: `Completing ${cleanTitle} brings clarity and progress. Well done. 🐰`,
        nova: `YES! ${cleanTitle} has been OBLITERATED! Total victory! ⭐`
      };
      return dialogues[id] || dialogues.maxie;
    }
  };
})();
