// ═══════════════ MOOD ENGINE ═══════════════

(function() {
  window.MoodEngine = {
    /**
     * Map events to deterministic mood changes
     * @param {string} eventName 
     * @param {Object} payload 
     */
    processEvent(eventName, payload = {}) {
      const companionId = (payload.companionId || "maxie").toLowerCase();
      if (!window.state || !window.state.shimeji) return;

      const moods = window.state.shimeji.moods || {};
      const current = moods[companionId] || { mood: "happy", intensity: 1.0, cause: "SYSTEM", timestamp: Date.now(), duration: 60000 };

      let nextMood = current.mood;
      let nextIntensity = current.intensity;
      let nextCause = eventName;

      switch(eventName) {
        case "APP_OPENED":
          nextMood = companionId === "kuro" ? "calm" : "happy";
          nextIntensity = 0.8;
          break;
        case "USER_MESSAGE":
          // Slightly increases curiosity/calmness depending on the pet
          if (current.mood === "lonely") {
            nextMood = "happy";
            nextIntensity = 0.7;
          } else {
            nextMood = companionId === "nova" ? "curious" : (companionId === "kuro" ? "calm" : "playful");
            nextIntensity = 0.6;
          }
          break;
        case "PET_TAPPED":
        case "PET_PETTED":
          nextMood = "happy";
          nextIntensity = 0.95;
          nextCause = "Tapped by user";
          // Trigger animation
          this.triggerShimejiAnimation(companionId, "happy");
          break;
        case "PET_DOUBLE_TAPPED":
        case "PET_DANCED":
          nextMood = "excited";
          nextIntensity = 1.0;
          nextCause = "Dancing";
          this.triggerShimejiAnimation(companionId, "dance");
          break;
        case "PET_DRAGGED":
          nextMood = "curious";
          nextIntensity = 0.8;
          nextCause = "Being carried";
          break;
        case "PET_THROWN":
          nextMood = companionId === "kuro" ? "angry" : "playful";
          nextIntensity = 0.9;
          nextCause = "Thrown!";
          this.triggerShimejiAnimation(companionId, companionId === "kuro" ? "angry" : "jump");
          break;
        case "PET_FED":
          nextMood = "happy";
          nextIntensity = 1.0;
          nextCause = "Fed tasty treat";
          this.triggerShimejiAnimation(companionId, "eat");
          break;
        case "PET_PLAYED":
          nextMood = "playful";
          nextIntensity = 0.9;
          nextCause = "Playing games";
          this.triggerShimejiAnimation(companionId, "run");
          break;
        case "PET_SLEPT":
          nextMood = "sleepy";
          nextIntensity = 0.95;
          nextCause = "Going to bed";
          this.triggerShimejiAnimation(companionId, "sleep");
          break;
        case "TASK_COMPLETED":
          nextMood = "proud";
          nextIntensity = 1.0;
          nextCause = "Completed task: " + (payload.taskTitle || "something awesome");
          this.triggerShimejiAnimation(companionId, "celebrate");
          break;
        case "TASK_CREATED":
          nextMood = "curious";
          nextIntensity = 0.7;
          nextCause = "New task created";
          break;
        case "USER_IDLE":
          nextMood = "lonely";
          nextIntensity = 0.55;
          nextCause = "User has been idle";
          this.triggerShimejiAnimation(companionId, "sit");
          break;
        case "CODING_DETECTED":
          nextMood = "curious";
          nextIntensity = 0.85;
          nextCause = "Developer hard at work";
          this.triggerShimejiAnimation(companionId, "thinking");
          break;
        case "MUSIC_STARTED":
          nextMood = "playful";
          nextIntensity = 0.9;
          nextCause = "Grooving to music";
          this.triggerShimejiAnimation(companionId, "dance");
          break;
        case "MUSIC_STOPPED":
          nextMood = "calm";
          nextIntensity = 0.6;
          nextCause = "Music paused";
          break;
        case "LATE_NIGHT":
          nextMood = "sleepy";
          nextIntensity = 0.9;
          nextCause = "Very late night";
          this.triggerShimejiAnimation(companionId, "yawn");
          break;
        case "COMPANION_UNLOCKED":
          nextMood = "excited";
          nextIntensity = 1.0;
          nextCause = "Unlocked a new companion!";
          this.triggerShimejiAnimation(companionId, "celebrate");
          break;
        case "GIFT_RECEIVED":
          nextMood = "happy";
          nextIntensity = 1.0;
          nextCause = "Received a gift";
          this.triggerShimejiAnimation(companionId, "excited");
          break;
        case "RELATIONSHIP_LEVEL_UP":
          nextMood = "proud";
          nextIntensity = 1.0;
          nextCause = "Relationship leveled up!";
          this.triggerShimejiAnimation(companionId, "celebrate");
          break;
      }

      // Save updated mood
      moods[companionId] = {
        mood: nextMood,
        intensity: Math.max(0, Math.min(1.0, nextIntensity)),
        cause: nextCause,
        timestamp: Date.now(),
        duration: 120000 // default duration of 2 mins before decaying
      };
      
      window.state.shimeji.moods = moods;
      
      // Save state to local storage
      if (typeof window.saveState === "function") {
        window.saveState();
      }
    },

    /**
     * Trigger animation on active pets
     */
    triggerShimejiAnimation(companionId, animationName) {
      // 1. Trigger in-app pets
      if (window.state && window.state.shimeji && window.state.shimeji.inAppEnabled && window.inAppPets) {
        window.inAppPets.forEach(p => {
          if (p.id === companionId) {
            p.setAnimation(animationName);
          }
        });
      }

      // 2. Trigger overlay pets via temporary state synchronization action
      if (window.state && window.state.shimeji && window.state.shimeji.enabled) {
        window.state.shimeji.action = {
          name: animationName,
          companionId: companionId,
          timestamp: Date.now()
        };
        if (typeof window.saveState === "function") {
          window.saveState();
        }
        if (typeof window.syncOverlayState === "function") {
          window.syncOverlayState();
        }
      }
    }
  };
})();
