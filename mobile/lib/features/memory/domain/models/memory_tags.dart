class MemoryTags {
  const MemoryTags._();

  static List<String> fromText(String text) {
    final tokens = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9@#\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .map(_normalize)
        .where((token) => token.length > 2)
        .toSet()
        .toList();
    return tokens.take(8).toList();
  }

  static List<String> merge(Iterable<String> values) {
    return values
        .map(_normalize)
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
  }

  static bool containsAny(List<String> tags, Iterable<String> queryTags) {
    final normalized = tags.map(_normalize).toSet();
    return queryTags.map(_normalize).any(normalized.contains);
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
  }
}
