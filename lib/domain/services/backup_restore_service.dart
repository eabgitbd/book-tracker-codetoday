import 'dart:convert';
import '../models/book.dart';
import '../models/reading_session.dart';
import '../models/book_note.dart';
import '../models/app_settings.dart';

class BackupManifest {
  final int formatVersion;
  final String appVersion;
  final DateTime exportedAt;
  final int bookCount;
  final int sessionCount;
  final int noteCount;

  const BackupManifest({
    required this.formatVersion,
    required this.appVersion,
    required this.exportedAt,
    required this.bookCount,
    required this.sessionCount,
    required this.noteCount,
  });

  Map<String, dynamic> toJson() => {
        'formatVersion': formatVersion,
        'appVersion': appVersion,
        'exportedAt': exportedAt.toIso8601String(),
        'bookCount': bookCount,
        'sessionCount': sessionCount,
        'noteCount': noteCount,
      };

  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    return BackupManifest(
      formatVersion: json['formatVersion'] as int? ?? 1,
      appVersion: json['appVersion'] as String? ?? '1.0.0',
      exportedAt: json['exportedAt'] != null
          ? DateTime.parse(json['exportedAt'] as String)
          : DateTime.now(),
      bookCount: json['bookCount'] as int? ?? 0,
      sessionCount: json['sessionCount'] as int? ?? 0,
      noteCount: json['noteCount'] as int? ?? 0,
    );
  }
}

class BackupValidationResult {
  final bool isValid;
  final String? errorMessage;
  final BackupManifest? manifest;

  const BackupValidationResult({
    required this.isValid,
    this.errorMessage,
    this.manifest,
  });
}

class BackupPayload {
  final BackupManifest manifest;
  final List<Book> books;
  final List<ReadingSession> sessions;
  final List<BookNote> notes;
  final AppSettings? settings;

  const BackupPayload({
    required this.manifest,
    required this.books,
    required this.sessions,
    required this.notes,
    this.settings,
  });
}

class BackupRestoreService {
  static const int currentFormatVersion = 1;

  static String createBackupJson({
    required List<Book> books,
    required List<ReadingSession> sessions,
    required List<BookNote> notes,
    required AppSettings settings,
  }) {
    final manifest = BackupManifest(
      formatVersion: currentFormatVersion,
      appVersion: '1.0.0',
      exportedAt: DateTime.now().toUtc(),
      bookCount: books.length,
      sessionCount: sessions.length,
      noteCount: notes.length,
    );

    final payload = {
      'manifest': manifest.toJson(),
      'books': books.map((b) => b.toJson()).toList(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'notes': notes.map((n) => n.toJson()).toList(),
      'settings': settings.toJson(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  static BackupValidationResult validateBackupJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return const BackupValidationResult(
          isValid: false,
          errorMessage: 'Invalid file format: Root must be a JSON object.',
        );
      }

      if (!decoded.containsKey('manifest')) {
        return const BackupValidationResult(
          isValid: false,
          errorMessage: 'Missing backup manifest.',
        );
      }

      final manifestJson = decoded['manifest'];
      if (manifestJson is! Map<String, dynamic>) {
        return const BackupValidationResult(
          isValid: false,
          errorMessage: 'Malformed manifest structure.',
        );
      }

      final manifest = BackupManifest.fromJson(manifestJson);
      if (manifest.formatVersion > currentFormatVersion) {
        return BackupValidationResult(
          isValid: false,
          errorMessage:
              'Backup version ${manifest.formatVersion} is not supported by this app version ($currentFormatVersion). Please update the app.',
        );
      }

      if (!decoded.containsKey('books') || decoded['books'] is! List) {
        return const BackupValidationResult(
          isValid: false,
          errorMessage: 'Backup must contain a valid books list.',
        );
      }

      return BackupValidationResult(
        isValid: true,
        manifest: manifest,
      );
    } catch (e) {
      return BackupValidationResult(
        isValid: false,
        errorMessage: 'JSON parse error: ${e.toString()}',
      );
    }
  }

  static BackupPayload parseBackupPayload(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final manifest = BackupManifest.fromJson(decoded['manifest'] as Map<String, dynamic>);

    final books = (decoded['books'] as List<dynamic>)
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();

    final sessions = (decoded['sessions'] as List<dynamic>?)
            ?.map((item) => ReadingSession.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    final notes = (decoded['notes'] as List<dynamic>?)
            ?.map((item) => BookNote.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    AppSettings? settings;
    if (decoded['settings'] is Map<String, dynamic>) {
      settings = AppSettings.fromJson(decoded['settings'] as Map<String, dynamic>);
    }

    return BackupPayload(
      manifest: manifest,
      books: books,
      sessions: sessions,
      notes: notes,
      settings: settings,
    );
  }
}
