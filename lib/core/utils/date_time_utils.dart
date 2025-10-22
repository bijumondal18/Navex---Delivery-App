import 'package:intl/intl.dart';

class DateTimeUtils {
  /// Formats an ISO 8601 UTC string like "2025-08-13T06:23:26.541Z"
  /// Rules:
  /// 1) Today -> "10:02 AM"
  /// 2) Yesterday -> "Yesterday"
  /// 3) Day before yesterday -> weekday ("Monday", "Tuesday", ...)
  /// 4) Else -> date "dd/MM/yy"
  static String formatChatTimestamp(String isoUtc, {DateTime? now}) {
    try {
      final dt = DateTime.parse(isoUtc).toLocal();
      final ref = (now ?? DateTime.now()).toLocal();

      DateTime justDate(DateTime d) => DateTime(d.year, d.month, d.day);
      final diffDays = justDate(ref).difference(justDate(dt)).inDays;

      if (diffDays == 0) {
        // Today
        return DateFormat('h:mm a').format(dt);
      } else if (diffDays == 1) {
        // Yesterday
        return 'Yesterday';
      } else if (diffDays == 2) {
        // Day before yesterday -> weekday
        return DateFormat('EEEE').format(dt);
      } else {
        // Everything else -> date only
        return DateFormat('dd MMM').format(dt);
      }
    } catch (_) {
      // Fallback if parsing fails
      return isoUtc;
    }
  }

  /// Converts a date string into "29th July, 2025" format
  static String formatToDayMonthYear(String dateStr) {
    if (dateStr.isEmpty) return '';

    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final day = dt.day;
      final suffix = _daySuffix(day);
      final month = DateFormat('MMMM').format(dt);
      final year = dt.year;

      return "$day$suffix $month, $year";
    } catch (e) {
      return dateStr; // fallback in case parsing fails
    }
  }

  static String _daySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  static String getFormattedCurrentDate() {
    final now = DateTime.now(); // current date
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(now);
  }

  static String getFormattedSelectedDate(DateTime selectedDate) {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(selectedDate);
  }

  static String getCurrentDate() {
    final now = DateTime.now();
    // Format: YYYY-MM-DD
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }


  static String getFormattedPickedDate(DateTime selectedDate) {
    return "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
  }

  static String convertMinutesToHoursMinutes(String minutesStr) {
    final totalMinutes = int.tryParse(minutesStr) ?? 0; // Safely parse to int
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return "${hours}h ${minutes}m";
  }

  static String convertToAmPm(String time24) {
    try {
      // Parse the 24-hour format time string
      final dateTime = DateTime.parse("1970-01-01 $time24");

      // Format into 12-hour format with AM/PM
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? "PM" : "AM";

      return "$hour:$minute $period";
    } catch (e) {
      return "Invalid time format";
    }
  }

}
