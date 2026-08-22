// ═══════════════ RELATIONSHIP ENGINE ═══════════════

(function() {
  window.RelationshipEngine = {
    /**
     * Map a numerical level to a companion relationship tier title
     * @param {number} level 
     * @returns {string}
     */
    getTier(level) {
      if (level >= 10) return "Soul Companion";
      if (level >= 8) return "Best Friend";
      if (level >= 6) return "Close Friend";
      if (level >= 4) return "Friend";
      if (level >= 2) return "Acquaintance";
      return "Stranger";
    },

    /**
     * Get XP needed for next level
     */
    getXpForLevel(level) {
      return level * 150; // simple arithmetic curve, level 1 requires 150 XP, lvl 2 300 XP etc.
    },

    /**
     * Process events to adjust relationship metrics
     */
    processEvent(eventName, payload = {}) {
      const companionId = (payload.companionId || "maxie").toLowerCase();
      if (!window.state || !window.state.shimeji) return;

      const shimejiState = window.state.shimeji;
      const relationships = shimejiState.relationships || {};
      const rel = relationships[companionId] || { level: 1, xp: 0, affection: 10, trust: 10, lastInteraction: Date.now(), milestones: [] };

      let xpAdded = 0;
      let affectionAdded = 0;
      let trustAdded = 0;

      switch(eventName) {
        case "USER_MESSAGE":
          xpAdded = 5;
          affectionAdded = 0.5;
          trustAdded = 0.5;
          break;
        case "PET_TAPPED":
        case "PET_PETTED":
          xpAdded = 10;
          affectionAdded = 2;
          trustAdded = 1;
          break;
        case "PET_DOUBLE_TAPPED":
        case "PET_DANCED":
          xpAdded = 15;
          affectionAdded = 3;
          trustAdded = 2;
          break;
        case "PET_FED":
          xpAdded = 25;
          affectionAdded = 5;
          trustAdded = 3;
          break;
        case "PET_PLAYED":
          xpAdded = 20;
          affectionAdded = 4;
          trustAdded = 1;
          break;
        case "TASK_COMPLETED":
          xpAdded = 40;
          affectionAdded = 3;
          trustAdded = 6;
          break;
        case "GIFT_RECEIVED":
          xpAdded = 50;
          affectionAdded = 10;
          trustAdded = 5;
          break;
      }

      // Add metrics
      rel.xp += xpAdded;
      rel.affection = Math.max(0, Math.min(100, rel.affection + affectionAdded));
      rel.trust = Math.max(0, Math.min(100, rel.trust + trustAdded));
      rel.lastInteraction = Date.now();
      rel.interactionCount = (rel.interactionCount || 0) + 1;

      // Check level-ups
      let xpNeeded = this.getXpForLevel(rel.level);
      let leveledUp = false;
      while (rel.xp >= xpNeeded && rel.level < 100) {
        rel.xp -= xpNeeded;
        rel.level++;
        leveledUp = true;
        xpNeeded = this.getXpForLevel(rel.level);
      }

      // Format updated properties
      rel.title = this.getTier(rel.level);
      relationships[companionId] = rel;
      window.state.shimeji.relationships = relationships;

      if (leveledUp) {
        console.log(`[RelationshipEngine] Leveled up! ${companionId} reached level ${rel.level}`);
        
        // Log milestone in memory
        if (window.MemoryStore && typeof window.MemoryStore.addCompanionMemory === "function") {
          window.MemoryStore.addCompanionMemory(
            "level_up", 
            `Reached Level ${rel.level} and became a ${rel.title}!`, 
            companionId
          );
        }

        // Fire local level-up event
        setTimeout(() => {
          if (window.companionEngine && typeof window.companionEngine.handleEvent === "function") {
            window.companionEngine.handleEvent("RELATIONSHIP_LEVEL_UP", { companionId, level: rel.level });
          }
        }, 100);
      } else {
        if (typeof window.saveState === "function") {
          window.saveState();
        }
      }
    }
  };
})();
