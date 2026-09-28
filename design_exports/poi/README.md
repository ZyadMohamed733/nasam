# POI design extraction

Source: local `Nasam _ Mobile (2).fig`, page **UI Mobile**, section **POI** (`647:7878`). Screens supplied in `Nasam _ Mobile (1)` were used for visual verification.

`resolved_styles.json` contains local node colors, typography, effects, radii, spacing and original library style references for the section and its referenced components. External library aliases are preserved; they are not claimed to be a complete Figma variable export. Application styling continues to use the existing AppTheme, semantic colors, Almarai typography and shared components.

## Extracted app vectors

| Asset | Local source | Usage |
|---|---|---|
| `assets/icons/poi_pin.svg` | Symbol `175:3902` | Location icon |
| `assets/icons/poi_fuel.svg` | Symbol `539:13710` | Fuel selector/list |
| `assets/icons/poi_hospital.svg` | Symbol `548:3820` | Hospital selector/list |
| `assets/icons/poi_library.svg` | Symbol `548:3811` | Library selector/list |
| `assets/icons/poi_fuel_marker.svg` | Marker `647:8040`, geometry blob 3021 | Fuel marker |

Vectors were recovered from the local canvas geometry, with empty component roots omitted. AppAssets registers all five. Existing map menu, notification, layers, plus and minus vectors are reused from the app.

The earlier nine-file partial MCP export remains in `../figma_poi/`. The original archive extraction and decoded POI node subset remain in `../nasam_mobile_2/`. Neither directory is a runtime dependency.
