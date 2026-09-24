# Backlog

Open items left by the tracking refactor (September 2026). Each says where it
lives in the code and what closing it takes. Nothing here blocks the current
build; everything here is a known gap, not a surprise.

## Product and design

### Map markers show status by colour alone
The vehicle markers on the map (`TrackingMarkerFactory`) carry the status only
in the arrow's colour; the label is the asset id. Everywhere else — chips,
card badges — status has an icon and a label too. Screen-reader users get
status from the fleet list, since map markers have no accessible labels, but a
colour-blind sighted user reading the map does not.
**To close:** add the status glyph (`TrackingStyle.icon`) or a short label to
the marker bitmap, then regenerate the goldens.

### Design sign-off on the status colours
`lib/core/theme/tracking_colors.dart` holds the status colours per brightness.
Each reaches WCAG AA (4.5:1) for 11sp text on its surface, including the 7%
chip tint.
- Light: the design's idle `#AC7600` (3.6:1) and stopped `#E0004D` (4.4:1)
  failed AA and were darkened to `#8A5E00` and `#C20042`. Moving `#17663A` is
  unchanged.
- Dark: `#5FD394`, `#F5C451`, `#FFA8C2` and the accent `#C9C2E8` have no design
  source; they are the light hues lifted until they pass on the dark container
  colour.

**To close:** design approves or replaces these values. Any replacement must
still pass the contrast tests in
`test/features/tracking/presentation/tracking_accessibility_test.dart`.

### Arabic copy awaiting design
36 strings in `lib/core/localization/l10n/app_ar.arb` are marked
`AWAITING DESIGN COPY`. Their Arabic is a back-translation of invented English,
not approved wording. **To close:** replace each with design copy and delete
the marker from its `@` description (`grep -n "AWAITING DESIGN COPY"`).

## Platform

### OS deep links are not configured
Asset details and playback have id-based routes that can be opened directly
(`/assets/:assetId`, `/assets/:assetId/playback?from=&to=`). A signed-out
visitor is sent through login and returned via `ReturnPath`, which accepts
in-app paths only. The OS side is missing: no Android intent filters or App
Links verification, no iOS associated domains or universal links.
**To close:** add those, then test a cold start from a real link on each
platform.

### No crash reporter
Every uncaught error, and every reported-but-handled one (such as API contract
violations and failed marker bitmaps), goes through `reportError` /
`ErrorReporter` in `lib/core/errors/error_reporter.dart`. Today that only logs,
so nothing reaches anyone from a release build.
**To close:** choose Crashlytics or Sentry and wire it in that one function
(the `TODO(nasam)` there). Nothing else needs to change.

## Backend

### Tracking API swap
Tracking data comes from `TrackingFixtureDataSource` over the JSON in
`assets/fixtures/tracking/` (the `TODO(api)` there). The contract the real
endpoints must meet is `docs/api/tracking_contract.md`, generated from those
fixtures. `statusDurationSeconds` is new, so the API team needs to hear about
it. Two open questions are listed in the contract: date-times without offsets,
and the playback `from`/`to` parameters.
**To close:** write a Dio-backed `TrackingRemoteDataSource` with the same
`@LazySingleton(as: TrackingDataSource)` binding and delete the fixture source.
Nothing above the data source changes.

### WS_URL is a placeholder
`config/dev.json`'s `WS_URL` (`wss://ws-dev.nasam.app`) is on a different domain
from the dev API (`nasam-v2-api-dev.nasam.net`), so the host check only warns
in dev (`AppConfigLoader`). The staging and prod socket URLs follow the naming
scheme but are unconfirmed.
**To close:** get the real socket hosts per environment and update
`config/<flavor>.json`. Dev can then fail on a host mismatch the way staging
and prod already do.
