import '../models/book.dart';
import '../models/reading_session.dart';

enum PredictionConfidence {
  low,
  medium,
  high,
}

class FinishPredictionResult {
  final bool hasSufficientData;
  final String message;
  final DateTime? estimatedFinishDate;
  final int? estimatedDaysRemaining;
  final double? averagePagesPerSession;
  final PredictionConfidence confidence;

  const FinishPredictionResult({
    required this.hasSufficientData,
    required this.message,
    this.estimatedFinishDate,
    this.estimatedDaysRemaining,
    this.averagePagesPerSession,
    this.confidence = PredictionConfidence.low,
  });
}

class FinishPredictionService {
  static FinishPredictionResult predictFinishDate({
    required Book book,
    required List<ReadingSession> sessions,
  }) {
    if (book.status == ReadingStatus.read) {
      return const FinishPredictionResult(
        hasSufficientData: false,
        message: 'This book has already been completed.',
      );
    }

    if (!book.hasPageCount) {
      return const FinishPredictionResult(
        hasSufficientData: false,
        message: 'Set total page count to calculate estimated finish date.',
      );
    }

    final remainingPages = book.remainingPages;
    if (remainingPages <= 0) {
      return const FinishPredictionResult(
        hasSufficientData: false,
        message: 'All pages read. Mark book as finished!',
      );
    }

    // Filter valid sessions for this book with positive progress
    final validSessions = sessions
        .where((s) => s.bookId == book.id && s.pagesRead > 0)
        .toList();

    // Blueprint Section 13: Never fabricate missing history; require sufficient data!
    if (validSessions.length < 2) {
      return const FinishPredictionResult(
        hasSufficientData: false,
        message: 'Log at least 2 reading sessions to calculate an accurate finish estimate.',
      );
    }

    // Calculate average pages read per session
    final totalPagesInSessions = validSessions.fold<int>(0, (sum, s) => sum + s.pagesRead);
    final avgPagesPerSession = totalPagesInSessions / validSessions.length;

    if (avgPagesPerSession <= 0) {
      return const FinishPredictionResult(
        hasSufficientData: false,
        message: 'Insufficient reading pace data.',
      );
    }

    // Estimate sessions needed
    final sessionsNeeded = (remainingPages / avgPagesPerSession).ceil();
    // Assuming roughly 1 session per day on active cadence
    final daysRemaining = sessionsNeeded;
    final finishDate = DateTime.now().add(Duration(days: daysRemaining));

    final confidence = validSessions.length >= 5
        ? PredictionConfidence.high
        : PredictionConfidence.medium;

    return FinishPredictionResult(
      hasSufficientData: true,
      message: 'Estimated completion in ~$daysRemaining days at current pace.',
      estimatedFinishDate: finishDate,
      estimatedDaysRemaining: daysRemaining,
      averagePagesPerSession: avgPagesPerSession,
      confidence: confidence,
    );
  }
}
