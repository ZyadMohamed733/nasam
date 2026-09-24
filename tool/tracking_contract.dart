// Renders docs/api/tracking_contract.md from the tracking fixtures.
//
//   dart run tool/tracking_contract.dart          # rewrite the doc
//   dart run tool/tracking_contract.dart --check  # exit 1 if it is stale
//
// The fixtures under assets/fixtures/tracking/ are the working contract
// until the tracking API exists. Field names, JSON types and optionality are
// read from them, never typed here, so the doc cannot drift from what the
// app is actually tested against. Whether a field is optional is decided by
// the app's own models: each is parsed with the field removed, and if that
// still parses, the field is optional. What neither can say — paths, the
// enum sets the client accepts, what is new — is declared below.

import 'dart:convert';
import 'dart:io';

import 'package:nasam/features/tracking/data/models/asset_details_model.dart';
import 'package:nasam/features/tracking/data/models/notification_model.dart';
import 'package:nasam/features/tracking/data/models/playback_segment_model.dart';
import 'package:nasam/features/tracking/data/models/tracked_asset_model.dart';
import 'package:nasam/features/tracking/data/models/vehicle_model.dart';

const fixtureRoot = 'assets/fixtures/tracking';
const docPath = 'docs/api/tracking_contract.md';

/// Fields added to the contract after it was first shared with the API team.
const newFields = {'statusDurationSeconds'};

/// Values the client maps; anything else is rejected as a format error.
const enums = {
  'status': ['MOVING', 'IDLE', 'STOPPED', 'OFFLINE'],
  'type': ['SPEEDING', 'STOPPED', 'GEOFENCE'],
};

class Endpoint {
  const Endpoint(
    this.method,
    this.path,
    this.fixture, {
    required this.summary,
    required this.parse,
    this.keyedById = false,
    this.single = false,
    this.query = const {},
  });

  final String method;
  final String path;
  final String fixture;
  final String summary;

  /// The app's model for one entry; used to probe which fields it requires.
  final Object Function(Map<String, dynamic>) parse;

  /// The fixture holds one response per asset id, keyed by that id.
  final bool keyedById;

  /// The response `data` is one entry of the fixture's list, not the list.
  final bool single;
  final Map<String, String> query;
}

const endpoints = [
  Endpoint(
    'GET',
    '/tracking/vehicles',
    'vehicles.json',
    summary: 'Every vehicle position, for the map.',
    parse: VehicleModel.fromJson,
  ),
  Endpoint(
    'GET',
    '/tracking/assets',
    'assets.json',
    summary: 'Every tracked asset, for the fleet list.',
    parse: TrackedAssetModel.fromJson,
  ),
  Endpoint(
    'GET',
    '/tracking/assets/:id',
    'assets.json',
    single: true,
    summary: 'One asset, for a screen opened by id. Unknown id: 404.',
    parse: TrackedAssetModel.fromJson,
  ),
  Endpoint(
    'GET',
    '/tracking/assets/:id/details',
    'asset_details.json',
    keyedById: true,
    single: true,
    summary: "The details screen's tabs. Unknown id: 404.",
    parse: AssetDetailsModel.fromJson,
  ),
  Endpoint(
    'GET',
    '/tracking/assets/:id/notifications',
    'asset_notifications.json',
    keyedById: true,
    summary: 'Alerts for one asset. Unknown id: 404.',
    parse: NotificationModel.fromJson,
  ),
  Endpoint(
    'GET',
    '/tracking/assets/:id/playback',
    'playback_segments.json',
    summary: 'Trip legs between two instants.',
    parse: PlaybackSegmentModel.fromJson,
    query: {
      'from': 'ISO-8601 instant, inclusive (proposed)',
      'to': 'ISO-8601 instant, inclusive (proposed)',
    },
  ),
];

final _isoDateTime = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}');

String _typeOf(Object? value) => switch (value) {
  null => 'null',
  bool() => 'boolean',
  // The models read every number as `num`, so whole or fractional is the
  // server's choice; the doc does not promise one the app does not need.
  num() => 'number',
  String() when _isoDateTime.hasMatch(value) => 'string (date-time)',
  String() => 'string',
  List() => 'array',
  Map() => 'object',
  _ => value.runtimeType.toString(),
};

/// Whether [parse] still accepts [entry] with [key] removed.
bool _parsesWithout(
  Object Function(Map<String, dynamic>) parse,
  Map<String, dynamic> entry,
  String key,
) {
  try {
    parse(Map.of(entry)..remove(key));
    return true;
  } catch (_) {
    return false;
  }
}

/// One row per field across [entries]: its type(s), and whether the app's
/// model accepts it being absent (or a fixture already leaves it out).
List<String> _fieldRows(
  List<Map<String, dynamic>> entries,
  Object Function(Map<String, dynamic>) parse,
) {
  final keys = <String>{for (final e in entries) ...e.keys};
  final rows = <String>[];
  for (final key in keys) {
    final present = entries.where((e) => e[key] != null).toList();
    final types = {for (final e in present) _typeOf(e[key])};
    final optional =
        present.length < entries.length ||
        _parsesWithout(parse, entries.first, key);
    final notes = [
      if (newFields.contains(key)) '**New.**',
      if (enums[key] case final values?)
        'One of ${values.map((v) => '`$v`').join(', ')}.',
    ].join(' ');
    rows.add(
      '| `$key` | ${types.join(' \\| ')} | ${optional ? 'optional' : 'required'} | $notes |',
    );
  }
  return rows;
}

