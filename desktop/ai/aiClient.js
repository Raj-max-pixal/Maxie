const { chatWithOllama } = require("./ollamaClient");
const { chatWithOpenAiCompatible } = require("./openAiCompatibleClient");
const { chatWithGemini } = require("./geminiClient");
const { buildSystemPrompt } = require("./personality");

function createAiClient(config) {
  return {
    async chat(messages, state) {
      const system = { role: "system", content: buildSystemPrompt(state) };
      const payload = [system, ...messages];

      if (config.provider === "gemini") return chatWithGemini(config, payload);
      if (config.provider === "openai-compatible") return chatWithOpenAiCompatible(config, payload);
      return chatWithOllama(config, payload);
    }
  };
}

module.exports = { createAiClient };
