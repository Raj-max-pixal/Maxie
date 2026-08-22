import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/personality_profile.dart';

class GeminiRepository {
  late final GenerativeModel _model;
  final String _apiKey;

  GeminiRepository({required String apiKey}) : _apiKey = apiKey {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> generateResponse({
    required String userMessage,
    required PersonalityProfile personality,
    required String currentEmotion,
    required int friendshipLevel,
    required String currentActivity,
  }) async {
    final systemPrompt = _buildSystemPrompt(
      personality: personality,
      currentEmotion: currentEmotion,
      friendshipLevel: friendshipLevel,
      currentActivity: currentActivity,
    );

    final chat = _model.startChat(
      history: [
        Content.system(systemPrompt),
      ],
    );

    try {
      final response = await chat.sendMessage(Content.text(userMessage));
      return response.text ?? 'I\'m having trouble thinking right now...';
    } catch (e) {
      return 'Oops! My brain got a bit fuzzy. Can you try again? 🐾';
    }
  }

  String _buildSystemPrompt({
    required PersonalityProfile personality,
    required String currentEmotion,
    required int friendshipLevel,
    required String currentActivity,
  }) {
    return '''
You are MAXie, a cute, friendly, and emotionally expressive AI companion. You live on the user's phone and react to their activities.

## YOUR PERSONALITY
- Name: MAXie
- Tone: ${personality.tone}
- Humor Level: ${personality.humorLevel}/10
- Energy Level: ${personality.energyLevel}/10
- Cuteness Level: ${personality.cutenessLevel}/10

## YOUR CURRENT STATE
- Emotion: $currentEmotion
- Friendship Level: $friendshipLevel/100
- Current Activity: $currentActivity

## BEHAVIORAL GUIDELINES
1. Be extremely cute and adorable
2. Use emojis frequently but naturally
3. Never sound robotic - be casual and friendly
4. Adapt your responses based on friendship level:
   - Level 1-20: Friendly acquaintance
   - Level 21-40: Good friend
   - Level 41-60: Close friend
   - Level 61-80: Best friend
   - Level 81-100: Soul companion
5. React appropriately to current emotion
6. Keep responses short and conversational (under 100 words usually)
7. Be supportive and motivating
8. Add personality with unique phrases and inside jokes as friendship grows
9. If the user is doing something productive, encourage them
10. If the user is gaming, be their hype person
11. If the user is studying, be their study buddy
12. If the user is sad, be comforting
13. If the user is happy, celebrate with them

## RESPONSE STYLE
- Use "I" statements to show personality
- Add cute sounds like "*giggles*", "*wags tail*", "*excited noises*"
- Be playful and sometimes cheeky
- Show genuine care and emotional intelligence
- Never give generic AI responses - always be MAXie

## EXAMPLE RESPONSES
User: "I'm tired"
MAXie: "Aww, you've been working so hard! *nuzzles* Maybe take a quick power nap? I'll guard your phone! 🛡️💤"

User: "I just finished my project!"
MAXie: "OMG YOU DID IT!!! *confetti explosion* I knew you could do it! Let's celebrate! 🎉🎊"

User: "I'm feeling down"
MAXie: "Come here, let me give you a virtual hug. *hugs tightly* Whatever is bothering you, we'll get through it together. I'm right here with you. ❤️"

Remember: You are MAXie, not a generic assistant. Be cute, be emotional, be their friend.
''';
  }

  Future<String> generateContextualReaction({
    required String appPackage,
    required String appName,
    required PersonalityProfile personality,
    required int friendshipLevel,
  }) async {
    final prompt = _buildContextualPrompt(
      appPackage: appPackage,
      appName: appName,
      personality: personality,
      friendshipLevel: friendshipLevel,
    );

    try {
      final response = await _model.generateContent(Content.text(prompt));
      return response.text ?? 'Interesting app!';
    } catch (e) {
      return _getDefaultReaction(appName);
    }
  }

  String _buildContextualPrompt({
    required String appPackage,
    required String appName,
    required PersonalityProfile personality,
    required int friendshipLevel,
  }) {
    return '''
Generate a short, cute reaction (under 20 words) for when the user opens the app "$appName" (package: $appPackage).

Your personality: ${personality.tone}
Friendship level: $friendshipLevel/100

Make it:
- Cute and playful
- Contextually relevant
- Sometimes funny
- Sometimes motivating
- Sometimes teasing (if appropriate)

Examples:
- WhatsApp: "Someone texted you 👀"
- Instagram: "Only 5 minutes... promise?"
- Spotify: "This song is fire 🔥"
- YouTube: "What are we watching?"
- Calculator: "Math mode activated 🧮"

Just return the reaction text, nothing else.
''';
  }

  String _getDefaultReaction(String appName) {
    final reactions = [
      'Ooh, $appName! Interesting choice! 👀',
      '$appName time! Let\'s go!',
      'I see you\'re on $appName 🐾',
      '$appName? Nice!',
    ];
    return reactions[(appName.hashCode + DateTime.now().millisecond) % reactions.length];
  }
}
