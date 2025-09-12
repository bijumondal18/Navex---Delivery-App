import 'package:intl/intl.dart';

extension TimeAgoExtension on DateTime {
  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24 && this.day == now.day) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1 ||
        (now.day - this.day == 1 && now.month == this.month)) {
      return 'Yesterday';
    } else if (difference.inDays == 0) {
      return 'Today';
    } else {
      return DateFormat('MMM d, yyyy').format(this);
    }
  }
}