import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../domain/entities/alert_history_filter.dart';
import '../../domain/entities/history_alert.dart';

/// How an alert's fields read on the list card and the details screen.
abstract final class AlertHistoryFormat {
  static String typeLabel(AppLocalizations l, AlertType type) => switch (type) {
    AlertType.speed => l.alertFilterTypeSpeed,
    AlertType.sensor => l.alertFilterTypeSensor,
    AlertType.geofence => l.alertTypeGeofence,
    AlertType.downtime => l.alertFilterTypeDowntime,
    AlertType.unknown => l.alertTypeUnknown,
  };

  /// The vehicle's name in the screen's language, then its code.
  static String asset(BuildContext context, AlertAsset asset) {
    final name = asset.name.of(_language(context));
    if (asset.code.isEmpty) return name;
    if (name.isEmpty) return asset.code;
    return '$name - ${asset.code}';
  }

  /// [text] in the screen's language.
  static String text(BuildContext context, LocalizedText text) =>
      text.of(_language(context));

  /// When it happened, read on the Saudi calendar the filter's days use.
  static String time(BuildContext context, DateTime occurredAt) => DateFormat(
    'd MMMM yyyy — hh:mm a',
    Localizations.localeOf(context).toString(),
  ).format(occurredAt.toUtc().add(AlertHistoryFilter.saudiUtcOffset));

  /// Latitude and longitude, or the story's message when it is unknown
  /// (scenario 28). Coordinates are the same in every language,
  /// so they are isolated left to right inside Arabic text.
  static String location(AppLocalizations l, AlertLocation? location) {
    if (location == null) return l.alertLocationUnavailable;
    String fixed(double value) => value.toStringAsFixed(5);
    return '\u2066${fixed(location.latitude)}, ${fixed(location.longitude)}\u2069';
  }

  static String _language(BuildContext context) =>
      Localizations.localeOf(context).languageCode;
}
