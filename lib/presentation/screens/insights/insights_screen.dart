import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/book.dart';
import '../../../domain/services/finish_prediction_service.dart';
import '../../providers/book_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/reading_progress_bar.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final books = ref.watch(booksProvider);
    final sessions = ref.watch(sessionsProvider);
    final streak = ref.watch(streakProvider);

    final totalPagesRead = sessions.fold<int>(0, (sum, s) => sum + s.pagesRead);
    final totalDurationMinutes = sessions.fold<int>(0, (sum, s) => sum + (s.durationSeconds ~/ 60));
    final finishedBooks = books.where((b) => b.status == ReadingStatus.read).toList();
    final readingBooks = books.where((b) => b.status == ReadingStatus.reading).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights & Trends', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Overview Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Books Finished',
                  value: '${finishedBooks.length}',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF315B48),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Pages Read',
                  value: '$totalPagesRead',
                  icon: Icons.menu_book,
                  color: const Color(0xFF2B4C6F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Reading Time',
                  value: '${totalDurationMinutes ~/ 60}h ${totalDurationMinutes % 60}m',
                  icon: Icons.timer_outlined,
                  color: const Color(0xFF8A5D2E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Best Streak',
                  value: '${streak.longestStreakDays} Days',
                  icon: Icons.local_fire_department_outlined,
                  color: const Color(0xFFD39A48),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Finish Predictions for Current Books
          Text(
            'Finish Predictions',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (readingBooks.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No books currently marked as "Reading". Start a book to see finish estimates!',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            )
          else
            ...readingBooks.map((book) {
              final pred = FinishPredictionService.predictFinishDate(
                book: book,
                sessions: sessions,
              );
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(pred.message, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                      const SizedBox(height: 8),
                      ReadingProgressBar(progress: book.progressPercentage, height: 6, showLabel: true),
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: 24),

          // Library Breakdown by Status
          Text(
            'Library Status Distribution',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: ReadingStatus.values.map((status) {
                  final count = books.where((b) => b.status == status).length;
                  final percentage = books.isNotEmpty ? (count / books.length) : 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(status.displayName, style: const TextStyle(fontSize: 13)),
                        ),
                        Expanded(
                          child: ReadingProgressBar(
                            progress: percentage,
                            height: 6,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
