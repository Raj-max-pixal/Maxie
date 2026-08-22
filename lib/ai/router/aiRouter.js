// ═══════════════ AI ROUTER ═══════════════

(function() {
  window.AiRouter = {
    /**
     * Generate response with cascading fallback routing
     * @param {string} userMsg 
     * @param {string} companionId 
     * @returns {Promise<string>}
     */
    async generate(userMsg, companionId) {
      companionId = companionId.toLowerCase();
      
      // Build compiled messages payload
      let messages = [];
      if (window.CharacterPrompts && typeof window.CharacterPrompts.build === "function") {
        messages = window.CharacterPrompts.build(companionId, userMsg);
      } else {
        messages = [{ role: "user", content: userMsg }];
      }

      // Check user AI configuration defaults
      const config = (window.state && window.state.ai) || { provider: "offline" };
      const provider = config.provider || "offline";

      console.log(`[AiRouter] Selected Provider: ${provider}`);

      // Case 1: Try Gemini
      if (provider === "gemini") {
        try {
          if (!config.apiKey) {
            throw new Error("Gemini API key is empty");
          }
          if (window.GeminiProvider) {
            return await window.GeminiProvider.chat(config, messages);
          }
        } catch (e) {
          console.warn("[AiRouter] Gemini failed, falling back to Ollama.", e);
        }
      }

      // Case 2: Try Ollama (either as primary or fallback)
      if (provider === "ollama" || provider === "gemini") {
        try {
          if (window.OllamaProvider) {
            return await window.OllamaProvider.chat(config, messages);
          }
        } catch (e) {
          console.warn("[AiRouter] Ollama failed, falling back to Offline AI.", e);
        }
      }

      // Case 3: Offline Fallback (always works)
      console.log("[AiRouter] Using Offline Fallback");
      if (window.OfflineAi) {
        return window.OfflineAi.generate(userMsg, companionId);
      }

      return "I'm right here with you!";
    }
  };
})();
