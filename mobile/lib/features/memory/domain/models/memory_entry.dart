class MemoryEntry {
  const MemoryEntry({
    required this.id,
    required this.title,
    required this.createdAt,
    this.tags = const [],
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final List<String> tags;
}
