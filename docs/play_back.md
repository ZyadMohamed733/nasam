# Playback feature

Playback is a separate feature slice under `lib/features/play_back/`, following
the data, domain and presentation structure in [feature conventions](FEATURE_CONVENTIONS.md).

- `data/` owns the playback fixture datasource, wire model, mapper and repository.
- `domain/` owns the playback segment entity, repository contract and use case.
- `presentation/` owns the playback page, date range, cubit and widgets.

The fixture is `assets/fixtures/play_back/playback_segments.json`, registered in
`pubspec.yaml`. The route remains nested under an asset URL, and the page reuses
the tracking feature's asset lookup gate and asset summary. Tracking itself does
not own playback models, data access or state.

## Real-device response scenarios

The fixture datasource can return different responses in a debug build. Set
`deviceSegmentsScenario` and `deviceRouteScenario` near the top of
`lib/features/play_back/data/datasources/playback_fixture_datasource.dart`, then
restart the app. Each selector controls only its own request, so you can keep
the list successful while trying map states, or choose a different scenario for
each. Release builds always use the normal fixture.

Scenario names are static constants in
`lib/features/play_back/data/datasources/playback_fixture_scenarios.dart`. For
example, to test a successful list with a failing map route, configure:

```dart
static const String deviceSegmentsScenario = PlaybackFixtureScenarios.success;
static const String deviceRouteScenario = PlaybackFixtureScenarios.networkError;
```

| Scenario | What Playback receives |
| --- | --- |
| `success` | The regular fixture data. |
| `empty` | No segments and no route points. |
| `segmentsEmpty` | An empty segment list; the map route still has points. |
| `routeEmpty` | The map route is empty; the segment list still has data. |
| `serverError` | Simulated HTTP 503 for whichever selector uses this scenario. |
| `networkError` | Simulated offline/network failure for whichever selector uses it. |
| `timeout` | Simulated request timeout for whichever selector uses it. |
| `unauthorized` | Simulated HTTP 401/authentication failure. |
| `rateLimit` | Simulated HTTP 429 with a 30-second retry hint. |
| `malformedPayload` | Invalid JSON, exercising the unexpected parse-error path. |
| `unknownError` | Unexpected datasource error. |
| `slow` | Both segment and map responses succeed after 8 seconds, to inspect loading UI. |

These scenarios are debug-only. An unknown scenario name intentionally becomes
an unexpected datasource error, which helps verify the fallback UI.
