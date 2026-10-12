import 'package:flutter_test/flutter_test.dart';
import 'package:book_tracker/domain/models/reading_session.dart';
import 'package:book_tracker/domain/services/streak_calculator.dart';

void main() {
  group('StreakCalculator Tests', () {
    test('Returns 0 streak when sessions list is empty', () {
      final result = StreakCalculator.calculateStreak([]);
      expect(result.currentStreakDays, 0);
      expect(result.longestStreakDays, 0);
      expect(result.readToday, false);
      expect(result.totalReadingDays, 0);
    });

    test('Calculates active streak when sessions include today and yesterday', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10);
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      final sessions = [
        ReadingSession(
          id: 's1',
          bookId: 'b1',
          startedAt: today,
          durationSeconds: 1200,
          startPage: 0,
          endPage: 20,
          pagesRead: 20,
          createdAt: today,
        ),
        ReadingSession(
          id: 's2',
          bookId: 'b1',
          startedAt: yesterday,
          durationSeconds: 1500,
          startPage: 20,
          endPage: 45,
          pagesRead: 25,
          createdAt: yesterday,
        ),
        ReadingSession(
          id: 's3',
          bookId: 'b1',
          startedAt: twoDaysAgo,
          durationSeconds: 900,
          startPage: 45,
          endPage: 60,
          pagesRead: 15,
          createdAt: twoDaysAgo,
        ),
      ];

      final result = StreakCalculator.calculateStreak(sessions);
      expect(result.readToday, true);
      expect(result.currentStreakDays, 3);
      expect(result.longestStreakDays, 3);
      expect(result.totalReadingDays, 3);
    });
  });
}
