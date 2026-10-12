import '../models/reading_session.dart';

class StreakResult {
  final int currentStreakDays;
  final int longestStreakDays;
  final bool readToday;
  final int totalReadingDays;

  const StreakResult({
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.readToday,
    required this.totalReadingDays,
  });
}

class StreakCalculator {
  static StreakResult calculateStreak(List<ReadingSession> sessions) {
    if (sessions.isEmpty) {
      return const StreakResult(
        currentStreakDays: 0,
        longestStreakDays: 0,
        readToday: false,
        totalReadingDays: 0,
      );
    }

    // Extract unique normalized dates (year, month, day)
    final uniqueDates = <DateTime>{};
    for (final session in sessions) {
      if (session.pagesRead > 0 || session.durationSeconds > 0) {
        final d = session.startedAt;
        uniqueDates.add(DateTime(d.year, d.month, d.day));
      }
    }

    if (uniqueDates.isEmpty) {
      return const StreakResult(
        currentStreakDays: 0,
        longestStreakDays: 0,
        readToday: false,
        totalReadingDays: 0,
      );
    }

    final sortedDates = uniqueDates.toList()..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final readToday = uniqueDates.contains(today);
    final readYesterday = uniqueDates.contains(yesterday);

    int currentStreak = 0;

    if (readToday || readYesterday) {
      DateTime checkDate = readToday ? today : yesterday;
      while (uniqueDates.contains(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }

    // Calculate longest historical streak
    // Sort ascending for consecutive check
    final ascendingDates = uniqueDates.toList()..sort((a, b) => a.compareTo(b));
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? prevDate;

    for (final date in ascendingDates) {
      if (prevDate == null) {
        tempStreak = 1;
      } else {
        final difference = date.difference(prevDate).inDays;
        if (difference == 1) {
          tempStreak++;
        } else {
          tempStreak = 1;
        }
      }
      if (tempStreak > longestStreak) {
        longestStreak = tempStreak;
      }
      prevDate = date;
    }

    return StreakResult(
      currentStreakDays: currentStreak,
      longestStreakDays: longestStreak,
      readToday: readToday,
      totalReadingDays: uniqueDates.length,
    );
  }
}
