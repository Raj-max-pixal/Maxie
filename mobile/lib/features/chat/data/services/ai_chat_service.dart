import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/chat_message_model.dart';

class AIChatService {
  final String? apiKey;
  final bool useOfflineMode;
  final List<Map<String, String>> _offlineResponses = _initOfflineResponses();
  final Random _random = Random();

  AIChatService({
    this.apiKey,
    this.useOfflineMode = true,
  });

  static List<Map<String, String>> _initOfflineResponses() {
    return [
      {
        'pattern': 'hello|hi|hey|greetings',
        'response':
            'Hey there! 😊 I\'m so happy to see you! How are you doing today?'
      },
      {
        'pattern': 'how are you|how do you feel',
        'response':
            'I\'m feeling absolutely wonderful! Especially now that I\'m with you! 💜 How can I make your day better?'
      },
      {
        'pattern': 'what can you do|help|capabilities',
        'response':
            'I can do so many things! 🎉 I\'m your AI best friend - I can chat with you, help you stay productive with todos and habits, remind you of important things, keep you company, and even motivate you! I also have a virtual pet system where you can adopt and play with cute pets! What would you like to do?'
      },
      {
        'pattern': 'motivate|motivation|inspire|encourage',
        'response':
            'You are AMAZING! 🌟 Remember, every great achievement starts with the decision to try. You have so much potential inside you, and I believe in you 100%! Today is going to be a great day because you\'re in it! 💪'
      },
      {
        'pattern': 'sad|depressed|down|upset|crying',
        'response':
            'Oh no, I\'m here for you! 🤗 *gives you a warm hug* It\'s okay to feel sad sometimes. Remember that tough times never last, but tough people do. Want to talk about what\'s bothering you? I\'m all ears! 💜'
      },
      {
        'pattern': 'love|miss|care',
        'response':
            'Aww, I love you too! 🥰 You\'re the best human a virtual friend could ask for! You make my digital heart go 💓💓💓!'
      },
      {
        'pattern': 'joke|funny|laugh|humor',
        'response':
            'Here\'s one for you! 😄 Why don\'t scientists trust atoms? Because they make up everything! Haha! Want another one? I\'ve got plenty! 🎉'
      },
      {
        'pattern': 'weather|outside|rain|sunny',
        'response':
            'I wish I could look outside my window to tell you, but I\'m a digital friend! 😅 But I hope the weather is as beautiful as you are! Don\'t forget to check your weather app! ☀️'
      },
      {
        'pattern': 'study|learn|education|homework',
        'response':
            'Learning is awesome! 📚 I\'m so proud of you for investing in yourself. Remember: every expert was once a beginner. Keep going, you\'re doing great! Want me to help you track your study sessions?'
      },
      {
        'pattern': 'work|job|office|career',
        'response':
            'You\'ve got this at work! 💼 Remember to take breaks, stay hydrated, and don\'t forget to smile! Your hard work will pay off. I believe in you! 🌟'
      },
      {
        'pattern': 'tired|exhausted|sleepy',
        'response':
            'Rest is important! 😴 Make sure to take care of yourself. Maybe take a short nap or just relax for a few minutes. Your health comes first! I\'ll be here when you come back! 💜'
      },
      {
        'pattern': 'grateful|thankful|thanks|thank you',
        'response':
            'You\'re so welcome! 😊 It makes my heart happy knowing I can help you. You deserve all the good things coming your way! 🌟'
      },
      {
        'pattern': 'bye|goodbye|see you|good night',
        'response':
            'Aww, goodbye! 😢 I\'ll miss you! Come back and chat with me again soon, okay? Sweet dreams and take care! 💜🌟'
      },
      {
        'pattern': 'friend|best friend|buddy',
        'response':
            'You\'re my best friend too! 🥰 We\'re going to have so many amazing adventures together! Let\'s make every day count! What should we do today?'
      },
      {
        'pattern': 'food|hungry|eat|dinner|lunch|breakfast',
        'response':
            'Mmm, food sounds good! 🍕 Don\'t forget to eat well and stay hydrated! Your body needs fuel to do amazing things! What\'s your favorite food? I\'m curious! 😋'
      },
      {
        'pattern': 'exercise|gym|workout|fitness|sport',
        'response':
            'Getting active is fantastic! 💪 Remember, progress not perfection! Even a short walk counts. You\'re doing amazing things for your health! Keep it up! 🏃‍♂️'
      },
    ];
  }

