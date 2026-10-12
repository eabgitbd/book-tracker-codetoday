class ReadingSession {
  final String id;
  final String bookId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final int startPage;
  final int endPage;
  final int pagesRead;
  final String? sessionNote;
  final String? focusTag;
  final DateTime createdAt;

  const ReadingSession({
    required this.id,
    required this.bookId,
    required this.startedAt,
    this.endedAt,
    required this.durationSeconds,
    required this.startPage,
    required this.endPage,
    required this.pagesRead,
    this.sessionNote,
    this.focusTag,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'startPage': startPage,
      'endPage': endPage,
      'pagesRead': pagesRead,
      'sessionNote': sessionNote,
      'focusTag': focusTag,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt'] as String) : null,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      startPage: json['startPage'] as int? ?? 0,
      endPage: json['endPage'] as int? ?? 0,
      pagesRead: json['pagesRead'] as int? ?? 0,
      sessionNote: json['sessionNote'] as String?,
      focusTag: json['focusTag'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    );
  }
}
