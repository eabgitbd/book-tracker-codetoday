import 'package:flutter/material.dart';
import '../../domain/models/book.dart';

class BookshelfSpineView extends StatelessWidget {
  final List<Book> books;
  final void Function(Book book) onBookTap;

  const BookshelfSpineView({
    super.key,
    required this.books,
    required this.onBookTap,
  });

  static const List<Color> _spineColors = [
    Color(0xFF2C4A3E), // Deep Forest Green
    Color(0xFF6E472A), // Warm Leather Brown
    Color(0xFF1E3A5F), // Deep Navy
    Color(0xFF7B2D26), // Oxblood Crimson
    Color(0xFF4A3B32), // Dark Espresso
    Color(0xFF2D5A46), // Muted Olive
    Color(0xFF5A4D41), // Antique Slate
    Color(0xFF8B4513), // Saddle Brown
  ];

  double _calculateSpineWidth(int? pageCount) {
    if (pageCount == null || pageCount <= 0) return 34.0;
    // Map pages 50..1000 to 26..62 dp width
    final clamped = pageCount.clamp(50, 1000);
    return 26.0 + ((clamped - 50) / 950.0) * 36.0;
  }

  double _calculateSpineHeight(Book book) {
    // Varied natural book heights between 170 and 205 dp
    final hash = book.title.hashCode.abs();
    return 175.0 + (hash % 30);
  }

  Color _resolveSpineColor(Book book) {
    if (book.coverColorValue != null) {
      return Color(book.coverColorValue!);
    }
    final hash = book.title.hashCode.abs();
    return _spineColors[hash % _spineColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (books.isEmpty) {
      return Center(
        child: Text(
          'Your bookshelf is empty.\nTap + to place your first book!',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    // Split books into shelves of approximately 8-10 books per shelf
    const int booksPerShelf = 8;
    final shelfCount = (books.length / booksPerShelf).ceil();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: shelfCount,
      itemBuilder: (context, shelfIndex) {
        final startIndex = shelfIndex * booksPerShelf;
        final endIndex = (startIndex + booksPerShelf).clamp(0, books.length);
        final shelfBooks = books.sublist(startIndex, endIndex);

        return _buildShelf(context, shelfBooks);
      },
    );
  }

  Widget _buildShelf(BuildContext context, List<Book> shelfBooks) {
    return Column(
      children: [
        // Books standing on the shelf
        Container(
          height: 215,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final book in shelfBooks) ...[
                _buildBookSpine(context, book),
                const SizedBox(width: 3),
              ],
            ],
          ),
        ),
        // Wooden Shelf Rail
        Container(
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF6B4423),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF8B5A2B),
                Color(0xFF5C381E),
                Color(0xFF422613),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildBookSpine(BuildContext context, Book book) {
    final spineWidth = _calculateSpineWidth(book.pageCount);
    final spineHeight = _calculateSpineHeight(book);
    final color = _resolveSpineColor(book);

    return InkWell(
      onTap: () => onBookTap(book),
      child: Container(
        width: spineWidth,
        height: spineHeight,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(1, 0),
              blurRadius: 2,
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color.withOpacity(0.85),
              color,
              color.withOpacity(0.7),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Gold foil header stripe
            Positioned(
              top: 6,
              left: 2,
              right: 2,
              height: 2,
              child: Container(color: Colors.amber.withOpacity(0.6)),
            ),

            // Reading status ribbon at top
            if (book.status == ReadingStatus.reading)
              Positioned(
                top: 0,
                right: 4,
                width: 6,
                height: 18,
                child: Container(
                  color: Colors.amber,
                ),
              )
            else if (book.status == ReadingStatus.read)
              Positioned(
                top: 0,
                right: 4,
                width: 6,
                height: 18,
                child: Container(
                  color: const Color(0xFF4CAF50),
                ),
              ),

            // Vertical Title Text
            Positioned.fill(
              top: 24,
              bottom: 12,
              child: RotatedBox(
                quarterTurns: 1,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom stripe
            Positioned(
              bottom: 6,
              left: 2,
              right: 2,
              height: 2,
              child: Container(color: Colors.white.withOpacity(0.4)),
            ),
          ],
        ),
      ),
    );
  }
}
