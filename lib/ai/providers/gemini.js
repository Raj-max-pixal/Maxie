// ═══════════════ GEMINI PROVIDER ═══════════════

(function() {
  window.GeminiProvider = {
    /**
     * Send chat prompt request to Gemini API
     * @param {Object} config 
     * @param {Array} messages 
     * @returns {Promise<string>}
     */
    async chat(config, messages) {
      const model = config.model || "gemini-1.5-flash";
      const key = config.apiKey || "";
      const endpoint = config.endpoint || "https://generativelanguage.googleapis.com";
      
      const payload = messages.map(m => ({
        role: (m.role === "assistant" || m.role === "bot" || m.role === "model") ? "model" : "user",
        parts: [{ text: m.content || m.text }]
      }));

      const response = await fetch(`${endpoint.replace(/\/$/, "")}/v1beta/models/${model}:generateContent?key=${key}`, {
        method: "POST",
        headers: { 
          "Content-Type": "application/json" 
        },
        body: JSON.stringify({ contents: payload })
      });

      if (!response.ok) {
        throw new Error(`Gemini status code: ${response.status}`);
      }

      const data = await response.json();
      return data.candidates?.[0]?.content?.parts?.map(part => part.text).join("") || "";
    }
  };
})();
