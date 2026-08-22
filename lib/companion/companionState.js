// ═══════════════ COMPANION STATE MANAGER ═══════════════

(function() {
  window.CompanionState = {
    getDefaults() {
      return {
        memory: [],
        relationships: {
          maxie: { level: 1, xp: 0, affection: 10, trust: 10, lastInteraction: Date.now(), milestones: [] },
          mimi: { level: 1, xp: 0, affection: 10, trust: 10, lastInteraction: Date.now(), milestones: [] },
          kuro: { level: 1, xp: 0, affection: 10, trust: 10, lastInteraction: Date.now(), milestones: [] },
          luna: { level: 1, xp: 0, affection: 10, trust: 10, lastInteraction: Date.now(), milestones: [] },
          nova: { level: 1, xp: 0, affection: 10, trust: 10, lastInteraction: Date.now(), milestones: [] }
        },
        moods: {
          maxie: { mood: "happy", intensity: 1.0, cause: "APP_OPENED", timestamp: Date.now(), duration: 60000 },
          mimi: { mood: "happy", intensity: 1.0, cause: "APP_OPENED", timestamp: Date.now(), duration: 60000 },
          kuro: { mood: "calm", intensity: 1.0, cause: "APP_OPENED", timestamp: Date.now(), duration: 60000 },
          luna: { mood: "sleepy", intensity: 1.0, cause: "APP_OPENED", timestamp: Date.now(), duration: 60000 },
          nova: { mood: "curious", intensity: 1.0, cause: "APP_OPENED", timestamp: Date.now(), duration: 60000 }
        },
        voice: {
          speechEnabled: false,
          ttsEnabled: false
        }
      };
    },

    validateAndSanitize(state) {
      if (!state) state = {};
      if (!Array.isArray(state.memory)) state.memory = [];
      if (!state.relationships || typeof state.relationships !== "object") state.relationships = {};
      if (!state.moods || typeof state.moods !== "object") state.moods = {};
      if (!state.voice || typeof state.voice !== "object") state.voice = { speechEnabled: false, ttsEnabled: false };

      const ids = ["maxie", "mimi", "kuro", "luna", "nova"];
      ids.forEach(id => {
        if (!state.relationships[id] || typeof state.relationships[id] !== "object") {
          state.relationships[id] = { level: 1, xp: 0, affection: 10, trust: 10, lastInteraction: Date.now(), milestones: [] };
        } else {
          // Fill missing properties
          const r = state.relationships[id];
          if (r.level === undefined) r.level = 1;
          if (r.xp === undefined) r.xp = 0;
          if (r.affection === undefined) r.affection = 10;
          if (r.trust === undefined) r.trust = 10;
          if (r.lastInteraction === undefined) r.lastInteraction = Date.now();
          if (!Array.isArray(r.milestones)) r.milestones = [];
        }

        if (!state.moods[id] || typeof state.moods[id] !== "object") {
          const defaultMood = id === "kuro" ? "calm" : (id === "luna" ? "sleepy" : (id === "nova" ? "curious" : "happy"));
          state.moods[id] = { mood: defaultMood, intensity: 1.0, cause: "SYSTEM", timestamp: Date.now(), duration: 60000 };
        } else {
          const m = state.moods[id];
          if (!m.mood) m.mood = "happy";
          if (m.intensity === undefined) m.intensity = 1.0;
          if (!m.cause) m.cause = "SYSTEM";
          if (m.timestamp === undefined) m.timestamp = Date.now();
          if (m.duration === undefined) m.duration = 60000;
        }
      });

      return state;
    }
  };
})();
