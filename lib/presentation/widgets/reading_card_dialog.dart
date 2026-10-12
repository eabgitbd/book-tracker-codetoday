import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/book.dart';
import '../../domain/models/book_note.dart';

class ReadingCardDialog extends StatelessWidget {
  final Book book;
  final BookNote? quote;

  const ReadingCardDialog({
    super.key,
    required this.book,
    this.quote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reading Card',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // The Reading Card itself
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F7F1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2DFD2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (quote != null) ...[
                    const Icon(Icons.format_quote, size: 36, color: Color(0xFF315B48)),
                    const SizedBox(height: 8),
                    Text(
                      quote!.content,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFF222521),
                      ),
                    ),
                    if (quote!.pageNumber != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '— Page ${quote!.pageNumber}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B706A)),
                      ),
                    ],
                    const Divider(height: 24),
                  ] else ...[
                    // Milestone / Progress card
                    Row(
                      children: [
                        const Icon(Icons.auto_stories, color: Color(0xFF315B48)),
                        const SizedBox(width: 8),
                        Text(
                          book.isCompleted ? 'Finished Book' : 'Currently Reading',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF315B48),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Page ${book.currentPage} of ${book.pageCount ?? "?"} (${(book.progressPercentage * 100).toInt()}%)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222521),
                      ),
                    ),
                    const Divider(height: 24),
                  ],

                  // Book details footer on card
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF222521),
                    ),
                  ),
                  Text(
                    book.author,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B706A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Watermark branding
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Captured with ${AppConstants.appName} • ${AppConstants.developer}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFA0A59E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Share Reading Card'),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reading card ready to share!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
