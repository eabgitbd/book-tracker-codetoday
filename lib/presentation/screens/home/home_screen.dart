import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/models/book.dart';
import '../../providers/book_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/book_cover_widget.dart';
import '../../widgets/reading_progress_bar.dart';
import '../../widgets/log_session_dialog.dart';
import '../library/add_edit_book_screen.dart';
import '../library/book_details_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final books = ref.watch(booksProvider);
    final streak = ref.watch(streakProvider);
    final settings = ref.watch(settingsProvider);
    final allSessions = ref.watch(sessionsProvider);

    // Calculate pages read today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayPages = allSessions
        .where((s) {
          final sDate = DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
          return sDate == today;
        })
        .fold<int>(0, (sum, s) => sum + s.pagesRead);

    // Find currently reading book (first by lastReadAt)
    final currentlyReading = books
        .where((b) => b.status == ReadingStatus.reading)
        .toList();
    final heroBook = currentlyReading.isNotEmpty
        ? currentlyReading.first
        : (books.isNotEmpty ? books.first : null);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormatter.formatDate(DateTime.now()).toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              '${_getGreeting()}, Reader',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Book',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddEditBookScreen()),
              );
            },
          ),
        ],
      ),
      body: books.isEmpty
          ? _buildEmptyState(context)
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Streak & Daily Goal Metric Row
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${streak.currentStreakDays} Day Streak',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    streak.readToday ? 'Active today!' : 'Log reading today',
                                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Goal: $todayPages / ${settings.dailyPageGoal} p.',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              ReadingProgressBar(
                                progress: settings.dailyPageGoal > 0
                                    ? (todayPages / settings.dailyPageGoal).clamp(0.0, 1.0)
                                    : 0.0,
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Hero Card: Continue Reading
                if (heroBook != null) ...[
                  Text(
                    'Continue Reading',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildHeroCard(context, ref, heroBook),
                  const SizedBox(height: 24),
                ],

                // Recently Read / Recent Books
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent in Library',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${books.length} Books',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 190,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final b = books[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BookDetailsScreen(bookId: b.id),
                            ),
                          );
                        },
                        child: Container(
                          width: 105,
                          margin: const EdgeInsets.only(right: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BookCoverWidget(
                                book: b,
                                width: 105,
                                height: 145,
                                showProgressOverlay: true,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                b.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildHeroCard(BuildContext context, WidgetRef ref, Book book) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => BookDetailsScreen(bookId: book.id)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookCoverWidget(
                    book: book,
                    width: 75,
                    height: 110,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.author,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ReadingProgressBar(
                          progress: book.progressPercentage,
                          showLabel: true,
                          height: 7,
                        ),
                        const SizedBox(height: 4),
                        if (book.hasPageCount)
                          Text(
                            'Page ${book.currentPage} of ${book.pageCount}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Quick Increments & Log Session
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      final newPage = (book.currentPage + 1).clamp(0, book.pageCount ?? 9999);
                      ref.read(booksProvider.notifier).updateProgress(book.id, newPage);
                    },
                    child: const Text('+1 p.'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      final newPage = (book.currentPage + 5).clamp(0, book.pageCount ?? 9999);
                      ref.read(booksProvider.notifier).updateProgress(book.id, newPage);
                    },
                    child: const Text('+5 p.'),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.timer_outlined, size: 16),
                    label: const Text('Log'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => LogSessionDialog(book: book),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories_outlined, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text(
              'Welcome to your Library',
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep your personal collection, track reading sessions, and save your favorite quotes offline.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Book'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddEditBookScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
