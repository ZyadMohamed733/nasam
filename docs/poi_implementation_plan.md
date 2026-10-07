# POI implementation and verification

Branch: `codex/poi`, from `feature/tracking-onboard`.

## Design analysis

The local `Nasam _ Mobile (2).fig` contains page **UI Mobile**, section **POI** (`647:7878`). The user's PNG exports in `Nasam _ Mobile (1)` supply the visual references. They replaced the blocked Figma MCP access for this task. Screenshots establish the visible flow; unprovided prototype transitions are implemented according to the actions shown.

| Screen | Node | Implemented flow |
|---|---|---|
| POI landing | `647:8022` | Home drawer → map, layers/zoom, search, draggable list, actions |
| Create | `647:7879` | Name, location, coordinates, icon, notes → validate → save |
| Details | `647:7898` | Map preview, fields, fullscreen map, edit, delete |
| Map | `647:7915` | Tap or drag pin → confirm location; read-only details view |
| Edit | `647:7930` | Same form seeded from ID → save → refreshed details/list |
| Upload | `647:7950` | Template download → select XLSX → validate |
| Validation | `647:7969` | All/valid/invalid/duplicate filters, reasons, paginated table |
| Preview | `647:7988` | Valid rows only → confirm |
| Confirmation | `647:8007` | Actual imported/skipped/total counts → map |
| Delete/menu/icons | `647:8236`, `647:8250`, `647:8257` | Cancel/confirm delete, row actions, four icon choices |

## Completed implementation steps

1. **Shared Home navigation.** Extracted the existing AdvancedDrawer into HomeScaffold. نقاط الاهتمام is enabled beside لوحة التتبع. An IndexedStack retains visited feature state; POI loads lazily. Drawer back closes it first; POI root back selects tracking.
2. **Routes.** `/?view=poi` selects POI within Home. This keeps `/assets/:assetId` and playback back stacks intact. Child routes `/poi/create`, `/poi/import`, `/poi/:poiId`, and `/poi/:poiId/edit` carry `view=poi`. Cold child links build POI Home underneath them. Authentication uses the existing route guard.
3. **Feature architecture.** Data source → model/mapper → repository with `Either<Failure,T>` → use cases → Cubits → presentation. DI is registered in the POI feature's dependencies file. Native file selection/export has a domain interface (`PoiFiles`). Repository change notifications refresh mounted lists after mutations, including direct-link edits.
4. **Landing.** Dynamic map markers, normal/hybrid layers, zoom, search, empty/error/retry states, measured draggable sheet, create/import/export and point actions. Search and selection are independent of tracking.
5. **CRUD.** Shared create/edit form, required name and finite coordinates, icon picker, fullscreen location selection, notes, dirty-draft discard dialog, loading/failure/missing-ID states, guarded submissions and delete confirmation.
6. **Spreadsheet flow.** XLSX read/write, native open/save dialogs, downloadable template, 20 MB / 5,000-row limits from the screenshot, staged validation/preview/confirmation, duplicate suppression and actual import counts. Parsing runs in an isolate. Preview table scrolls horizontally and pages ten rows at a time.
7. **Design assets/styles.** Five POI SVGs extracted from local canvas geometry and registered in AppAssets. Shared map icons remain reused. `design_exports/poi/resolved_styles.json` preserves resolved node properties and library references; the README records scope/provenance. The app uses its existing theme, semantic colors, Almarai typography, AppCard, AppButton, AppTextField and AppBottomSheet.

## Data contract and current limits

POI follows the existing tracking fixture binding. Changes are **in memory for this app process**, shared between screens; they are not persisted across restart or sent to a server. No POI backend endpoints or request contract were supplied. Replace the `PoiDataSource` binding to integrate the eventual API; retain validation and UI/use-case contracts.

The sample points are fixture locations around Jeddah, not a live customer collection. Maps use their coordinates; they do not use the design's map screenshot as a background.

Provisional form rules: name 1–200 trimmed characters, latitude −90…90, longitude −180…180, notes up to 2,000 characters. These constraints supplement the visual design and should be aligned with the backend contract.

Template columns: `name`, `latitude`, `longitude`, `icon`, `notes`. Icon values: `location`, `hospital`, `library`, `fuel`. First worksheet only; inline/shared strings and numeric values are supported. Formulas are rejected rather than evaluated. Duplicate identity is trimmed case-insensitive name plus numeric latitude/longitude, checked against existing points and within the file. Invalid and duplicate rows stay visible during validation; only valid rows are imported.

## Responsive behavior

Map remains full bleed; sheets/forms are capped at 600 logical pixels and import content at 800. Actions and coordinate fields stack on narrow or enlarged-text layouts. Safe areas, keyboard insets, Arabic RTL, English LTR, dark mode and reduced motion use the app's existing conventions. Long validation rows use bounded cells with horizontal scrolling.

## Verification

- POI repository/Cubit tests: create/edit/delete, duplicate submissions, missing IDs, atomic invalid batches, duplicate imports, selection/search and failed refresh behavior.
- XLSX tests: Arabic/literal-text round trip, numeric/shared cells, column reordering, missing/duplicate headers, oversized files/record limits and formula rejection.
- Real router tests: Home switching/state retention, drawer/system back, cold POI links, CRUD refresh, draft cancellation, unknown IDs and all import stages; existing asset/playback/auth return paths retained.
- Widget layout matrix: 320×568, 402×874, 800×1024 and 844×390; Arabic/English; light/dark; 1.5 text scale. Landing, editor, details and upload/validation/preview/completion tested.
- Arabic landing/expanded/create/upload golden renders inspected. Widget tests use a fake map surface; live Google Maps tiles and native file-dialog interactions still require device QA.
- **101 focused tests passed**, covering the POI suite, real router, registered assets, drawer/session drawer and affected tracking interactions.
- **iOS dev simulator build passed** after the final changes, including native file-picker integration.
- **Flutter analyze:** no errors/warnings; eight existing import-order informational notices in unrelated playback/tracking/test/tool files.
- Existing tracking golden suite: **32 passed, 16 expanded-card baselines failed**. A representative failure reproduces with the original HEAD TrackingPage at the same 8.93% pixel difference, showing existing card icon/spacing changes relative to the stored image. Collapsed tracking and drawer visuals pass. Baselines were not updated for these unrelated differences.

## Remaining integration work

- Supply and connect the production POI API/persistence contract.
- Device QA for actual map gestures/tiles and native file open/save dialogs.
- Product confirmation of the provisional field limits, workbook columns and duplicate identity before connecting production data.
