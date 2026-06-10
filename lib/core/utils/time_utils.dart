/// Time formatting and ETA calculation utilities.
class TimeUtils {
  /// Formats a DateTime as "HH:mm" (24-hour).
  static String formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Parses a "HH:mm" string into a [DateTime] (today's date).
  static DateTime parseHHmm(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Returns how many minutes from [from] to [to]. Negative if [to] is past.
  static int minutesBetween(DateTime from, DateTime to) =>
      to.difference(from).inMinutes;

  /// Converts minutes to human-readable string: "2 min", "1 hr 5 min".
  static String formatDuration(int totalMinutes) {
    if (totalMinutes < 60) return '$totalMinutes min';
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return m == 0 ? '$h hr' : '$h hr $m min';
  }

  /// Returns the scheduled ETA in minutes from now for a given [scheduledTime].
  static int? etaFromSchedule(String scheduledTime) {
    try {
      final scheduled = parseHHmm(scheduledTime);
      final diff = minutesBetween(DateTime.now(), scheduled);
      return diff < 0 ? null : diff; // null = already departed
    } catch (_) {
      return null;
    }
  }

  /// Returns "Today", "Tomorrow", or the date formatted as "dd MMM".
  static String relativeDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today';
    }
    final tomorrow = now.add(const Duration(days: 1));
    if (dt.year == tomorrow.year &&
        dt.month == tomorrow.month &&
        dt.day == tomorrow.day) {
      return 'Tomorrow';
    }
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month]}';
  }
}
