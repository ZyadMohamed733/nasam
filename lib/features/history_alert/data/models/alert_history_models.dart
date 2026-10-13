/// The Alert History wire shapes (API-CONTRACT.md, NASAM-621). Enum fields
/// stay strings here; the mapper turns them into domain values.
library;

class NamedRefModel {
  const NamedRefModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  final String id;
  final String nameEn;
  final String nameAr;

  factory NamedRefModel.fromJson(Map<String, dynamic> json) => NamedRefModel(
    id: json['id'] as String,
    nameEn: json['nameEn'] as String? ?? '',
    nameAr: json['nameAr'] as String? ?? '',
  );
}

class AlertAssetModel extends NamedRefModel {
  const AlertAssetModel({
    required super.id,
    required super.nameEn,
    required super.nameAr,
    required this.code,
  });

  final String code;

  factory AlertAssetModel.fromJson(Map<String, dynamic> json) =>
      AlertAssetModel(
        id: json['id'] as String,
        nameEn: json['nameEn'] as String? ?? '',
        nameAr: json['nameAr'] as String? ?? '',
        code: json['code'] as String? ?? '',
      );
}

class AlertLocationModel {
  const AlertLocationModel({required this.latitude, required this.longitude});

  final num latitude;
  final num longitude;

  factory AlertLocationModel.fromJson(Map<String, dynamic> json) =>
      AlertLocationModel(
        latitude: json['latitude'] as num,
        longitude: json['longitude'] as num,
      );
}

/// A row of `GET /alerts/history`. `company` is not read: it is always null
/// for the Level 2 users the app serves.
class AlertHistoryItemModel {
  const AlertHistoryItemModel({
    required this.id,
    required this.occurredAt,
    required this.asset,
    required this.alertType,
    required this.alertNameEn,
    required this.alertNameAr,
    required this.triggeredValueEn,
    required this.triggeredValueAr,
    this.location,
  });

  final String id;

  /// ISO 8601, UTC.
  final String occurredAt;
  final AlertAssetModel asset;
  final String alertType;
  final String alertNameEn;
  final String alertNameAr;
  final String triggeredValueEn;
  final String triggeredValueAr;
  final AlertLocationModel? location;

  factory AlertHistoryItemModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    return AlertHistoryItemModel(
      id: json['id'] as String,
      occurredAt: json['occurredAt'] as String,
      asset: AlertAssetModel.fromJson(json['asset'] as Map<String, dynamic>),
      alertType: json['alertType'] as String,
      alertNameEn: json['alertNameEn'] as String? ?? '',
      alertNameAr: json['alertNameAr'] as String? ?? '',
      triggeredValueEn: json['triggeredValueEn'] as String? ?? '',
      triggeredValueAr: json['triggeredValueAr'] as String? ?? '',
      location: location == null ? null : AlertLocationModel.fromJson(location),
    );
  }
}

/// `meta` of a paginated response.
class PageMetaModel {
  const PageMetaModel({
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  final int totalCount;
  final int currentPage;
  final int totalPages;

  factory PageMetaModel.fromJson(Map<String, dynamic> json) => PageMetaModel(
    totalCount: json['totalCount'] as int? ?? 0,
    currentPage: json['currentPage'] as int? ?? 1,
    totalPages: json['totalPages'] as int? ?? 0,
  );
}

class AlertHistoryPageModel {
  const AlertHistoryPageModel({required this.items, required this.meta});

  final List<AlertHistoryItemModel> items;
  final PageMetaModel meta;

  factory AlertHistoryPageModel.fromJson(Map<String, dynamic> json) =>
      AlertHistoryPageModel(
        items: (json['data'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(AlertHistoryItemModel.fromJson)
            .toList(growable: false),
        meta: PageMetaModel.fromJson(
          json['meta'] as Map<String, dynamic>? ?? const {},
        ),
      );
}

/// `data` of `GET /alerts/history/:historyId`: the row plus `details`, kept
/// as raw JSON because its shape depends on `details.type`.
class AlertHistoryDetailsModel {
  const AlertHistoryDetailsModel({required this.item, this.details});

  final AlertHistoryItemModel item;
  final Map<String, dynamic>? details;

  factory AlertHistoryDetailsModel.fromJson(Map<String, dynamic> json) =>
      AlertHistoryDetailsModel(
        item: AlertHistoryItemModel.fromJson(json),
        details: json['details'] as Map<String, dynamic>?,
      );
}
