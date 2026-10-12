import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../utils/id_generator.dart';

class BookCoverResult {
  final bool success;
  final String? filePath;
  final String? errorMessage;

  const BookCoverResult({
    required this.success,
    this.filePath,
    this.errorMessage,
  });
}

class BookCoverService {
  static final ImagePicker _picker = ImagePicker();

  static Future<Directory> _getCoversDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final coversDir = Directory(p.join(appDir.path, 'book_covers'));
    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }
    return coversDir;
  }

  /// Capture cover using device camera
  static Future<BookCoverResult> captureFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (photo == null) {
        return const BookCoverResult(success: false);
      }

      final savedPath = await _persistFile(photo.path);
      return BookCoverResult(success: true, filePath: savedPath);
    } catch (e) {
      return BookCoverResult(
        success: false,
        errorMessage: 'Camera error: ${e.toString()}',
      );
    }
  }

  /// Select cover from local gallery / file storage
  static Future<BookCoverResult> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image == null) {
        return const BookCoverResult(success: false);
      }

      final savedPath = await _persistFile(image.path);
      return BookCoverResult(success: true, filePath: savedPath);
    } catch (e) {
      return BookCoverResult(
        success: false,
        errorMessage: 'Gallery error: ${e.toString()}',
      );
    }
  }

  /// Download cover image from internet link and persist locally
  static Future<BookCoverResult> downloadFromUrl(String url) async {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) {
      return const BookCoverResult(
        success: false,
        errorMessage: 'Please enter a valid image URL.',
      );
    }

    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return const BookCoverResult(
        success: false,
        errorMessage: 'Invalid URL. Must begin with http:// or https://',
      );
    }

    try {
      final response = await http.get(uri).timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Image download timed out.'),
          );

      if (response.statusCode != 200) {
        return BookCoverResult(
          success: false,
          errorMessage: 'Server returned HTTP ${response.statusCode}',
        );
      }

      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        return const BookCoverResult(
          success: false,
          errorMessage: 'Downloaded file is empty.',
        );
      }

      // Determine extension from URL or fallback to jpg
      var ext = p.extension(uri.path).toLowerCase();
      if (ext != '.jpg' && ext != '.jpeg' && ext != '.png' && ext != '.webp') {
        ext = '.jpg';
      }

      final coversDir = await _getCoversDirectory();
      final filename = 'cover_${IdGenerator.generate()}$ext';
      final localFile = File(p.join(coversDir.path, filename));
      await localFile.writeAsBytes(bytes);

      return BookCoverResult(success: true, filePath: localFile.path);
    } catch (e) {
      return BookCoverResult(
        success: false,
        errorMessage: 'Failed to download image: ${e.toString()}',
      );
    }
  }

  /// Copy picked temporary file into app private permanent storage
  static Future<String> _persistFile(String sourcePath) async {
    final coversDir = await _getCoversDirectory();
    final ext = p.extension(sourcePath).isNotEmpty ? p.extension(sourcePath) : '.jpg';
    final targetFilename = 'cover_${IdGenerator.generate()}$ext';
    final targetFile = File(p.join(coversDir.path, targetFilename));
    await File(sourcePath).copy(targetFile.path);
    return targetFile.path;
  }
}
