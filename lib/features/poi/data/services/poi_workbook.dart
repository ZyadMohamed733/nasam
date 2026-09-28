import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

/// Minimal XLSX interchange contract: first worksheet, plain cell values.
/// No formulas, macros or external links are evaluated. Runs in an isolate.
abstract final class PoiWorkbook {
  static const maxBytes = 20 * 1024 * 1024;
  static const maxRows = 5000;
  static const headers = ['name', 'latitude', 'longitude', 'icon', 'notes'];
  static List<List<String>> decode(Uint8List bytes) {
    if (bytes.length > maxBytes || bytes.isEmpty) {
      throw const FormatException('Workbook size');
    }
    final zip = ZipDecoder().decodeBytes(bytes);
    if (zip.length > 256 ||
        zip.fold<int>(0, (n, f) => n + f.size) > 64 * 1024 * 1024) {
      throw const FormatException('Expanded workbook size');
    }
    XmlDocument read(String name) {
      final file = zip.findFile(name);
      if (file == null) throw const FormatException('Missing workbook part');
      return XmlDocument.parse(utf8.decode(file.content));
    }

    final shared = <String>[];
    if (zip.findFile('xl/sharedStrings.xml') != null) {
      for (final item in read('xl/sharedStrings.xml').findAllElements('si')) {
        shared.add(item.findAllElements('t').map((e) => e.innerText).join());
      }
    }
    final workbook = read('xl/workbook.xml');
    final first = workbook.findAllElements('sheet').first;
    final relationId = first.getAttribute('r:id');
    final relations = read(
      'xl/_rels/workbook.xml.rels',
    ).findAllElements('Relationship');
    final relation = relations.firstWhere(
      (e) => e.getAttribute('Id') == relationId,
    );
    if (relation.getAttribute('TargetMode') == 'External') {
      throw const FormatException('External worksheet');
    }
    final target = relation.getAttribute('Target')!;
    if (target.contains('..')) throw const FormatException('Invalid worksheet');
    final path = target.startsWith('/') ? target.substring(1) : 'xl/$target';
    final rows = <List<String>>[];
    for (final row in read(path).findAllElements('row')) {
      final values = <int, String>{};
      for (final cell in row.findElements('c')) {
        final ref = cell.getAttribute('r') ?? '';
        final column = RegExp(r'^[A-Z]+').stringMatch(ref);
        if (column == null) throw const FormatException('Cell reference');
        var index = 0;
        for (final char in column.codeUnits) {
          index = index * 26 + char - 64;
        }
        if (index > 32) throw const FormatException('Too many columns');
        if (cell.findElements('f').isNotEmpty) {
          throw const FormatException('Use values, not formulas');
        }
        final type = cell.getAttribute('t');
        var value = cell.findElements('v').firstOrNull?.innerText ?? '';
        if (type == 's') {
          final i = int.tryParse(value);
          if (i == null || i < 0 || i >= shared.length) {
            throw const FormatException('Shared string reference');
          }
          value = shared[i];
        } else if (type == 'inlineStr') {
          value = cell.findAllElements('t').map((e) => e.innerText).join();
        }
        values[index - 1] = value;
      }
      if (values.values.every((v) => v.trim().isEmpty)) continue;
      if (rows.length >= maxRows + 1) {
        throw const FormatException('Too many records');
      }
      final width = values.keys.reduce((a, b) => a > b ? a : b) + 1;
      rows.add(List.generate(width, (i) => values[i] ?? ''));
    }
    if (rows.length < 2) throw const FormatException('No records');
    return rows;
  }

  static Uint8List encode(List<List<String>> rows) {
    String escape(String value) =>
        const HtmlEscape(HtmlEscapeMode.element).convert(value);
    final sheet = StringBuffer(
      '<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>',
    );
    for (var r = 0; r < rows.length; r++) {
      sheet.write('<row r="${r + 1}">');
      for (var c = 0; c < rows[r].length; c++) {
        final ref = '${String.fromCharCode(65 + c)}${r + 1}';
        // All strings stay strings, including text beginning with '='.
        sheet.write(
          '<c r="$ref" t="inlineStr"><is><t xml:space="preserve">${escape(rows[r][c])}</t></is></c>',
        );
      }
      sheet.write('</row>');
    }
    sheet.write('</sheetData></worksheet>');
    final parts = {
      '[Content_Types].xml':
          '<?xml version="1.0"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/></Types>',
      '_rels/.rels':
          '<?xml version="1.0"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>',
      'xl/workbook.xml':
          '<?xml version="1.0"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="POI" sheetId="1" r:id="rId1"/></sheets></workbook>',
      'xl/_rels/workbook.xml.rels':
          '<?xml version="1.0"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/></Relationships>',
      'xl/worksheets/sheet1.xml': sheet.toString(),
    };
    final archive = Archive();
    parts.forEach((name, xml) {
      final bytes = utf8.encode(xml);
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    });
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }
}
