import 'package:flutter_riverpod/flutter_riverpod.dart';

class CodingDetector {
  static final Map<String, String> codingApps = {
    'com.github.android': 'GitHub',
    'com.microsoft.vscode': 'VS Code',
    'com.jedga.vscode': 'VS Code',
    'com.google.android.studio': 'Android Studio',
    'com.jetbrains.android': 'Android Studio',
    'com.zeptolab.cats': 'Replit',
    'com.replit.android': 'Replit',
    'com.coderpad': 'CoderPad',
    'com.codepen': 'CodePen',
    'com.stackexchange': 'Stack Overflow',
    'com.stackoverflow': 'Stack Overflow',
    'com.termux': 'Termux',
    'com.spartacusrex.spartacuside': 'AIDE',
    'com.aide.ide': 'AIDE',
    'sololearn': 'SoloLearn',
    'com.sololearn': 'SoloLearn',
    'com.udemy.android': 'Udemy',
    'com.coursera.android': 'Coursera',
  };

  String? detectCodingApp(String packageName) {
    return codingApps[packageName];
  }

  bool isCodingApp(String packageName) {
    return codingApps.containsKey(packageName);
  }

  String getCodingReaction(String app, String activity) {
    switch (activity) {
      case 'typing':
        return _getTypingReaction();
      case 'error':
        return _getErrorReaction();
      case 'success':
        return _getSuccessReaction();
      case 'debugging':
        return _getDebuggingReaction();
      default:
        return _getDefaultReaction(app);
    }
  }

  String _getTypingReaction() {
    return [
      'Code code code! ⌨️',
      'Look at you go! Typing master! 💻',
      'Those fingers are flying! ⚡',
      'Coding in progress... 🚧',
      'Compiling... just kidding! 😂',
    ][(DateTime.now().millisecond) % 5];
  }

  String _getErrorReaction() {
    return [
      'Bug detected! 🐛',
      'Don\'t forget semicolons... 😂',
      'Classic error! You\'ll fix it!',
      'Debugging mode: ON! 🔍',
      'Every bug is a feature in disguise! 😄',
    ][(DateTime.now().millisecond) % 5];
  }

  String _getSuccessReaction() {
    return [
      'It compiles! 🎉',
      'First try? You\'re a genius! 🧠',
      'Clean code! Beautiful! ✨',
      'That\'s how it\'s done! 👏',
      'Code works! Time to ship! 🚀',
    ][(DateTime.now().millisecond) % 5];
  }

  String _getDebuggingReaction() {
    return [
      'Where is that bug... 🕵️',
      'Sherlock Holmes mode activated! 🔍',
      'Bug hunting! Let\'s find it! 🎯',
      'Almost got it... I can feel it! 😤',
      'Debugging is just coding with extra steps! 😂',
    ][(DateTime.now().millisecond) % 5];
  }

  String _getDefaultReaction(String app) {
    return [
      'Coding on $app? Nice! 💻',
      '$app time! Build something amazing!',
      'Future Google engineer loading... 🚀',
      'I\'ll be your coding buddy on $app!',
      'Let\'s create something cool on $app! ✨',
    ][(DateTime.now().millisecond) % 5];
  }
}

final codingDetectorProvider = Provider<CodingDetector>((ref) {
  return CodingDetector();
});
