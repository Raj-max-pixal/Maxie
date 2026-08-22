function toGeminiContents(messages) {
  return messages.map((message) => ({
    role: message.role === "assistant" ? "model" : "user",
    parts: [{ text: message.content }]
  }));
}

async function chatWithGemini(config, messages) {
  const model = config.model || "gemini-1.5-flash";
  const key = config.apiKey || "";
  const endpoint = config.endpoint || "https://generativelanguage.googleapis.com";
  const response = await fetch(`${endpoint.replace(/\/$/, "")}/v1beta/models/${model}:generateContent?key=${key}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ contents: toGeminiContents(messages) })
  });

  if (!response.ok) throw new Error(`Gemini API error ${response.status}`);
  const data = await response.json();
  return data.candidates?.[0]?.content?.parts?.map((part) => part.text).join("") || "";
}

module.exports = { chatWithGemini };
