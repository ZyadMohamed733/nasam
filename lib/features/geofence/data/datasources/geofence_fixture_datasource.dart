import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/geofence_model.dart';
import 'geofence_datasource.dart';

/// TODO(api): Replace this fixture binding with the API implementation; the repository and UI contract stay unchanged.
class GeofenceFixtureDataSource implements GeofenceDataSource {
  GeofenceFixtureDataSource({this.latency = const Duration(milliseconds: 300)});
  final Duration latency;
  List<GeofenceModel>? _items;
  List<Map<String, dynamic>>? _assets;
  Future<void> _wait() => Future<void>.delayed(latency);
  Future<void> _load() async {
    if (_items != null) return;
    final payload = jsonDecode(await rootBundle.loadString('assets/fixtures/geofence/geofences.json')) as Map<String, dynamic>;
    _items = ((payload['data'] as List).cast<Map<String, dynamic>>()).map(GeofenceModel.fromJson).toList();
  }
  @override Future<List<GeofenceModel>> getGeofences() async { await _wait(); await _load(); return List.unmodifiable(_items!); }
  @override Future<GeofenceModel> getGeofence(String id) async { await _wait(); await _load(); return _items!.firstWhere((e) => e.id == id, orElse: () => throw const ServerException(message: 'Geofence not found', code: '404')); }
  @override Future<GeofenceModel> save(GeofenceModel model, {required bool create}) async {
    await _wait(); await _load();
    final index = _items!.indexWhere((e) => e.id == model.id);
    if (create && index >= 0) throw const ServerException(message: 'Duplicate geofence id', code: '409');
    if (!create && index < 0) throw const ServerException(message: 'Geofence not found', code: '404');
    if (create) { _items!.add(model); } else { _items![index] = model; }
    return model;
  }
  @override Future<void> delete(String id) async { await _wait(); await _load(); if (!_items!.any((e) => e.id == id)) throw const ServerException(message: 'Geofence not found', code: '404'); _items!.removeWhere((e) => e.id == id); }
  @override Future<List<Map<String, dynamic>>> getAssetOptions() async {
    await _wait();
    if (_assets == null) { final payload = jsonDecode(await rootBundle.loadString('assets/fixtures/geofence/asset_options.json')) as Map<String, dynamic>; _assets = (payload['data'] as List).cast<Map<String, dynamic>>(); }
    return List.unmodifiable(_assets!);
  }
}
