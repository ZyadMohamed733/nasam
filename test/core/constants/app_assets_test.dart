import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/constants/app_assets.dart';

/// Guards the asset registry against the failure that broke this repo before:
/// a path that exists in code but not on disk, or a file on disk that
/// pubspec.yaml never declares. Either one is a grey box at runtime, or a
/// `flutter pub get` that fails on a fresh clone. Both should fail CI instead.
void main() {
  group('AppAssets', () {
    test('every registered path exists on disk', () {
      for (final path in AppAssets.all) {
        expect(
          File(path).existsSync(),
          isTrue,
          reason: 'AppAssets lists $path but no such file exists',
        );
      }
    });

    test('every registered path is declared in pubspec.yaml', () {
      final declared = _declaredAssetEntries();
      expect(
        declared,
        isNotEmpty,
        reason: 'Could not parse any asset entries out of pubspec.yaml',
      );

      for (final path in AppAssets.all) {
        final covered = declared.any(
          (entry) => entry.endsWith('/')
              // A directory entry covers the files directly inside it, but
              // Flutter does not recurse into subdirectories.
              ? path.startsWith(entry) && !path.substring(entry.length).contains('/')
              : entry == path,
        );
        expect(
          covered,
          isTrue,
          reason:
              '$path is in AppAssets but no pubspec assets entry covers it, '
              'so it will not be bundled. Declared: $declared',
        );
      }
    });

    // Dart gives us no runtime reflection, so `all` is hand-maintained and can
    // silently fall behind. Read the source back and check it did not.
    test('all lists every path constant declared in the class', () {
      final source = File(
        'lib/core/constants/app_assets.dart',
      ).readAsStringSync();

      // Private constants are path fragments used for interpolation.
      final prefixes = <String, String>{};
      final constPattern = RegExp(
        r"static const String (\w+) =\s*'([^']*)';",
        multiLine: true,
      );
      for (final m in constPattern.allMatches(source)) {
        final name = m.group(1)!;
        if (name.startsWith('_')) prefixes[name] = m.group(2)!;
      }

      final declaredPaths = <String>[];
      for (final m in constPattern.allMatches(source)) {
        final name = m.group(1)!;
        if (name.startsWith('_')) continue;
        var value = m.group(2)!;
        prefixes.forEach((k, v) => value = value.replaceAll('\$$k', v));
        declaredPaths.add(value);
      }

      expect(
        declaredPaths,
        isNotEmpty,
        reason: 'Parsed no asset constants — has the class been restructured?',
      );
      for (final path in declaredPaths) {
        expect(
          AppAssets.all,
          contains(path),
          reason: '$path is declared in AppAssets but missing from AppAssets.all',
        );
      }
      expect(AppAssets.all, hasLength(declaredPaths.length));
    });
  });
}

/// The entries under `flutter: assets:` in pubspec.yaml, parsed without
/// pulling in a YAML dependency for one flat list of strings.
List<String> _declaredAssetEntries() {
  final lines = File('pubspec.yaml').readAsLinesSync();
  final entries = <String>[];
  var inAssets = false;

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

    if (trimmed == 'assets:') {
      inAssets = true;
      continue;
    }
    if (!inAssets) continue;

    if (trimmed.startsWith('- ')) {
      entries.add(trimmed.substring(2).trim());
    } else {
      // Any other key at any indent ends the list.
      break;
    }
  }
  return entries;
}
