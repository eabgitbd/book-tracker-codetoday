enum BookFormat {
  physical,
  ebook,
  audiobook,
  pdf,
  article,
  other,
}

extension BookFormatExtension on BookFormat {
  String get displayName {
    switch (this) {
      case BookFormat.physical:
        return 'Physical';
      case BookFormat.ebook:
        return 'E-Book';
      case BookFormat.audiobook:
        return 'Audiobook';
      case BookFormat.pdf:
        return 'PDF';
      case BookFormat.article:
        return 'Article';
      case BookFormat.other:
        return 'Other';
    }
  }
}

enum ReadingStatus {
  wantToRead,
  reading,
  paused,
  read,
  dnf, // Did Not Finish
  archived,
}

extension ReadingStatusExtension on ReadingStatus {
  String get displayName {
    switch (this) {
      case ReadingStatus.wantToRead:
        return 'Want to Read';
      case ReadingStatus.reading:
        return 'Reading';
      case ReadingStatus.paused:
        return 'Paused';
      case ReadingStatus.read:
        return 'Finished';
      case ReadingStatus.dnf:
        return 'DNF';
      case ReadingStatus.archived:
        return 'Archived';
    }
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final String? sortTitle;
  final String? subtitle;
  final String? description;
  final String? publisher;
  final String? publicationDate;
  final String? isbn;
  final String? languageCode;
  final int? pageCount;
  final int currentPage;
  final String? coverUrl;
  final String? coverLocalPath;
  final int? coverColorValue;
  final BookFormat format;
  final ReadingStatus status;
  final double? rating;
  final String? genre;
  final bool isOwned;
  final String? borrowedFrom;
  final DateTime? borrowedAt;
  final DateTime? returnDueDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime lastReadAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.sortTitle,
    this.subtitle,
    this.description,
    this.publisher,
    this.publicationDate,
    this.isbn,
    this.languageCode,
    this.pageCount,
    this.currentPage = 0,
    this.coverUrl,
    this.coverLocalPath,
    this.coverColorValue,
    this.format = BookFormat.physical,
    this.status = ReadingStatus.wantToRead,
    this.rating,
    this.genre,
    this.isOwned = true,
    this.borrowedFrom,
    this.borrowedAt,
    this.returnDueDate,
    this.startedAt,
    this.completedAt,
    required this.lastReadAt,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  bool get hasPageCount => pageCount != null && pageCount! > 0;

  double get progressPercentage {
    if (!hasPageCount) return 0.0;
    final clamped = currentPage.clamp(0, pageCount!);
    return clamped / pageCount!;
  }

  int get remainingPages {
    if (!hasPageCount) return 0;
    return (pageCount! - currentPage).clamp(0, pageCount!);
  }

  bool get isCompleted => status == ReadingStatus.read;

  bool get isBorrowed => !isOwned;

  bool get isReturnOverdue =>
      isBorrowed &&
      returnDueDate != null &&
      DateTime.now().isAfter(returnDueDate!);

  int? get daysUntilReturnDue {
    if (!isBorrowed || returnDueDate == null) return null;
    return returnDueDate!.difference(DateTime.now()).inDays;
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? sortTitle,
    String? subtitle,
    String? description,
    String? publisher,
    String? publicationDate,
    String? isbn,
    String? languageCode,
    int? pageCount,
    bool clearPageCount = false,
    int? currentPage,
    String? coverUrl,
    String? coverLocalPath,
    int? coverColorValue,
    BookFormat? format,
    ReadingStatus? status,
    double? rating,
    String? genre,
    bool? isOwned,
    String? borrowedFrom,
    bool clearBorrowedFrom = false,
    DateTime? borrowedAt,
    DateTime? returnDueDate,
    bool clearReturnDueDate = false,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastReadAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      sortTitle: sortTitle ?? this.sortTitle,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      publisher: publisher ?? this.publisher,
      publicationDate: publicationDate ?? this.publicationDate,
      isbn: isbn ?? this.isbn,
      languageCode: languageCode ?? this.languageCode,
      pageCount: clearPageCount ? null : (pageCount ?? this.pageCount),
      currentPage: currentPage ?? this.currentPage,
      coverUrl: coverUrl ?? this.coverUrl,
      coverLocalPath: coverLocalPath ?? this.coverLocalPath,
      coverColorValue: coverColorValue ?? this.coverColorValue,
      format: format ?? this.format,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      genre: genre ?? this.genre,
      isOwned: isOwned ?? this.isOwned,
      borrowedFrom: clearBorrowedFrom ? null : (borrowedFrom ?? this.borrowedFrom),
      borrowedAt: borrowedAt ?? this.borrowedAt,
      returnDueDate: clearReturnDueDate ? null : (returnDueDate ?? this.returnDueDate),
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'sortTitle': sortTitle,
      'subtitle': subtitle,
      'description': description,
      'publisher': publisher,
      'publicationDate': publicationDate,
      'isbn': isbn,
      'languageCode': languageCode,
      'pageCount': pageCount,
      'currentPage': currentPage,
      'coverUrl': coverUrl,
      'coverLocalPath': coverLocalPath,
      'coverColorValue': coverColorValue,
      'format': format.name,
      'status': status.name,
      'rating': rating,
      'genre': genre,
      'isOwned': isOwned,
      'borrowedFrom': borrowedFrom,
      'borrowedAt': borrowedAt?.toIso8601String(),
      'returnDueDate': returnDueDate?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'lastReadAt': lastReadAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String? ?? 'Unknown Author',
      sortTitle: json['sortTitle'] as String?,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      publisher: json['publisher'] as String?,
      publicationDate: json['publicationDate'] as String?,
      isbn: json['isbn'] as String?,
      languageCode: json['languageCode'] as String?,
      pageCount: json['pageCount'] as int?,
      currentPage: json['currentPage'] as int? ?? 0,
      coverUrl: json['coverUrl'] as String?,
      coverLocalPath: json['coverLocalPath'] as String?,
      coverColorValue: json['coverColorValue'] as int?,
      format: BookFormat.values.firstWhere(
        (f) => f.name == json['format'],
        orElse: () => BookFormat.physical,
      ),
      status: ReadingStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ReadingStatus.wantToRead,
      ),
      rating: (json['rating'] as num?)?.toDouble(),
      genre: json['genre'] as String?,
      isOwned: json['isOwned'] as bool? ?? true,
      borrowedFrom: json['borrowedFrom'] as String?,
      borrowedAt: json['borrowedAt'] != null
          ? DateTime.parse(json['borrowedAt'] as String)
          : null,
      returnDueDate: json['returnDueDate'] != null
          ? DateTime.parse(json['returnDueDate'] as String)
          : null,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      lastReadAt: json['lastReadAt'] != null ? DateTime.parse(json['lastReadAt'] as String) : DateTime.now(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }
}
