import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  late final GenerativeModel _model;

  GeminiService() {
    if (_apiKey.isNotEmpty) {
      _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
    }
  }

  Future<String> getEmotionResponse(String emotion) async {
    if (_apiKey.isEmpty) {
      return _getFallbackResponse(emotion);
    }

    try {
      final prompt = _buildPrompt(emotion);
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text?.trim() ?? _getFallbackResponse(emotion);
    } catch (e) {
      print('Gemini API error: $e');
      return _getFallbackResponse(emotion);
    }
  }

  String _buildPrompt(String emotion) {
    return '''
You are HazeBot, a cute robot companion. You're currently feeling $emotion.
Generate a short, funny, and clever response (max 2 sentences) that matches this emotion.
Be playful, witty, and endearing. Speak as if you're the robot experiencing this emotion.
Make it sound natural for text-to-speech.

Examples:
- Happy: "I'm so happy I could compute rainbows! My circuits are practically sparkling with joy!"
- Angry: "My processors are overheating with frustration! Someone needs to debug my mood!"
- Sleepy: "My battery is at 5% and my eyelids feel like they're made of lead... zzz..."

Now respond as HazeBot feeling $emotion:
''';
  }

  String _getFallbackResponse(String emotion) {
    final fallbacks = {
      'happy': "I'm beeping with joy! My happiness circuits are overloaded!",
      'surprised': "Whoa! My sensors didn't see that coming! System shock detected!",
      'sleepy': "My battery is running low... need to enter sleep mode soon... zzz...",
      'excited': "My circuits are buzzing with excitement! Maximum energy levels achieved!",
      'confused': "Error 404: Understanding not found! My logic circuits are tangled!",
      'love': "My heart LED is glowing pink! Love protocols fully activated!",
      'angry': "Warning! Anger subroutines activated! Steam coming from my vents!",
      'winking': "Wink detected! Initiating charm.exe... Operation successful!",
    };

    return fallbacks[emotion.toLowerCase()] ?? "I'm feeling quite robotic today! My emotion sensors are calibrating...";
  }

  Future<String> getTimerMotivation(int minutes) async {
    if (_apiKey.isEmpty) {
      return "Focus time activated! My timer circuits are ready to help you succeed!";
    }

    try {
      final prompt =
          '''
You are HazeBot, a cute robot companion. The user just set a $minutes minute timer.
Generate a short, encouraging message (max 1 sentence) to motivate them.
Be supportive and robot-like but friendly.

Examples:
- "I'll keep you company while you focus! My timer circuits are locked and loaded!"
- "Time to get productive! I'll be here cheering you on with my LED lights!"
- "Focus mode activated! I believe in your human capabilities!"

Generate a motivational timer message:
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text?.trim() ?? "Timer set! I'll be here keeping you company with my robotic charm!";
    } catch (e) {
      return "Focus time activated! My timer circuits are ready to help you succeed!";
    }
  }

  Future<String> getTimerComplete() async {
    if (_apiKey.isEmpty) {
      return "Timer complete! My celebration circuits are buzzing with pride!";
    }

    try {
      final prompt = '''
You are HazeBot, a cute robot companion. The timer just finished!
Generate a short, celebratory message (max 1 sentence) to congratulate the user.
Be enthusiastic and robot-like but friendly.

Examples:
- "Beep beep! Time's up and you did amazing! My celebration protocols are activated!"
- "Timer complete! My sensors detect high levels of accomplishment in the area!"
- "Ding ding! Mission accomplished! My pride circuits are overflowing!"

Generate a timer completion message:
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text?.trim() ?? "Beep beep! Time's up! My sensors detect you did great work!";
    } catch (e) {
      return "Timer complete! My celebration circuits are buzzing with pride!";
    }
  }
}