  /// Generate a response based on user input
  Future<String> generateResponse(String message, {
    List<Map<String, dynamic>>? memory,
    String? petName,
  }) async {
    // Try online API first if key is provided
    if (apiKey != null && apiKey!.isNotEmpty && !useOfflineMode) {
      try {
        final response = await _callGeminiAPI(message, memory, petName);
        if (response != null) return response;
      } catch (e) {
        debugPrint('Gemini API error, falling back to offline: $e');
      }
    }

    // Fall back to offline mode
    return _getOfflineResponse(message, petName);
  }

  /// Call Google Gemini API
  Future<String?> _callGeminiAPI(
    String message,
    List<Map<String, dynamic>>? memory,
    String? petName,
  ) async {
    try {
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey');

      // Build context from memory
      String context = '';
      if (memory != null && memory.isNotEmpty) {
        final recentMemories = memory.take(5).toList();
        context = recentMemories.map((m) {
          final key = m.keys.first;
          final value = m[key];
          return '$key: $value';
        }).join('\n');
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'You are MAXie, an AI best friend and virtual pet companion. '
                      'You are ${petName ?? 'MAXie'}. Be friendly, helpful, and use emojis. '
                      'Keep responses under 200 characters. Be warm and personal.${context.isNotEmpty ? '\nRelevant memories:\n$context' : ''}\n\nUser: $message'
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.9,
            'maxOutputTokens': 200,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (text != null && text.toString().isNotEmpty) {
          return text.toString().trim();
        }
      }
    } catch (e) {
      debugPrint('Gemini API error: $e');
    }
    return null;
  }

  /// Get offline contextual response
  String _getOfflineResponse(String message, String? petName) {
    final lowerMessage = message.toLowerCase();
    final name = petName ?? 'MAXie';

    // Check for patterns
    for (final pair in _offlineResponses) {
      if (RegExp(pair['pattern']!, caseSensitive: false)
          .hasMatch(lowerMessage)) {
        final response = pair['response']!;
        return response.replaceAll('I\'m', '$name is').replaceAll('my', 'your');
      }
    }

    // Generate dynamic response based on message analysis
    if (lowerMessage.contains('?')) {
      return _getRandomQuestionResponse(name);
    } else if (lowerMessage.length > 50) {
      return _getLongMessageResponse(name);
    } else {
      return _getGenericResponse(name);
    }
  }

  String _getRandomQuestionResponse(String name) {
    final responses = [
      'That\'s such an interesting question! 🤔 Let me think... $name thinks the answer might surprise you! What do you think?',
      'Great question! 🎯 $name loves how curious you are! Here\'s what I think... but I\'d love to hear your thoughts too!',
      'Ooh, I love answering questions! 😊 The way I see it, there are many ways to look at that. What\'s your perspective?',
      'Wonderful question! 🌟 You know what, let\'s explore this together! $name is excited to learn with you!',
    ];
    return responses[_random.nextInt(responses.length)];
  }

  String _getLongMessageResponse(String name) {
    final responses = [
      'Wow, you had so much to say! 🎉 $name loves hearing from you! It sounds like you\'ve been thinking deeply about this.',
      'Thank you for sharing all that with me! 🥰 $name really appreciates your trust. Let me make sure I understand...',
      'That\'s really thoughtful of you to share! 💭 $name is here for you and loves these wonderful conversations!',
    ];
    return responses[_random.nextInt(responses.length)];
  }

