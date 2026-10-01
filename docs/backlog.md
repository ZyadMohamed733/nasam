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

### POI sheet states the design does not draw
The POI sheet follows "POI – open" (`647:8266`), the only sheet state in the
design. Three things in the app have no design source:
- **Selected row.** A row whose point is selected on the map fills with
  `bluePurple25` at 50% (`PoiSheetColors.rowSelectedFill`). The row component
  (`507:16775`) has no selected variant.
- **Close icon.** The design's header link reads "عرض" (show). The open sheet
  shows a close icon in the same 33×20 box instead, so there is a way back.
- **Icon picker selection and row height.** The picker (`647:8257`) has no
  selected row. The current icon takes the same provisional fill
  (`rowSelectedFill`) and is announced as selected. Its rows are 48 apart,
  the touch minimum, where the design spaces them 43.75.
- **Dark mode.** Every `PoiSheetColors.dark` value
  (`lib/core/theme/poi_sheet_colors.dart`) is marked `AWAITING DESIGN`.

**To close:** design supplies the selected row, the open-state header action
and the dark sheet, then update `PoiSheetColors` and regenerate
`test/features/poi/goldens/`.

### Latitude and longitude order
The design contradicts itself: Create and Edit (`539:13754`) put latitude at
the start (the right in RTL), View (`553:4510`) puts longitude there. The app
puts latitude first on all three, for one reading order across the flow.
**To close:** design confirms latitude first, and updates View's frame to
match.

### POI bulk upload: states and copy the design does not cover
- **A chosen file.** No frame shows the Upload step after a file is picked
  (the Attachment component, `561:5443`, has only its empty variant). The
  app shows a row under the drop zone: file icon, name, size and a remove
  button, on the table fill (`PoiImportFileRow`).
- **The drop zone's hint.** The design says "PDF، DOC، XLS، PNG، JPG بحد أقصى
  25 ميجابايت لكل ملف" (`561:5451`), which is wrong for this flow. The app
  states `.xlsx` and 20 MB from `PoiLimits`.

**To close:** design draws the chosen-file state and corrects the hint.

### Dark secondary buttons on a container
In dark mode `AppButton`'s secondary variant draws `secondaryButtonText`
(`neutral400`) on `secondaryButtonBackground` (10% white). On the page
background that is 5.8:1; on `containerBackground` (`neutral800`), where the
POI sheet's upload and download buttons sit, it is 3.6:1, under AA for their
12sp labels. `test/features/poi/poi_accessibility_test.dart` checks text
contrast in light only because of this.
**To close:** design picks dark secondary-button tokens that pass on a
container, or a container variant; then add dark to that test's contrast
check.

### Secondary grey text under AA
The design sets secondary text in `#818181` (`neutral600`, the
`textPlaceholder` token): page and card subtitles at 14, info value labels at
10, field placeholders. On white that is 3.9:1, under WCAG AA's 4.5:1 for text
that size. The shared form components (`AppPageHeader`, `AppFormCard`,
`AppInfoValue`, `AppFormField`) keep the design's colour, so their tests and
the POI form/view accessibility tests check tap targets but not text contrast.
**To close:** design darkens the secondary grey (`neutral700`, `#616161`, is
6.2:1) or confirms the exception; then add `textContrastGuideline` back to
those tests.

### Form and view tokens awaiting dark design
`AppSemanticColors.dark` values for `pageTitle`, `infoValueSurface`,
`cardShadow` and `actionIcon` are marked `AWAITING DESIGN`.
**To close:** design supplies them.

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
