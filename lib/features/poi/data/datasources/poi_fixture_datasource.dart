import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/poi_model.dart';
import 'poi_datasource.dart';

/// Temporary fixture binding, matching tracking until a POI API is supplied.
/// This is sample data, not a server-backed collection or persistent storage.
class PoiFixtureDataSource implements PoiDataSource {
  PoiFixtureDataSource({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;
  final AssetBundle _bundle;
  List<PoiModel>? _points;
  Future<List<PoiModel>>? _loading;
  @override
  Future<List<PoiModel>> getPoints() async {
    try {
      final points = _points ??= await (_loading ??= _read());
      return List.unmodifiable(points);
    } finally {
      _loading = null;
    }
  }

  Future<List<PoiModel>> _read() async {
    final json =
        jsonDecode(await _bundle.loadString('assets/fixtures/poi/points.json'))
            as Map<String, dynamic>;
    return (json['data'] as List)
        .map((e) => PoiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PoiModel> save(PoiModel point, {required bool create}) async {
    await getPoints();
    final index = _points!.indexWhere((p) => p.id == point.id);
    if (!create && index < 0) {
      throw ServerException(message: 'POI not found', code: '404');
    }
    if (create && index >= 0) {
      throw ServerException(message: 'Duplicate POI ID', code: '409');
    }
    if (create) {
      _points!.add(point);
    } else {
      _points![index] = point;
    }
    return point;
  }

  @override
  Future<void> delete(String id) async {
    await getPoints();
    if (!_points!.any((p) => p.id == id)) {
      throw ServerException(message: 'POI not found', code: '404');
    }
    _points!.removeWhere((p) => p.id == id);
  }

  @override
  Future<int> importPoints(List<PoiModel> points) async {
    await getPoints();
    final known = _points!
        .map(
          (p) => '${p.name.trim().toLowerCase()}|${p.latitude}|${p.longitude}',
        )
        .toSet();
    final accepted = <PoiModel>[];
    for (final point in points) {
      if (known.add(
        '${point.name.trim().toLowerCase()}|${point.latitude}|${point.longitude}',
      )) {
        accepted.add(point);
      }
    }
    _points!.addAll(accepted);
    return accepted.length;
  }
}
