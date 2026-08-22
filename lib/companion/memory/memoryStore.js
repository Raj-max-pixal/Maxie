// ═══════════════ MEMORY STORE ═══════════════

(function() {
  window.MemoryStore = {
    /**
     * Add a message to the short-term conversation history buffer (app state)
     */
    addMessage(role, text, companionId) {
      if (!window.state) return;
      if (!Array.isArray(window.state.chat)) window.state.chat = [];

      window.state.chat.push({
        role: role === "user" ? "user" : "bot",
        text: text,
        companionId: companionId,
        timestamp: Date.now()
      });

      // Bounded chat size limit: Cap to the last 20 messages to save local storage memory
      if (window.state.chat.length > 20) {
        window.state.chat = window.state.chat.slice(-20);
      }

      if (typeof window.saveState === "function") {
        window.saveState();
      }
    },

    /**
     * Parse message pairs to capture and store long-term facts
     */
    evaluateAndStoreLongTerm(userMsg, botMsg, companionId) {
      if (!window.state || !window.state.memory) return;
      if (!window.ImportanceFilter) return;

      const fact = window.ImportanceFilter.evaluate(userMsg, botMsg);
      if (fact) {
        // Prevent duplicate memories
        const exists = window.state.memory.some(m => 
          m.content.toLowerCase().trim() === fact.content.toLowerCase().trim()
        );

        if (!exists) {
          const memoryRecord = {
            id: String(Date.now()),
            type: fact.type, // 'favorites', 'goals', 'projects', 'important'
            content: fact.content,
            importance: fact.importance,
            timestamp: Date.now(),
            companionId: companionId
          };

          window.state.memory.push(memoryRecord);
          console.log("[MemoryStore] Saved Long-Term Memory:", memoryRecord);

          if (typeof window.saveState === "function") {
            window.saveState();
          }
        }
      }
    },

    /**
     * Add a companion-specific relationship memory milestone
     */
    addCompanionMemory(type, content, companionId) {
      if (!window.state || !window.state.shimeji) return;
      
      const shimejiState = window.state.shimeji;
      const relationships = shimejiState.relationships || {};
      const rel = relationships[companionId];
      if (!rel) return;

      const milestoneRecord = {
        id: String(Date.now()),
        type: type,
        content: content,
        timestamp: Date.now()
      };

      if (!Array.isArray(rel.milestones)) {
        rel.milestones = [];
      }
      
      rel.milestones.push(milestoneRecord);
      
      // Cap milestones to 15 records
      if (rel.milestones.length > 15) {
        rel.milestones.shift();
      }

      // Also append to global memory log as type 'milestone'
      if (!Array.isArray(window.state.memory)) {
        window.state.memory = [];
      }

      window.state.memory.push({
        id: milestoneRecord.id,
        type: "milestone",
        content: `[${companionId}] ${content}`,
        importance: 2,
        timestamp: Date.now(),
        companionId: companionId
      });

      if (typeof window.saveState === "function") {
        window.saveState();
      }
    },

    /**
     * Retrieve relevant memory snippets for the AI prompt
     */
    getMemoriesSnippet(companionId) {
      if (!window.state || !Array.isArray(window.state.memory)) return "";

      // Fetch memories belonging to this companion or general memories
      const relevant = window.state.memory
        .filter(m => !m.companionId || m.companionId.toLowerCase() === companionId.toLowerCase())
        .slice(-5); // limit to 5 snippets for system prompt safety

      if (relevant.length === 0) return "";

      return relevant.map(m => `- ${m.content} (Recorded: ${new Date(m.timestamp).toLocaleDateString()})`).join("\n");
    }
  };
})();
