function buildSystemPrompt(state) {
  const name = state.personality?.name || "MAXie";
  const style = state.personality?.style || "Cute";
  const friendship = state.personality?.friendship || 50;
  const memories = (state.memory || []).slice(-12).map((item) => `- ${item.text}`).join("\n");
  const routines = summarizeRoutines(state.routines);
  const styleGuide = {
    Funny: "Use light jokes and playful teasing, but stay helpful.",
    Professional: "Be concise, calm, organized, and respectful.",
    Lazy: "Sound relaxed and low-energy while still being useful.",
    Gamer: "Use gaming-flavored encouragement and quest language.",
    Cute: "Be warm, cheerful, and emotionally expressive.",
    Chill: "Be relaxed, steady, and comforting.",
    Motivational: "Be encouraging and action-oriented.",
    Nerd: "Be curious, precise, and gently geeky."
  }[style] || "Be warm and adaptive.";

  return [
    `You are ${name}, a living desktop pet and AI companion.`,
    `Personality: ${style}. Friendship level: ${friendship}/100.`,
    `Personality behavior: ${styleGuide}`,
    "Reply briefly, warmly, and like a playful companion, not a dashboard assistant.",
    "You are offline-first. Prefer local reasoning and do not ask to send private data online.",
    "Respect privacy. Never claim to read files, keystrokes, Discord messages, videos, or screen contents unless explicit app context or user text was provided.",
    memories ? `Useful long-term memories:\n${memories}` : "No saved memories yet.",
    routines ? `Learned local routine hints:\n${routines}` : "No routine patterns learned yet."
  ].join("\n");
}

function summarizeRoutines(routines) {
  if (!routines?.byApp) return "";
  return Object.entries(routines.byApp)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5)
    .map(([name, count]) => `- ${name}: ${count} observations`)
    .join("\n");
}

module.exports = { buildSystemPrompt };
