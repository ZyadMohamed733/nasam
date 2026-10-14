# Geofence

The feature uses a typed domain model and `GeofenceRepository` as the boundary
between the presentation layer and data. `GeofenceFixtureDataSource` reads the
`assets/fixtures/geofence/` JSON envelope on first access, keeps it in memory,
and simulates a 300 ms request. Replace its DI binding with the API datasource
when that contract is available. The datasource owns fixture loading and
create/update/delete behavior; the repository maps models, validates drafts,
maps exceptions to failures, and publishes changes.

`GeofenceEditorCubit` owns the wizard draft across all five steps. Details use
the same cubit to load a route ID; the editor route creates a separate cubit
and loads the same record for edits. The Home destination lazily mounts and
retains its list/map cubit when visited.

Fixtures use `{ "data": [...] }` envelopes. Geofences store a `shape` object
(`polygon` points or a `circle` center/radius), schedule (`always` or `specific`),
color enum name, asset IDs, and settings. Asset options have `id`, `name`, and
`code` fields.

Open design questions are the dark palette for geofence swatches, drawing-tool
states, the preferred asset picker presentation, and the detailed speed/time
monitoring rules.
