async function chatWithOpenAiCompatible(config, messages) {
  const endpoint = config.endpoint || "https://api.openai.com/v1";
  const response = await fetch(`${endpoint.replace(/\/$/, "")}/chat/completions`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${config.apiKey || ""}`
    },
    body: JSON.stringify({
      model: config.model || "gpt-4o-mini",
      messages
    })
  });

  if (!response.ok) throw new Error(`OpenAI-compatible API error ${response.status}`);
  const data = await response.json();
  return data.choices?.[0]?.message?.content || "";
}

module.exports = { chatWithOpenAiCompatible };
