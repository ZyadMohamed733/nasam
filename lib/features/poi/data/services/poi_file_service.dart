import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/poi_limits.dart';
import '../../domain/entities/point_of_interest.dart';
import '../../domain/repositories/poi_files.dart';
import 'poi_workbook.dart';

@LazySingleton(as: PoiFiles)
class PoiFileService implements PoiFiles {
  @override
  Future<PickedPoiWorkbook?> pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
      allowMultiple: false,
    );
    if (result == null) return null;
    final file = result.files.single;
    final bytes = file.bytes;
    if (!file.name.toLowerCase().endsWith('.xlsx') ||
        file.size > PoiLimits.maxFileBytes ||
        bytes == null) {
      throw const FormatException('Invalid XLSX file');
    }
    final rows = await compute(PoiWorkbook.decode, bytes);
    return PickedPoiWorkbook(file.name, rows, size: file.size);
  }

  @override
  Future<bool> save({List<PointOfInterest>? points}) async {
    final rows = [
      PoiWorkbook.headers,
      if (points == null)
        ['Example POI', '24.695299', '46.695299', 'fuel', '']
      else
        for (final p in points)
          [p.name, '${p.latitude}', '${p.longitude}', p.icon.name, p.notes],
    ];
    final Uint8List bytes = await compute(PoiWorkbook.encode, rows);
    final path = await FilePicker.platform.saveFile(
      fileName: points == null ? 'POI-template.xlsx' : 'POIs.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      bytes: bytes,
    );
    return path != null;
  }
}
