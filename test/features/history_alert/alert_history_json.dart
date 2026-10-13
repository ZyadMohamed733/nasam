/// Alert History responses shaped exactly as API-CONTRACT.md documents them.
library;

Map<String, dynamic> alertJson({
  String id = 'a0000000-0000-4000-8000-000000000001',
  String occurredAt = '2026-10-13T11:47:00.000Z',
  String alertType = 'SPEED',
  Map<String, dynamic>? location = const {
    'latitude': 24.7136,
    'longitude': 46.6753,
  },
}) => {
  'id': id,
  'occurredAt': occurredAt,
  'company': null,
  'asset': {
    'id': 'b0000000-0000-4000-8000-000000000001',
    'code': 'VH-001',
    'nameEn': 'Truck 101',
    'nameAr': 'شاحنة 101',
  },
  'alertType': alertType,
  'alertNameEn': 'Speeding over 100 km/h',
  'alertNameAr': 'تجاوز السرعة 100 كم/س',
  'triggeredValueEn': '108 km/h',
  'triggeredValueAr': '108 كم/س',
  'location': location,
};

Map<String, dynamic> pageJson(
  List<Map<String, dynamic>> alerts, {
  int page = 1,
  int totalPages = 1,
  int? totalCount,
}) => {
  'data': alerts,
  'meta': {
    'totalCount': totalCount ?? alerts.length,
    'currentPage': page,
    'totalPages': totalPages,
    'firstPageUrl': '/api/v1/alerts/history?page=1&limit=20',
    'lastPageUrl': '/api/v1/alerts/history?page=$totalPages&limit=20',
    'nextPageUrl': null,
    'previousPageUrl': null,
  },
};

const speedDetailsJson = {
  'type': 'SPEED',
  'recordedSpeedKph': 108,
  'speedLimitKph': 100,
};

const sensorDetailsJson = {
  'type': 'SENSOR',
  'sensor': {
    'id': 'd0000000-0000-4000-8000-000000000001',
    'nameEn': 'Truck 101 engine temperature',
    'nameAr': 'حرارة محرك شاحنة 101',
    'sensorType': 'TEMPERATURE',
    'unit': '°C',
  },
  'triggeredValue': 112,
  'unit': '°C',
  'condition': {'operator': 'GREATER_THAN', 'value': 105},
};

const downtimeDetailsJson = {'type': 'DOWNTIME', 'durationMinutes': 45};

Map<String, dynamic> detailsJson(
  Map<String, dynamic> details, {
  Map<String, dynamic>? location = const {
    'latitude': 24.7136,
    'longitude': 46.6753,
  },
}) => {
  'data': {
    ...alertJson(alertType: details['type'] as String, location: location),
    'details': details,
  },
};
