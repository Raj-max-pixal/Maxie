class AiResponse {
  const AiResponse({
    required this.text,
    this.model = 'local-companion',
    this.finishReason,
  });

  final String text;
  final String model;
  final String? finishReason;
}
