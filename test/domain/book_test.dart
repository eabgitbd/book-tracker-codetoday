import 'package:flutter_test/flutter_test.dart';
import 'package:book_tracker/domain/models/book.dart';

void main() {
  group('Book Model Tests', () {
    test('Calculates progress percentage accurately and clamps to 0..1', () {
      final now = DateTime.now();
      final book = Book(
        id: 'b1',
        title: 'The Great Gatsby',
        author: 'F. Scott Fitzgerald',
        pageCount: 200,
        currentPage: 50,
        lastReadAt: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(book.progressPercentage, 0.25);
      expect(book.remainingPages, 150);

      // Clamping test with overflow page
      final overflownBook = book.copyWith(currentPage: 250);
      expect(overflownBook.progressPercentage, 1.0);
      expect(overflownBook.remainingPages, 0);

      // Book with no page count
      final noPageBook = book.copyWith(clearPageCount: true);
      expect(noPageBook.progressPercentage, 0.0);
      expect(noPageBook.hasPageCount, false);
    });

    test('Serializes to and from JSON correctly', () {
      final now = DateTime.now();
      final original = Book(
        id: 'book-123',
        title: 'Clean Architecture',
        author: 'Robert C. Martin',
        pageCount: 350,
        currentPage: 120,
        format: BookFormat.physical,
        status: ReadingStatus.reading,
        rating: 4.5,
        lastReadAt: now,
        createdAt: now,
        updatedAt: now,
      );

      final json = original.toJson();
      final reconstructed = Book.fromJson(json);

      expect(reconstructed.id, original.id);
      expect(reconstructed.title, original.title);
      expect(reconstructed.author, original.author);
      expect(reconstructed.pageCount, original.pageCount);
      expect(reconstructed.currentPage, original.currentPage);
      expect(reconstructed.format, original.format);
      expect(reconstructed.status, original.status);
      expect(reconstructed.rating, original.rating);
    });
  });
}
