import 'package:intl/intl.dart';

class DateHelper {
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, y · h:mm a').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return 'Today';
    } else if (dateDay == tomorrow) {
      return 'Tomorrow';
    } else {
      final difference = dateDay.difference(today).inDays;
      if (difference > 0 && difference <= 7) {
        return '${difference}d';
      }
      return formatDate(date);
    }
  }

  static String getCountdownBadge(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    final difference = dateDay.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference > 1 && difference <= 7) {
      return '${difference}d';
    } else if (difference < 0) {
      return 'Past';
    }
    return formatDate(date);
  }
}