Map<String, dynamic> _read(String file) =>
    jsonDecode(File('$fixtureRoot/$file').readAsStringSync())
        as Map<String, dynamic>;

/// The `data` payloads of [e]'s fixture, flattened to entries.
List<Map<String, dynamic>> _entries(Endpoint e) {
  final json = _read(e.fixture);
  final responses = e.keyedById
      ? json.values.cast<Map<String, dynamic>>()
      : [json];
  return [
    for (final response in responses)
      for (final item in switch (response['data']) {
        final List<dynamic> list => list,
        final Map<String, dynamic> one => [one],
        _ => throw FormatException('${e.fixture}: no data envelope'),
      })
        item as Map<String, dynamic>,
  ];
}

String render() {
  final out = StringBuffer()
    ..writeln('# Tracking API contract')
    ..writeln()
    ..writeln(
      '<!-- Generated by `dart run tool/tracking_contract.dart` from '
      '`$fixtureRoot/`. Do not edit by hand; change the fixtures or the '
      'script. -->',
    )
    ..writeln()
    ..writeln(
      'What the app expects from the tracking backend, which does not exist '
      'yet. Until it does, the app reads these same shapes from the fixtures '
      'in `$fixtureRoot/` (`TrackingFixtureDataSource`), so every field '
      'below is exercised by the models, mapper and tests exactly as the '
      'real responses will be.',
    )
    ..writeln()
    ..writeln('## Envelope')
    ..writeln()
    ..writeln(
      'Every success is `200` with the payload under `data`, like the auth '
      'endpoints:',
    )
    ..writeln()
    ..writeln('```json')
    ..writeln('{ "data": [ … ] }   // list endpoints')
    ..writeln('{ "data": { … } }   // single-object endpoints')
    ..writeln('```')
    ..writeln()
    ..writeln(
      'Types are JSON types. "Optional" means the app parses the object with '
      'the field absent or `null` (falling back to an empty or zero value, or '
      'showing nothing); "required" means it rejects the response without '
      'it. A field the app does not know is ignored.',
    )
    ..writeln()
    ..writeln('## Endpoints')
    ..writeln();

  for (final e in endpoints) {
    out
      ..writeln('### `${e.method} ${e.path}`')
      ..writeln()
      ..writeln(e.summary)
      ..writeln();
    if (e.query.isNotEmpty) {
      out.writeln('Query parameters:');
      e.query.forEach((k, v) => out.writeln('- `$k`: $v'));
      out.writeln();
    }
    out
      ..writeln(
        e.single ? '`data`: one object:' : '`data`: an array of objects, each:',
      )
      ..writeln()
      ..writeln('| Field | Type | | Notes |')
      ..writeln('|---|---|---|---|');
    _fieldRows(_entries(e), e.parse).forEach(out.writeln);
    out
      ..writeln()
      ..writeln('Fixture: `$fixtureRoot/${e.fixture}`')
      ..writeln();
  }

  out
    ..writeln('## Enums')
    ..writeln()
    ..writeln(
      'The client maps exactly these values and rejects anything else as a '
      'format error, so a new value needs an app release first.',
    )
    ..writeln()
    ..writeln(
      '- Vehicle and asset `status`: '
      '${enums['status']!.map((v) => '`$v`').join(', ')}',
    )
    ..writeln(
      '- Notification `type`: '
      '${enums['type']!.map((v) => '`$v`').join(', ')}',
    )
    ..writeln()
    ..writeln('## Errors')
    ..writeln()
    ..writeln(
      'Errors are the backend\'s standard NestJS body; the app reads '
      '`message` (a string, or for `400` an array of validation sentences):',
    )
    ..writeln()
    ..writeln('```json')
    ..writeln(
      '{ "statusCode": 404, "message": "No asset \\"AST-9999\\".", '
      '"error": "Not Found" }',
    )
    ..writeln('```')
    ..writeln()
    ..writeln('| Status | Meaning to the app |')
    ..writeln('|---|---|')
    ..writeln(
      '| `401` | Access token expired: refreshed once and retried; a '
      'rejected refresh ends the session. |',
    )
    ..writeln('| `403` | Not allowed: shown as a permission error. |')
    ..writeln(
      '| `404` | Unknown asset id: the screen shows "not found", not an '
      'error with retry. |',
    )
    ..writeln('| `429` | Rate limited: the `message` is shown. |')
    ..writeln('| `5xx` | Server error: shown with Retry. |')
    ..writeln()
    ..writeln(
      'Every request carries `Authorization: Bearer …`, `X-Client: mobile` '
      'and `x-tenant` (per flavor, from `AppConfig`).',
    )
    ..writeln()
    ..writeln('## Open questions')
    ..writeln()
    ..writeln(
      '- The fixtures\' date-times have no offset (`2025-10-17T09:00:00`). '
      'The API should send UTC with `Z`, or an explicit offset.',
    )
    ..writeln(
      '- Playback `from`/`to` are proposed; the app currently asks for whole '
      'days.',
    );
  return out.toString();
}

void main(List<String> args) {
  final rendered = render();
  final file = File(docPath);
  if (args.contains('--check')) {
    if (!file.existsSync() || file.readAsStringSync() != rendered) {
      stderr.writeln(
        '$docPath is stale: run dart run tool/tracking_contract.dart',
      );
      exitCode = 1;
    }
    return;
  }
  file.writeAsStringSync(rendered);
  stdout.writeln('Wrote $docPath');
}
