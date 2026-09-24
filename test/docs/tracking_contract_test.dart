import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/tracking_contract.dart' as contract;

/// The API contract doc is generated from the fixtures; a fixture change
/// that is not re-rendered would leave the API team reading stale shapes.
void main() {
  test('docs/api/tracking_contract.md matches the fixtures', () {
    expect(
      File(contract.docPath).readAsStringSync(),
      contract.render(),
      reason: 'run: dart run tool/tracking_contract.dart',
    );
  });

  test('the new time-in-status field is flagged for the API team', () {
    expect(
      contract.render(),
      contains('| `statusDurationSeconds` | number | optional | **New.** |'),
    );
  });
}
