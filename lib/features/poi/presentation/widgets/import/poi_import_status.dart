import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_status_tones.dart';
import '../../../domain/entities/poi_import_row.dart';
import '../../../domain/entities/poi_validation.dart';

/// How a row's status and reasons read and look, in one place.
abstract final class PoiImportStatus {
  /// Null is the "all" filter.
  static AppTone tone(PoiRowStatus? status) => switch (status) {
    PoiRowStatus.valid => AppTone.success,
    PoiRowStatus.invalid => AppTone.danger,
    PoiRowStatus.duplicate => AppTone.warning,
    null => AppTone.info,
  };

  static String label(PoiRowStatus? status, AppLocalizations l) =>
      switch (status) {
        PoiRowStatus.valid => l.poiValid,
        PoiRowStatus.invalid => l.poiInvalid,
        PoiRowStatus.duplicate => l.poiDuplicate,
        null => l.poiAll,
      };

  /// Why the row will not be imported; empty for a valid row.
  static String reason(PoiImportRow row, AppLocalizations l) =>
      switch (row.status) {
        PoiRowStatus.valid => '',
        PoiRowStatus.duplicate => l.poiIssueDuplicate,
        PoiRowStatus.invalid => row.issues.map((i) => issue(i, l)).join('\n'),
      };

  static String issue(PoiIssue issue, AppLocalizations l) => switch (issue) {
    PoiIssue.nameRequired => l.poiIssueNameRequired,
    PoiIssue.nameTooLong => l.poiIssueNameTooLong,
    PoiIssue.latitudeInvalid => l.poiIssueLatitude,
    PoiIssue.longitudeInvalid => l.poiIssueLongitude,
    PoiIssue.iconUnknown => l.poiIssueIcon,
    PoiIssue.notesTooLong => l.poiIssueNotesTooLong,
  };
}
