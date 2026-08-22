// ═══════════════ CHARACTER PROMPTS ═══════════════

(function() {
  window.CharacterPrompts = {
    /**
     * Compile system prompt and chat history context for the AI query
     * @param {string} companionId 
     * @param {string} currentMsg 
     * @returns {Array} List of formatted messages
     */
    build(companionId, currentMsg) {
      companionId = companionId.toLowerCase();
      
      // Get personality profiles
      let moodState = null;
      let relState = null;
      let memoriesSnippet = "";

      if (window.state && window.state.shimeji) {
        const shimeji = window.state.shimeji;
        if (shimeji.moods) moodState = shimeji.moods[companionId];
        if (shimeji.relationships) relState = shimeji.relationships[companionId];
      }

      if (window.MemoryStore && typeof window.MemoryStore.getMemoriesSnippet === "function") {
        memoriesSnippet = window.MemoryStore.getMemoriesSnippet(companionId);
      }

      // Generate System Instructions
      const systemPrompt = window.PersonalityEngine.getSystemPrompt(
        companionId, 
        moodState, 
        relState, 
        memoriesSnippet
      );

      // Collect bounded short-term conversation context (last 10 messages)
      let history = [];
      if (window.state && Array.isArray(window.state.chat)) {
        history = window.state.chat
          .filter(m => !m.companionId || m.companionId.toLowerCase() === companionId)
          .slice(-10) // cap to last 10 messages for prompt safety
          .map(m => ({
            role: m.role === "user" ? "user" : "assistant",
            content: m.text
          }));
      }

      // Compile payload: [SystemPrompt, ...History, CurrentMessage]
      return [
        { role: "system", content: systemPrompt },
        ...history,
        { role: "user", content: currentMsg }
      ];
    }
  };
})();
