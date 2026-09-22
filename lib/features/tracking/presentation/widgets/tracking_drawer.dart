import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../tracking_style.dart';

/// Height of [_DrawerBottomAccent], carried over from the 268 (of an 874
/// total) that `drawer_bottom_background.svg`'s viewBox gave the shape in
/// the original Figma export.
const double _accentHeight = 268;

class TrackingDrawer extends StatelessWidget {
  const TrackingDrawer({super.key, this.logout});

  /// Injected in tests; resolved from the container otherwise.
  final LogoutUseCase? logout;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: TrackingStyle.drawer),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: _accentHeight,
          child: _DrawerBottomAccent(),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const AppLogo(),
                    const SizedBox(width: 8),
                    Text(
                      'NASAM',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: TrackingStyle.drawerText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: TrackingStyle.drawerText.withValues(alpha: .75),
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: TrackingStyle.drawerText,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l.trackingSearch,
                        style: const TextStyle(
                          color: TrackingStyle.drawerText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _section(l.trackingSystems),
                        _item(
                          l.trackingFleet,
                          Icons.settings_input_component_outlined,
                          expanded: true,
                        ),
                        _item(l.trackingTitle, Icons.location_on_outlined),
                        _item(l.trackingPoi, Icons.pin_drop_outlined),
                        _item(l.trackingGeofences, Icons.straighten_outlined),
                        _item(
                          l.trackingAssignments,
                          Icons.link,
                          expanded: false,
                        ),
                        const SizedBox(height: 8),
                        _section(l.trackingSettings),
                        _item(
                          l.trackingSettings,
                          Icons.settings_outlined,
                          expanded: true,
                        ),
                        _item(l.trackingSettings, Icons.settings_outlined),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _LogoutRow(
                  label: l.trackingLogout,
                  onTap: () async {
                    await (logout ?? getIt<LogoutUseCase>())();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 21,
                      backgroundColor: Color(0xFFD9D9D9),
                      child: Icon(Icons.person, color: Color(0xFF818181)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aya Al-Rashidi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF171129),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            l.trackingAdmin,
                            style: const TextStyle(
                              fontSize: 10,
                              color: TrackingStyle.drawer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _section(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: const TextStyle(fontSize: 10, color: Color(0xFFB26DBD)),
    ),
  );
  Widget _item(String text, IconData icon, {bool? expanded}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Icon(icon, size: 19, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
        if (expanded != null)
          Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 16,
            color: Colors.white,
          ),
      ],
    ),
  );
}

class _LogoutRow extends StatelessWidget {
  const _LogoutRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.logout_rounded,
            size: 19,
            color: TrackingStyle.drawerText,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: TrackingStyle.drawerText,
            ),
          ),
        ],
      ),
    ),
  );
}

/// The rounded-corner accent band pinned to the bottom of the drawer.
///
/// Reproduces only the *shape* from `drawer_bottom_background.svg` -- a
/// rectangle with just its bottom-right corner rounded. That file's actual
/// fill is an unusable `<pattern>` wrapping a base64 raster (flutter_svg
/// does not support pattern fills at all, the same issue already
/// documented on `Vector.svg`/[AppLogo]), so the raster is dropped
/// entirely and the shape is filled with [TrackingStyle.drawerBottomAccent]
/// instead -- a single, code-controlled colour.
class _DrawerBottomAccent extends StatelessWidget {
  const _DrawerBottomAccent();

  @override
  Widget build(BuildContext context) => ClipPath(
    clipper: const _DrawerBottomAccentClipper(),
    child: ColoredBox(
      color: TrackingStyle.drawerBottomAccent.withValues(alpha: .8),
    ),
  );
}

/// A rectangle with only its bottom-right corner rounded, matching the
/// `M0 0H402V236C402 253.673 387.673 268 370 268H0V0Z` path from
/// `drawer_bottom_background.svg` (402x268 viewBox -- a ~32px radius).
/// The radius is kept proportional to the clipped size rather than a fixed
/// pixel value so the shape holds together at whatever height it's given.
class _DrawerBottomAccentClipper extends CustomClipper<Path> {
  const _DrawerBottomAccentClipper();

  @override
  Path getClip(Size size) {
    final radius = size.height * (32 / 268);
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - radius)
      ..arcToPoint(
        Offset(size.width - radius, size.height),
        radius: Radius.circular(radius),
      )
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
