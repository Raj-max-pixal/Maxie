// ═══════════════ OLLAMA PROVIDER ═══════════════

(function() {
  window.OllamaProvider = {
    /**
     * Send chat request to local Ollama API
     * @param {Object} config 
     * @param {Array} messages 
     * @returns {Promise<string>}
     */
    async chat(config, messages) {
      const endpoint = config.endpoint || "http://localhost:11434";
      const payload = messages.map(m => ({
        role: (m.role === "assistant" || m.role === "bot" || m.role === "model") ? "assistant" : "user",
        content: m.content || m.text
      }));

      const response = await fetch(`${endpoint.replace(/\/$/, "")}/api/chat`, {
        method: "POST",
        headers: { 
          "Content-Type": "application/json" 
        },
        body: JSON.stringify({
          model: config.model || "llama3.2",
          messages: payload,
          stream: false
        })
      });

      if (!response.ok) {
        throw new Error(`Ollama status code: ${response.status}`);
      }

      const data = await response.json();
      return data.message?.content || "";
    }
  };
})();
