class AiSettings {
  const AiSettings({
    this.provider = 'gemini',
    this.model = 'gemini-1.5-flash',
    this.temperature = 0.8,
    this.maxTokens = 2048,
    this.streamingEnabled = true,
    this.memoryEnabled = true,
    this.futureLocalAiEnabled = false,
  });

  final String provider;
  final String model;
  final double temperature;
  final int maxTokens;
  final bool streamingEnabled;
  final bool memoryEnabled;
  final bool futureLocalAiEnabled;
}
