import 'package:flutter_test/flutter_test.dart';
import 'package:book_tracker/domain/models/book.dart';
import 'package:book_tracker/domain/models/reading_session.dart';
import 'package:book_tracker/domain/services/finish_prediction_service.dart';

void main() {
  group('FinishPredictionService Tests', () {
    final now = DateTime.now();
    final book = Book(
      id: 'b1',
      title: 'Atomic Habits',
      author: 'James Clear',
      pageCount: 300,
      currentPage: 60,
      status: ReadingStatus.reading,
      lastReadAt: now,
      createdAt: now,
      updatedAt: now,
    );

    test('Withholds false-precision estimate when fewer than 2 sessions exist', () {
      final singleSession = [
        ReadingSession(
          id: 's1',
          bookId: 'b1',
          startedAt: now,
          durationSeconds: 1200,
          startPage: 0,
          endPage: 20,
          pagesRead: 20,
          createdAt: now,
        ),
      ];

      final result = FinishPredictionService.predictFinishDate(
        book: book,
        sessions: singleSession,
      );

      expect(result.hasSufficientData, false);
      expect(result.estimatedFinishDate, isNull);
      expect(result.message, contains('Log at least 2 reading sessions'));
    });

    test('Accurately estimates completion when 2 or more sessions are logged', () {
      final sessions = [
        ReadingSession(
          id: 's1',
          bookId: 'b1',
          startedAt: now.subtract(const Duration(days: 2)),
          durationSeconds: 1800,
          startPage: 0,
          endPage: 30,
          pagesRead: 30,
          createdAt: now.subtract(const Duration(days: 2)),
        ),
        ReadingSession(
          id: 's2',
          bookId: 'b1',
          startedAt: now.subtract(const Duration(days: 1)),
          durationSeconds: 1800,
          startPage: 30,
          endPage: 60,
          pagesRead: 30,
          createdAt: now.subtract(const Duration(days: 1)),
        ),
      ];

      final result = FinishPredictionService.predictFinishDate(
        book: book,
        sessions: sessions,
      );

      expect(result.hasSufficientData, true);
      expect(result.estimatedFinishDate, isNotNull);
      expect(result.averagePagesPerSession, 30.0);
      // Remaining pages: 300 - 60 = 240. 240 / 30 = 8 days
      expect(result.estimatedDaysRemaining, 8);
    });
  });
}
