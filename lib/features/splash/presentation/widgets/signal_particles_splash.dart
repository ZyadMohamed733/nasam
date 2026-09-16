import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_logo.dart';

/// Plays the bundled particle assembly and dissolve once before continuing.
class SignalParticlesSplash extends StatefulWidget {
  const SignalParticlesSplash({super.key, required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<SignalParticlesSplash> createState() => _SignalParticlesSplashState();
}

class _SignalParticlesSplashState extends State<SignalParticlesSplash> {
  // The four-second GIF contains 99 frames (one duplicate was merged).
  // Finish after its last frame is displayed, not four seconds after starting
  // to load: decoding on slower devices must not cut off the animation.
  static const _lastFrame = 98;
  static const _lastFrameDuration = Duration(milliseconds: 40);

  Timer? _completionTimer;
  bool _completionScheduled = false;
  bool _assetsWarmed = false;

  void _completeAfterFrame() {
    if (_completionScheduled) return;
    _completionScheduled = true;
    _completionTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onCompleted();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_assetsWarmed) {
      _assetsWarmed = true;
      unawaited(precacheImage(const AssetImage(AppAssets.logoMark), context));
      unawaited(
        precacheImage(const AssetImage(AppAssets.splashBackground), context),
      );
    }
    if (MediaQuery.disableAnimationsOf(context)) _completeAfterFrame();
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bluePurple700,
      child: SizedBox.expand(
        child: MediaQuery.disableAnimationsOf(context)
            ? const Center(child: AppLogo(size: AppLogoSize.large))
            : Image.asset(
                AppAssets.splashParticles,
                fit: BoxFit.cover,
                semanticLabel: 'Nasam',
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame != null &&
                      frame >= _lastFrame &&
                      !_completionScheduled &&
                      _completionTimer == null) {
                    _completionTimer = Timer(
                      _lastFrameDuration,
                      _completeAfterFrame,
                    );
                  }
                  return child;
                },
                errorBuilder: (context, error, stackTrace) {
                  _completeAfterFrame();
                  return const Center(child: AppLogo(size: AppLogoSize.large));
                },
              ),
      ),
    );
  }
}
