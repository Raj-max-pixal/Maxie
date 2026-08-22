import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_service.dart';

class MemoryBrainState {
  const MemoryBrainState({
    required this.memories,
    required this.summary,
    required this.relationship,
    this.pendingSuggestion,
    this.isLoading = false,
    this.errorMessage,
  });

  factory MemoryBrainState.initial() {
    return const MemoryBrainState(
      memories: [],
      summary: MemorySummary(
        totalMemories: 0,
        pinnedMemories: 0,
        relationshipLevel: 12,
        topCategories: {},
        recentCount: 0,
        mostImportantCount: 0,
      ),
      relationship: MemoryRelationshipState(
        friendshipLevel: 12,
        trustLevel: 10,
        conversationCount: 0,
        daysTogether: 0,
        messagesExchanged: 0,
        xpEarnedTogether: 0,
        milestones: [],
      ),
    );
  }

  final List<MemoryRecord> memories;
  final MemorySummary summary;
  final MemoryRelationshipState relationship;
  final MemorySuggestion? pendingSuggestion;
  final bool isLoading;
  final String? errorMessage;

  MemoryBrainState copyWith({
    List<MemoryRecord>? memories,
    MemorySummary? summary,
    MemoryRelationshipState? relationship,
    MemorySuggestion? pendingSuggestion,
    bool? isLoading,
    String? errorMessage,
    bool clearSuggestion = false,
    bool clearError = false,
  }) {
    return MemoryBrainState(
      memories: memories ?? this.memories,
      summary: summary ?? this.summary,
      relationship: relationship ?? this.relationship,
      pendingSuggestion: clearSuggestion
          ? null
          : pendingSuggestion ?? this.pendingSuggestion,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class MemoryManager extends StateNotifier<MemoryBrainState> {
  MemoryManager({required MemoryService service})
    : _service = service,
      super(MemoryBrainState.initial());

  final MemoryService _service;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final memories = await _service.recallMemory('');
      final summary = await _service.summarize();
      final relationship = await _service.relationshipSnapshot();
      state = state.copyWith(
        memories: memories,
        summary: summary,
        relationship: relationship,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> proposeSuggestion(
    String text, {
    String? conversationId,
    String? messageId,
  }) async {
    final suggestion = await _service.extractSuggestion(
      text,
      conversationId: conversationId,
      messageId: messageId,
    );
    if (suggestion == null) {
      state = state.copyWith(clearSuggestion: true);
      return;
    }
    state = state.copyWith(pendingSuggestion: suggestion, clearError: true);
  }

  Future<void> acceptSuggestion() async {
    final suggestion = state.pendingSuggestion;
    if (suggestion == null) {
      return;
    }
    await saveMemory(suggestion.memory);
    state = state.copyWith(clearSuggestion: true);
  }

  void ignoreSuggestion() {
    state = state.copyWith(clearSuggestion: true);
  }

  Future<void> saveMemory(MemoryRecord memory) async {
    await _service.saveMemory(memory);
    await load();
  }

  Future<void> deleteMemory(String id) async {
    await _service.deleteMemory(id);
    await load();
  }

  Future<void> pinMemory(String id, {bool pinned = true}) async {
    await _service.pinMemory(id, pinned: pinned);
    await load();
  }

  Future<void> clearMemories() async {
    await _service.clearMemories();
    await load();
  }
}
