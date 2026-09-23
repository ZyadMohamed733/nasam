import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'context_extensions.dart';

extension DateExtensions on DateTime {
  String toFormattedString([String pattern = 'yyyy-MM-dd HH:mm']) {
    return DateFormat(pattern).format(this);
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Relative time resolved through the ARB plural rules.
  ///
  /// Takes a [BuildContext] because Arabic has six plural categories and its
  /// dual form carries no number word at all ("منذ يومين"), so no amount of
  /// `count == 1 ? a : b` in Dart can produce it — only ICU can.
  String toRelativeTime(BuildContext context, {DateTime? now}) {
    final l10n = context.l10n;
    final difference = (now ?? DateTime.now()).difference(this);

    if (difference.inDays > 30) {
      return toFormattedString('yyyy-MM-dd');
    }
    if (difference.inDays >= 7) {
      return l10n.relativeWeeksAgo((difference.inDays / 7).floor());
    }
    if (difference.inDays >= 1) {
      return l10n.relativeDaysAgo(difference.inDays);
    }
    if (difference.inHours >= 1) {
      return l10n.relativeHoursAgo(difference.inHours);
    }
    if (difference.inMinutes >= 1) {
      return l10n.relativeMinutesAgo(difference.inMinutes);
    }
    return l10n.relativeJustNow;
  }
}
