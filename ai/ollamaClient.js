async function chatWithOllama(config, messages) {
  const endpoint = config.endpoint || "http://localhost:11434";
  const response = await fetch(`${endpoint.replace(/\/$/, "")}/api/chat`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model: config.model || "llama3.2",
      messages,
      stream: false
    })
  });

  if (!response.ok) throw new Error(`Ollama error ${response.status}`);
  const data = await response.json();
  return data.message?.content || "";
}

module.exports = { chatWithOllama };
