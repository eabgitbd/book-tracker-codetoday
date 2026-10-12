import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/models/book.dart';

class BookCoverWidget extends StatelessWidget {
  final Book book;
  final double width;
  final double height;
  final double borderRadius;
  final bool showProgressOverlay;

  const BookCoverWidget({
    super.key,
    required this.book,
    this.width = 90,
    this.height = 135,
    this.borderRadius = 8.0,
    this.showProgressOverlay = false,
  });

  static const List<Color> _palette = [
    Color(0xFF2C4A3E), // Deep sage
    Color(0xFF6E472A), // Leather brown
    Color(0xFF2B4C6F), // Classic navy
    Color(0xFF7A3E48), // Burgundy
    Color(0xFF3E3D53), // Slate indigo
    Color(0xFF8A5D2E), // Amber ochre
  ];

  Color _resolveColor() {
    if (book.coverColorValue != null) {
      return Color(book.coverColorValue!);
    }
    final hash = book.title.hashCode.abs();
    return _palette[hash % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final hasLocalImage = book.coverLocalPath != null &&
        book.coverLocalPath!.isNotEmpty &&
        File(book.coverLocalPath!).existsSync();

    final baseColor = _resolveColor();

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            offset: const Offset(2, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasLocalImage)
              Image.file(
                File(book.coverLocalPath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildProceduralCover(baseColor),
              )
            else
              _buildProceduralCover(baseColor),

            // Left book spine crease shadow
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 6,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            if (showProgressOverlay && book.hasPageCount)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.65),
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                  child: Text(
                    '${(book.progressPercentage * 100).toInt()}%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProceduralCover(Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.9),
            color,
            color.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Embossed decorative header line
          Container(
            height: 2,
            width: 24,
            color: Colors.white.withOpacity(0.5),
          ),
          // Title
          Text(
            book.title,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              height: 1.2,
            ),
          ),
          // Author
          Text(
            book.author,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