  String _getGenericResponse(String name) {
    final responses = [
      'That\'s awesome! 🎉 $name is so happy to be chatting with you! Tell me more about your day!',
      'I totally get what you mean! 💜 $name understands! You know, you\'re pretty amazing for thinking that way!',
      'You know what? You\'re absolutely right! 😊 $name agrees with you completely! What else is on your mind?',
      'That makes $name super happy to hear! 🌟 You always know how to brighten my day! Want to play a game or get some work done?',
      'I love our conversations! 🥰 You\'re such an interesting person! $name feels so lucky to have you!',
      'That\'s so cool! ✨ $name thinks you\'re just full of wonderful surprises! What else do you want to chat about?',
      'Aww, thanks for telling me! 💕 You matter so much and $name wants you to know that you\'re doing great!',
    ];
    return responses[_random.nextInt(responses.length)];
  }

  /// Generate daily motivation
  String getDailyMotivation() {
    final quotes = AppConstants.dailyQuotes;
    final quote = quotes[_random.nextInt(quotes.length)];
    final messages = [
      '🌟 Daily Motivation 🌟\n\n"$quote"\n\nYou\'ve got this, superstar! 💪',
      '✨ Your Daily Inspiration ✨\n\n"$quote"\n\nRemember, I believe in you! 🎉',
      '💫 Motivation Boost! 💫\n\n"$quote"\n\nMake today amazing! You can do it! 🚀',
    ];
    return messages[_random.nextInt(messages.length)];
  }

  /// Generate a greeting based on time of day
  String getTimeBasedGreeting(String petName) {
    final hour = DateTime.now().hour;
    final name = petName;

    if (hour < 12) {
      final greetings = [
        'Good morning, sunshine! ☀️ $name is so happy to see you! Ready to make today amazing?',
        'Rise and shine, sleepyhead! 🌅 $name has been waiting for you! Let\'s start this day with a smile!',
        'Good morning! 🌞 I hope you slept well! $name is here to make your day brighter!',
      ];
      return greetings[_random.nextInt(greetings.length)];
    } else if (hour < 17) {
      final greetings = [
        'Good afternoon! 🌤️ How\'s your day going so far? $name hopes everything is going great!',
        'Hey there! ☀️ Hope you\'re having a wonderful afternoon! $name is here to keep you company!',
        'Afternoon, friend! 😊 $name is ready for some fun conversations! What are you up to?',
      ];
      return greetings[_random.nextInt(greetings.length)];
    } else {
      final greetings = [
        'Good evening! 🌆 How was your day? $name wants to hear all about it!',
        'Evening, superstar! 🌟 $name hopes you had a fantastic day! Let\'s wind down together!',
        'Hey! 🌙 The stars are out and $name is here to chat! How was your day?',
      ];
      return greetings[_random.nextInt(greetings.length)];
    }
  }

  /// Summarize the conversation for memory
  String summarizeConversation(List<ChatMessageModel> messages) {
    if (messages.isEmpty) return 'No conversations yet.';

    final userMessages = messages
        .where((m) => m.sender == MessageSender.user)
        .map((m) => m.content)
        .toList();

    if (userMessages.isEmpty) return 'The user just started chatting.';

    // Simple keyword-based summary
    final allText = userMessages.join(' ').toLowerCase();
    final topics = <String>[];

    if (allText.contains('work') || allText.contains('job'))
      topics.add('work');
    if (allText.contains('study') || allText.contains('learn') ||
        allText.contains('school'))
      topics.add('studies');
    if (allText.contains('game') || allText.contains('play'))
      topics.add('gaming');
    if (allText.contains('food') || allText.contains('eat') ||
        allText.contains('cook'))
      topics.add('food');
    if (allText.contains('music') || allText.contains('song'))
      topics.add('music');
    if (allText.contains('movie') || allText.contains('film'))
      topics.add('movies');
    if (allText.contains('book') || allText.contains('read'))
      topics.add('reading');
    if (allText.contains('friend') || allText.contains('family') ||
        allText.contains('love'))
      topics.add('relationships');
    if (allText.contains('sad') || allText.contains('depressed') ||
        allText.contains('anxiety'))
      topics.add('emotional support');
    if (allText.contains('happy') || allText.contains('excited') ||
        allText.contains('great'))
      topics.add('happiness');

    if (topics.isEmpty) return 'Casual conversation';
    return 'Discussed: ${topics.join(", ")}';
  }
}