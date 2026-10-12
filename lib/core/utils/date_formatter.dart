import 'package:intl/intl.dart';

class DateFormatter {
  static final _shortDate = DateFormat('MMM d, yyyy');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _shortTime = DateFormat('h:mm a');

  static String formatDate(DateTime date) {
    return _shortDate.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYear.format(date);
  }

  static String formatTime(DateTime date) {
    return _shortTime.format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes <= 1) {
          return 'Just now';
        }
        return '${difference.inMinutes} mins ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return _shortDate.format(date);
    }
  }
}
