import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/extensions/context_extensions.dart';
import 'animated_success_icon.dart';
import 'success_confetti.dart';

/// Reusable one-shot celebration for completed actions.
///
/// Callers supply localized copy and navigation; this widget owns only visuals.
/// Use a new key when showing a new success event in the same widget location.
class SuccessScreen extends StatefulWidget {
  const SuccessScreen({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    this.message,
    this.icon,
    this.showConfetti = true,
  });

  final String title;
  final String? message;
  final String actionLabel;
  final VoidCallback onAction;

  /// Optional artwork revealed after the circular sweep; defaults to the brand checkmark.
  final Widget? icon;
  final bool showConfetti;

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );
  late final Animation<double> _content = _controller.drive(
    CurveTween(curve: const Interval(0.44, 0.58, curve: Curves.easeOutCubic)),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.value == 0 && !_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bluePurple700,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF141332),
                  Color(0xFF30256B),
                  Color(0xFF5546AB),
                ],
              ),
            ),
          ),
          if (widget.showConfetti && !MediaQuery.disableAnimationsOf(context))
            SuccessConfetti(animation: _controller),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 48).clamp(
                      0,
                      double.infinity,
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: AnimatedBuilder(
                        animation: _content,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(0, 60 * (1 - _content.value)),
                          child: child,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSuccessIcon(icon: widget.icon),
                            const SizedBox(height: 24),
                            AnimatedBuilder(
                              animation: _content,
                              builder: (context, child) => IgnorePointer(
                                ignoring: _content.value == 0,
                                child: ExcludeSemantics(
                                  excluding: _content.value == 0,
                                  child: FadeTransition(
                                    opacity: _content,
                                    child: child,
                                  ),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      widget.title,
                                      textAlign: TextAlign.center,
                                      style: context.textTheme.displaySmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                                  ),
                                  if (widget.message != null) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      widget.message!,
                                      textAlign: TextAlign.center,
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.white70),
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: widget.onAction,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor:
                                            AppColors.bluePurple700,
                                        minimumSize: const Size(0, 44),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        textStyle: context.textTheme.labelLarge,
                                      ),
                                      child: Text(
                                        widget.actionLabel,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
