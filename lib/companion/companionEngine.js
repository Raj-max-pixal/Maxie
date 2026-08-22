// ═══════════════ COMPANION ENGINE ═══════════════

(function() {
  class CompanionEngine {
    constructor() {
      this.eventListeners = [];
    }

    /**
     * Dispatch a companion lifecycle event
     * @param {string} eventName 
     * @param {Object} payload 
     */
    handleEvent(eventName, payload = {}) {
      console.log(`[CompanionEngine] Event Dispatched: ${eventName}`, payload);

      // Default the companionId to active companion if missing
      if (!payload.companionId && window.state && window.state.personality) {
        payload.companionId = String(window.state.personality).toLowerCase();
      }

      // 1. Process Event through Mood Engine
      if (window.MoodEngine && typeof window.MoodEngine.processEvent === "function") {
        window.MoodEngine.processEvent(eventName, payload);
      }

      // 2. Process Event through Relationship Engine
      if (window.RelationshipEngine && typeof window.RelationshipEngine.processEvent === "function") {
        window.RelationshipEngine.processEvent(eventName, payload);
      }

      // 3. Process Event through Reaction Engine (Contextual Reactions)
      if (window.ReactionEngine && typeof window.ReactionEngine.processEvent === "function") {
        window.ReactionEngine.processEvent(eventName, payload);
      }

      // Execute custom listener callbacks
      this.eventListeners.forEach(listener => {
        try {
          listener(eventName, payload);
        } catch(e) {
          console.error("[CompanionEngine] Listener error:", e);
        }
      });

      // Notify UI of State Change
      if (typeof window.render === "function") {
        window.render();
      }
    }

    /**
     * Register a callback listener for companion events
     * @param {Function} callback 
     */
    addEventListener(callback) {
      this.eventListeners.push(callback);
    }

    /**
     * Get full consolidated stats for a specific companion
     * @param {string} id 
     */
    getCompanionState(id) {
      if (!window.state || !window.state.shimeji) return null;
      
      const shimejiState = window.state.shimeji;
      const relationships = shimejiState.relationships || {};
      const moods = shimejiState.moods || {};

      return {
        id,
        relationship: relationships[id] || { level: 1, xp: 0, affection: 10, trust: 10, milestones: [] },
        mood: moods[id] || { mood: "happy", intensity: 1.0, cause: "SYSTEM", timestamp: Date.now() }
      };
    }

    /**
     * Generate an AI response for a message
     * @param {string} userMessage 
     * @param {string} companionId 
     * @returns {Promise<string>}
     */
    async generateResponse(userMessage, companionId) {
      companionId = companionId.toLowerCase();
      console.log(`[CompanionEngine] Generating response for: ${companionId}`);
      
      // Dispatch message event
      this.handleEvent("USER_MESSAGE", { companionId, message: userMessage });

      // Add message to short-term memory
      if (window.MemoryStore && typeof window.MemoryStore.addMessage === "function") {
        window.MemoryStore.addMessage("user", userMessage, companionId);
      }

      // Generate response using router
      let responseText = "";
      if (window.AiRouter && typeof window.AiRouter.generate === "function") {
        responseText = await window.AiRouter.generate(userMessage, companionId);
      } else {
        responseText = "I am currently loading my thoughts... Let's talk in a bit!";
      }

      // Add response to memory
      if (window.MemoryStore && typeof window.MemoryStore.addMessage === "function") {
        window.MemoryStore.addMessage("bot", responseText, companionId);
        
        // Evaluate if message contains important long-term facts
        if (typeof window.MemoryStore.evaluateAndStoreLongTerm === "function") {
          window.MemoryStore.evaluateAndStoreLongTerm(userMessage, responseText, companionId);
        }
      }

      // Play synthesized audio response if TTS is active
      if (window.TtsSynthesis && typeof window.TtsSynthesis.speak === "function") {
        window.TtsSynthesis.speak(responseText);
      }

      // Dispatch response event
      this.handleEvent("AI_RESPONSE", { companionId, response: responseText });

      return responseText;
    }

    /**
     * Trigger a quick-action activity (Feed, Pet, Play, etc.)
     * @param {string} id 
     * @param {string} activityName 
     */
    performActivity(id, activityName) {
      console.log(`[CompanionEngine] Performing activity: ${activityName} on ${id}`);
      if (window.ActivityEngine && typeof window.ActivityEngine.run === "function") {
        window.ActivityEngine.run(id, activityName);
      }
    }
  }

  // Bind to global window scope
  window.CompanionEngineClass = CompanionEngine;
  window.companionEngine = new CompanionEngine();
})();
