import 'package:nasam/features/history_alert/data/models/histroy_alert_model.dart';

import '../models/history_alert_detailed_model.dart';

abstract interface class HistoryAlertDataSource {
  Future<List<HistoryAlertModel>> getHistoryAlert();
  Future<HistoryAlertDetailsModel> getHistoryDetailed({
    required String alertId,
  });
}
