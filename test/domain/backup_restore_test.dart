import 'package:flutter_test/flutter_test.dart';
import 'package:book_tracker/domain/models/book.dart';
import 'package:book_tracker/domain/models/reading_session.dart';
import 'package:book_tracker/domain/models/book_note.dart';
import 'package:book_tracker/domain/models/app_settings.dart';
import 'package:book_tracker/domain/services/backup_restore_service.dart';

void main() {
  group('BackupRestoreService Tests', () {
    test('Exports valid JSON with manifest, counts, and items', () {
      final now = DateTime.now();
      final books = [
        Book(
          id: 'b1',
          title: 'Deep Work',
          author: 'Cal Newport',
          lastReadAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final sessions = [
        ReadingSession(
          id: 's1',
          bookId: 'b1',
          startedAt: now,
          durationSeconds: 1500,
          startPage: 0,
          endPage: 30,
          pagesRead: 30,
          createdAt: now,
        ),
      ];
      final notes = [
        BookNote(
          id: 'n1',
          bookId: 'b1',
          type: NoteType.quote,
          content: 'Clarity about what matters provides clarity about what does not.',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final jsonStr = BackupRestoreService.createBackupJson(
        books: books,
        sessions: sessions,
        notes: notes,
        settings: const AppSettings(),
      );

      final validation = BackupRestoreService.validateBackupJson(jsonStr);
      expect(validation.isValid, true);
      expect(validation.manifest?.bookCount, 1);
      expect(validation.manifest?.sessionCount, 1);
      expect(validation.manifest?.noteCount, 1);

      final payload = BackupRestoreService.parseBackupPayload(jsonStr);
      expect(payload.books.length, 1);
      expect(payload.books.first.title, 'Deep Work');
      expect(payload.sessions.length, 1);
      expect(payload.notes.length, 1);
    });

    test('Rejects invalid or corrupt JSON', () {
      final validation = BackupRestoreService.validateBackupJson('{invalid_json}');
      expect(validation.isValid, false);
      expect(validation.errorMessage, contains('JSON parse error'));
    });
  });
}
