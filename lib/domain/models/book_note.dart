enum NoteType {
  quote,
  note,
  reflection,
}

extension NoteTypeExtension on NoteType {
  String get displayName {
    switch (this) {
      case NoteType.quote:
        return 'Quote';
      case NoteType.note:
        return 'Note';
      case NoteType.reflection:
        return 'Reflection';
    }
  }
}

class BookNote {
  final String id;
  final String bookId;
  final NoteType type;
  final String content;
  final int? pageNumber;
  final List<String> tags;
  final String sourceType; // manual, ocr, imported
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookNote({
    required this.id,
    required this.bookId,
    required this.type,
    required this.content,
    this.pageNumber,
    this.tags = const [],
    this.sourceType = 'manual',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'type': type.name,
      'content': content,
      'pageNumber': pageNumber,
      'tags': tags,
      'sourceType': sourceType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BookNote.fromJson(Map<String, dynamic> json) {
    return BookNote(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      type: NoteType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => NoteType.note,
      ),
      content: json['content'] as String,
      pageNumber: json['pageNumber'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      sourceType: json['sourceType'] as String? ?? 'manual',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
    );
  }
}
