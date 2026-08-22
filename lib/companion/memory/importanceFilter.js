// ═══════════════ IMPORTANCE FILTER ═══════════════

(function() {
  window.ImportanceFilter = {
    /**
     * Evaluate if a message pair contains long-term valuable facts
     * @param {string} userMsg 
     * @param {string} botMsg 
     * @returns {Object|null}
     */
    evaluate(userMsg, botMsg) {
      const text = String(userMsg).toLowerCase().trim();
      
      // Heuristic rules for name capture
      let match = text.match(/my name is\s+([a-zA-Z0-9\s]+)/i) || text.match(/call me\s+([a-zA-Z0-9\s]+)/i);
      if (match && match[1]) {
        return {
          type: "important",
          content: `User's name is ${match[1].trim()}`,
          importance: 5
        };
      }

      // Heuristic rules for favorites
      match = text.match(/i like\s+([a-zA-Z0-9\s]+)/i) || text.match(/my favorite\s+([a-zA-Z0-9\s]+)/i);
      if (match && match[1]) {
        return {
          type: "favorites",
          content: `User likes/prefers: ${match[1].trim()}`,
          importance: 3
        };
      }

      // Heuristic rules for goals / tasks / projects
      match = text.match(/i want to learn\s+([a-zA-Z0-9\s]+)/i) || text.match(/working on\s+([a-zA-Z0-9\s]+)/i) || text.match(/my goal is\s+([a-zA-Z0-9\s]+)/i);
      if (match && match[1]) {
        return {
          type: "goals",
          content: `User's project/goal: ${match[1].trim()}`,
          importance: 4
        };
      }

      // Heuristic rules for general "remember this" facts
      if (text.startsWith("remember") || text.includes("don't forget")) {
        const cleanContent = userMsg.replace(/^remember\s+/i, "").replace(/^don't forget\s+/i, "");
        return {
          type: "important",
          content: `User asked to remember: ${cleanContent.trim()}`,
          importance: 4
        };
      }

      // Default: not important enough for long-term database storage
      return null;
    }
  };
})();
