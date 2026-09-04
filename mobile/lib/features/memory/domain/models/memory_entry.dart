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

  factory MemoryEntry.fromJson(Map<dynamic, dynamic> json) {
    return MemoryEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      tags: [
        for (final tag in (json['tags'] as List<dynamic>? ?? const []))
          tag as String,
      ],
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }
}
