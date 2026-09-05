import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:maxie_mobile/features/ai_chat/data/ai_provider.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/ai_response.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/chat_message.dart';

class GeminiProvider implements AiProvider {
  GeminiProvider({http.Client? client}) : _client = client ?? http.Client();

  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _model = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-1.5-flash',
  );

  final http.Client _client;

  @override
  String get id => 'gemini';

  @override
  bool get isConfigured => _apiKey.isNotEmpty;

  @override
  Future<AiResponse> complete(List<ChatMessage> messages) async {
    if (!isConfigured) {
      return LocalCompanionProvider().complete(messages);
    }

    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$_model:generateContent',
      {'key': _apiKey},
    );

    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': messages
                .where((message) => message.role != ChatRole.system)
                .map(
                  (message) => {
                    'role': message.role == ChatRole.user ? 'user' : 'model',
                    'parts': [
                      {'text': message.content},
                    ],
                  },
                )
                .toList(),
            'generationConfig': {
              'temperature': 0.8,
              'maxOutputTokens': 2048,
            },
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const AiProviderException('Invalid Gemini API key.');
    }
    if (response.statusCode == 429) {
      throw const AiProviderException('Gemini rate limit reached. Try again soon.');
    }
    if (response.statusCode >= 400) {
      throw AiProviderException('Gemini request failed: ${response.statusCode}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = payload['candidates'] as List<dynamic>? ?? [];
    final content = candidates.isEmpty
        ? null
        : candidates.first as Map<String, dynamic>;
    final parts = (content?['content'] as Map<String, dynamic>?)?['parts']
            as List<dynamic>? ??
        [];
    final text = parts
        .map((part) => (part as Map<String, dynamic>)['text'] as String? ?? '')
        .join()
        .trim();

    return AiResponse(
      text: text.isEmpty ? 'I heard you, but I need a clearer prompt.' : text,
      model: _model,
      finishReason: content?['finishReason'] as String?,
    );
  }
}

class LocalCompanionProvider implements AiProvider {
  @override
  String get id => 'local-companion';

  @override
  bool get isConfigured => true;

  @override
  Future<AiResponse> complete(List<ChatMessage> messages) async {
    final prompt = messages.lastWhere((message) => message.isUser).content;
    final text = '''
I am running in local companion mode because no Gemini API key is configured.

Here is how I can help with this:

- I understood: "$prompt"
- I can turn this into a plan, checklist, explanation, or study note.
- When you run with `--dart-define=GEMINI_API_KEY=your_key`, I will use Gemini for real responses.

```dart
final maxie = Companion.ready(mode: CompanionMode.supportive);
```
''';
    return AiResponse(text: text);
  }
}

class AiProviderException implements Exception {
  const AiProviderException(this.message);

  final String message;

  @override
  String toString() => message;
}
