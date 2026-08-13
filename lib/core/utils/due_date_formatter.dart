import 'package:intl/intl.dart';

/// Formats a due date/time in a way that reads naturally depending on how
/// far away it is — this is what lets the task list show "Due in 2 hours"
/// instead of always spelling out the full date, while still showing the
/// full date+time for anything further out. Pure function, no widget
/// dependency, so it's easy to unit test on its own.
class DueDateFormatter {
  DueDateFormatter._();

  static String format(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    final isSameDay = dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
    final isTomorrow = dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day + 1;

    final timeStr = DateFormat.jm().format(dueDate); // e.g. "5:30 PM"

    if (isSameDay) {
      if (difference.isNegative) {
        // Overdue today — show how long ago in the most readable unit.
        final overdue = difference.abs();
        if (overdue.inMinutes < 60) {
          return '${overdue.inMinutes}m overdue';
        }
        return '${overdue.inHours}h overdue';
      }
      if (difference.inMinutes < 60) {
        return 'Due in ${difference.inMinutes}m';
      }
      return 'Today, $timeStr';
    }

    if (isTomorrow) {
      return 'Tomorrow, $timeStr';
    }

    if (difference.isNegative) {
      final overdueDays = now.difference(dueDate).inDays;
      return 'Overdue by ${overdueDays}d';
    }

    if (difference.inDays < 7) {
      return 'In ${difference.inDays}d, $timeStr';
    }

    // Far enough out that relative phrasing stops being useful —
    // fall back to a full, unambiguous date + time.
    return '${DateFormat.MMMd().format(dueDate)}, $timeStr';
  }
}