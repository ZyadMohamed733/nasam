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
