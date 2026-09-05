import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/core/constants/app_constants.dart';
import 'package:maxie_mobile/features/memory/data/models/memory_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final uuid = const Uuid();

class MemoryService {
  final List<MemoryModel> _memories = [];
  static const int _maxMemories = 1000;

  MemoryService() {
    _loadMemories();
  }

  List<MemoryModel> get memories => List.unmodifiable(_memories);

  List<Map<String, dynamic>> getMemoriesAsMap() {
    return _memories.map((m) => {
      m.id: m.content,
      'tags': m.tags.join(', '),
      'type': m.type.name,
      'timestamp': m.timestamp.toIso8601String(),
    }).toList();
  }

  void addMemory({
    required MemoryType type,
    required String content,
    List<String>? tags,
    double importance = 0.5,
    Map<String, dynamic>? metadata,
  }) {
    final memory = MemoryModel(
      id: uuid.v4(),
      type: type,
      content: content,
      timestamp: DateTime.now(),
      tags: tags ?? [],
      importance: importance,
      metadata: metadata,
    );
    _memories.add(memory);

    // Limit memory size
    if (_memories.length > _maxMemories) {
      _memories.removeAt(0);
    }
    _saveMemories();
  }

  List<MemoryModel> getMemoriesByType(MemoryType type) {
    return _memories.where((m) => m.type == type).toList();
  }

  List<MemoryModel> searchMemories(String query) {
    final lowerQuery = query.toLowerCase();
    return _memories.where((m) {
      return m.content.toLowerCase().contains(lowerQuery) ||
          m.tags.any((t) => t.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<MemoryModel> getRecentMemories({int limit = 10, MemoryType? type}) {
    var filtered = _memories;
    if (type != null) {
      filtered = filtered.where((m) => m.type == type).toList();
    }
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered.take(limit).toList();
  }

  List<MemoryModel> getImportantMemories({double minImportance = 0.7}) {
    final important = _memories
        .where((m) => m.importance >= minImportance)
        .toList();
    important.sort((a, b) => b.importance.compareTo(a.importance));
    return important;
  }

  void deleteMemory(String id) {
    _memories.removeWhere((m) => m.id == id);
    _saveMemories();
  }

  void toggleFavorite(String id) {
    final index = _memories.indexWhere((m) => m.id == id);
    if (index != -1) {
      _memories[index] = _memories[index].copyWith(
        isFavorite: !_memories[index].isFavorite,
      );
      _saveMemories();
    }
  }

  void clearMemories() {
    _memories.clear();
    _saveMemories();
  }

  String getPersonalizedContext() {
    if (_memories.isEmpty) return '';

    final preferences = getMemoriesByType(MemoryType.userPreference);
    final goals = getMemoriesByType(MemoryType.userGoal);
    final recent = getRecentMemories(limit: 5);

    final buffer = StringBuffer();

    if (preferences.isNotEmpty) {
      buffer.writeln('User preferences:');
      for (final pref in preferences.take(3)) {
        buffer.writeln('- ${pref.content}');
      }
    }
    if (goals.isNotEmpty) {
      buffer.writeln('User goals:');
      for (final goal in goals.take(3)) {
        buffer.writeln('- ${goal.content}');
      }
    }

    return buffer.toString();
  }

  void _loadMemories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(AppConstants.memoryKey);
      if (data != null) {
        final list = jsonDecode(data) as List<dynamic>;
        _memories.addAll(
          list.map((e) => MemoryModel.fromJson(e as Map<String, dynamic>)),
        );
      }
    } catch (e) {
      debugPrint('Error loading memories: $e');
    }
  }

  void _saveMemories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_memories.map((m) => m.toJson()).toList());
      await prefs.setString(AppConstants.memoryKey, data);
    } catch (e) {
      debugPrint('Error saving memories: $e');
    }
  }
}

final memoryServiceProvider = Provider<MemoryService>((ref) {
  return MemoryService();
});