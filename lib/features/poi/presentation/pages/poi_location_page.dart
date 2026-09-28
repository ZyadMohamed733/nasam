import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/poi_location_map.dart';

class PoiLocationPage extends StatefulWidget {
  const PoiLocationPage({
    super.key,
    required this.initial,
    this.readOnly = false,
  });
  final LatLng initial;
  final bool readOnly;
  @override
  State<PoiLocationPage> createState() => _PoiLocationPageState();
}

class _PoiLocationPageState extends State<PoiLocationPage> {
  late LatLng _point = widget.initial;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.poiLocation)),
      body: PoiLocationMap(
        point: _point,
        onChanged: widget.readOnly
            ? null
            : (point) => setState(() => _point = point),
      ),
      bottomNavigationBar: widget.readOnly
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: AppButton(
                  label: l.poiConfirmLocation,
                  onPressed: () => Navigator.of(context).pop(_point),
                ),
              ),
            ),
    );
  }
}

/// Dynamic map preview shared by the editor and detail screen.
class PoiLocationPreview extends StatelessWidget {
  const PoiLocationPreview({
    super.key,
    required this.point,
    required this.onExpand,
  });
  final LatLng point;
  final VoidCallback? onExpand;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 170,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.r8),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: PoiLocationMap(point: point, preview: true),
            ),
          ),
          PositionedDirectional(
            top: 8,
            end: 8,
            child: IconButton.filledTonal(
              tooltip: AppLocalizations.of(context)!.poiSelectLocation,
              icon: const Icon(Icons.fullscreen),
              onPressed: onExpand,
            ),
          ),
        ],
      ),
    ),
  );
}
