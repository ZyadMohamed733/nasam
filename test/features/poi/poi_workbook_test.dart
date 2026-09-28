import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/poi/data/services/poi_workbook.dart';
import 'package:nasam/features/poi/domain/entities/poi_import_row.dart';
import 'package:nasam/features/poi/domain/entities/point_of_interest.dart';

void main() {
  const valid = ['محطة <الوقود> & =1', '24.8', '46.4', 'fuel', 'Notes\nline 2'];
  test('export is readable XLSX preserving Arabic and literal text', () {
    final rows = [PoiWorkbook.headers, valid];
    expect(PoiWorkbook.decode(PoiWorkbook.encode(rows)), rows);
  });
  test(
    'valid, invalid and duplicate rows are separated including existing POIs',
    () {
      final rows = PoiImportValidation.validate(
        [
          PoiWorkbook.headers,
          valid,
          valid,
          ['bad', 'NaN', '181', 'fuel', ''],
          ['unknown icon', '20', '40', 'other', ''],
          ['existing', '20', '40', 'location', ''],
        ],
        [
          const PointOfInterest(
            id: '1',
            name: 'Existing',
            latitude: 20,
            longitude: 40,
          ),
        ],
      );
      expect(rows.map((r) => r.status), [
        PoiRowStatus.valid,
        PoiRowStatus.duplicate,
        PoiRowStatus.invalid,
        PoiRowStatus.invalid,
        PoiRowStatus.duplicate,
      ]);
    },
  );
  test('reordered columns work; missing/duplicate headers are rejected', () {
    final rows = PoiImportValidation.validate([
      ['icon', 'longitude', 'name', 'latitude'],
      ['hospital', '40', 'Hospital', '20'],
    ], []);
    expect(rows.single.status, PoiRowStatus.valid);
    expect(
      () => PoiImportValidation.validate([
        ['name', 'latitude'],
        ['n', '20'],
      ], []),
      throwsFormatException,
    );
    expect(
      () => PoiImportValidation.validate([
        ['name', 'latitude', 'longitude', 'icon', 'icon'],
        valid,
      ], []),
      throwsFormatException,
    );
  });
  test(
    'workbook limits reject empty, oversized and more than 5000 records',
    () {
      expect(() => PoiWorkbook.decode(Uint8List(0)), throwsFormatException);
      expect(
        () => PoiWorkbook.decode(Uint8List(PoiWorkbook.maxBytes + 1)),
        throwsFormatException,
      );
      final bytes = PoiWorkbook.encode([
        PoiWorkbook.headers,
        ...List.filled(5001, valid),
      ]);
      expect(() => PoiWorkbook.decode(bytes), throwsFormatException);
    },
  );
  test('reads numeric cells/shared strings and rejects formula cells', () {
    Uint8List workbook(String cell) {
      final original = ZipDecoder().decodeBytes(
        PoiWorkbook.encode([PoiWorkbook.headers, valid]),
      );
      final zip = Archive();
      for (final file in original) {
        if (file.name == 'xl/worksheets/sheet1.xml') {
          final xml =
              '<worksheet><sheetData><row><c r="A1" t="s"><v>0</v></c></row><row>$cell</row></sheetData></worksheet>';
          final data = utf8.encode(xml);
          zip.addFile(ArchiveFile(file.name, data.length, data));
        } else {
          zip.addFile(file);
        }
      }
      final shared = utf8.encode('<sst><si><t>name</t></si></sst>');
      zip.addFile(ArchiveFile('xl/sharedStrings.xml', shared.length, shared));
      return Uint8List.fromList(ZipEncoder().encode(zip));
    }

    expect(PoiWorkbook.decode(workbook('<c r="A2"><v>24.8</v></c>')), [
      ['name'],
      ['24.8'],
    ]);
    expect(
      () => PoiWorkbook.decode(workbook('<c r="A2"><f>1+1</f><v>2</v></c>')),
      throwsFormatException,
    );
  });
}
