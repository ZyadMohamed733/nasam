import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n/app_localizations.dart';

/// Measurements as the reader's locale writes them: digits, decimal mark
/// and grouping from [NumberFormat], the unit and its position from the
/// ARB — "12.5 km" in English, "١٢٫٥ كم" or "12.5 كم" in Arabic, whichever
/// the locale's number system says.
class TrackingUnits {
  TrackingUnits._(this._l, String locale)
    : _number = NumberFormat.decimalPattern(locale)..maximumFractionDigits = 1,
      _twoDigits = NumberFormat('00', locale);

  factory TrackingUnits.of(BuildContext context) => TrackingUnits._(
    AppLocalizations.of(context)!,
    Localizations.localeOf(context).toString(),
  );

  final AppLocalizations _l;
  final NumberFormat _number;
  final NumberFormat _twoDigits;

  String number(num value) => _number.format(value);

  String speedKph(num value) => _l.unitSpeedKph(number(value));
  String distanceKm(num value) => _l.unitDistanceKm(number(value));
  String weightKg(num value) => _l.unitWeightKg(number(value));
  String hours(num value) => _l.unitHours(number(value));
  String celsius(num value) => _l.unitCelsius(number(value));
  String percent(num value) => _l.unitPercent(number(value));
  String millivolts(num value) => _l.unitMillivolts(number(value));

  /// "07m 09s" under an hour, "1h 02m" from an hour up.
  String duration(Duration d) {
    final minutes = d.inMinutes;
    if (minutes < 60) {
      return _l.durationMinutesSeconds(
        _twoDigits.format(minutes),
        _twoDigits.format(d.inSeconds % 60),
      );
    }
    return _l.durationHoursMinutes(
      number(d.inHours),
      _twoDigits.format(minutes % 60),
    );
  }
}
