import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';

/// The design's one-time-code block: a row of boxed digit fields, an expiry
/// countdown, the submit action and a resend link, in that order.
///
/// The boxes are [Pinput]. It was a hand-rolled row of single-character
/// `TextField`s, which meant owning focus advance, backspace-to-previous and
/// paste-spreading by hand — and still not having SMS autofill, cursor
/// animation, or a single accessible field rather than five unlabelled ones.
/// What is kept here is what the design specifies: the sizes, the per-state
/// colours, and the order of the three things under the boxes.
///
/// The row follows the ambient [Directionality]. Under Arabic that means the
/// first box is the rightmost and the code fills right to left, which is how
/// the design draws a partly-entered code.
class AppOtpInput extends StatefulWidget {
  const AppOtpInput({
    super.key,
    this.length = 5,
    this.validity = const Duration(minutes: 3, seconds: 30),
    this.onCompleted,
    this.onChanged,
    this.onResend,
    this.errorText,
    this.action,
  });

  final int length;

  /// How long the code is good for. The countdown starts when the widget is
  /// first built and restarts whenever [onResend] fires.
  final Duration validity;

  /// Called once every box is filled.
  final ValueChanged<String>? onCompleted;

  final ValueChanged<String>? onChanged;

  /// Called when the user asks for a new code. Null disables the action.
  final VoidCallback? onResend;

  final String? errorText;

  /// The submit button. It sits between the countdown and the resend link, so
  /// the block owns the order rather than the page assembling it around this
  /// widget and getting it wrong.
  final Widget? action;

  @override
  State<AppOtpInput> createState() => _AppOtpInputState();
}

class _AppOtpInputState extends State<AppOtpInput> {
  late final TextEditingController _controller;
  Timer? _timer;
  late Duration _remaining;

  /// Measured from the design: 52 square, 8 radius.
  static const double _boxSize = 52.0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _remaining = widget.validity;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _remaining = widget.validity);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() => _remaining = Duration.zero);
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  bool get _expired => _remaining == Duration.zero;

  static String _format(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  PinTheme _theme(BuildContext context, {required Color border, Color? text}) {
    final semantic = context.semanticColors;
    return PinTheme(
      width: _boxSize,
      height: _boxSize,
      textStyle: context.textTheme.displaySmall?.copyWith(
        color: text ?? semantic.primary,
      ),
      decoration: BoxDecoration(
        color: semantic.containerBackground,
        borderRadius: BorderRadius.circular(AppSizes.r8),
        border: Border.all(color: border),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final hasError = widget.errorText != null;

    final empty = _theme(context, border: semantic.containerBorder);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Pinput(
          length: widget.length,
          controller: _controller,
          // spaceBetween rather than a separator: the boxes are a fixed 52 and
          // the card width varies, so the slack belongs in the gaps.
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          defaultPinTheme: empty,
          followingPinTheme: empty,
          focusedPinTheme: _theme(
            context,
            border: hasError ? semantic.failText : semantic.primary,
          ),
          // A filled box carries the brand colour, which is what separates it
          // from an empty one at a glance.
          submittedPinTheme: _theme(context, border: semantic.primary),
          errorPinTheme: _theme(
            context,
            border: semantic.failText,
            text: semantic.failText,
          ),
          // Pinput defaults to no formatters, so a numeric keyboard is the
          // only thing keeping letters out — and that is a suggestion, not a
          // guarantee: a paste or a hardware keyboard walks straight past it.
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          forceErrorState: hasError,
          // The error is drawn below with the rest of the block's copy, so
          // Pinput must not draw its own underneath the boxes as well.
          errorBuilder: (_, _) => const SizedBox.shrink(),
          onChanged: widget.onChanged,
          onCompleted: widget.onCompleted,
        ),
        const SizedBox(height: AppSizes.p16),
        _Countdown(remaining: _remaining, expired: _expired, format: _format),
        if (hasError) ...[
          const SizedBox(height: AppSizes.p8),
          Text(
            widget.errorText!,
            textAlign: TextAlign.center,
            style: context.textTheme.labelSmall?.copyWith(
              color: semantic.failText,
            ),
          ),
        ],
        if (widget.action != null) ...[
          const SizedBox(height: AppSizes.p16),
          widget.action!,
        ],
        const SizedBox(height: AppSizes.p8),
        _ResendRow(onResend: widget.onResend, restart: _startCountdown),
      ],
    );
  }
}

/// The expiry line, with the clock picked out in the fail colour.
///
/// The time is found inside the translated sentence rather than the sentence
/// being split in the ARB, so the two languages can put the clock wherever
/// their grammar wants it without the widget caring.
class _Countdown extends StatelessWidget {
  const _Countdown({
    required this.remaining,
    required this.expired,
    required this.format,
  });

  final Duration remaining;
  final bool expired;
  final String Function(Duration) format;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final base = context.textTheme.labelLarge?.copyWith(
      color: semantic.textPlaceholder,
    );

    if (expired) {
      return Text(
        context.l10n.otpExpired,
        textAlign: TextAlign.center,
        style: base?.copyWith(color: semantic.failText),
      );
    }

    final clock = format(remaining);
    final sentence = context.l10n.otpExpiresIn(clock);
    final at = sentence.indexOf(clock);

    if (at < 0) {
      return Text(sentence, textAlign: TextAlign.center, style: base);
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: sentence.substring(0, at)),
          TextSpan(text: clock, style: TextStyle(color: semantic.failText)),
          TextSpan(text: sentence.substring(at + clock.length)),
        ],
      ),
      textAlign: TextAlign.center,
      style: base,
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({required this.onResend, required this.restart});

  final VoidCallback? onResend;
  final VoidCallback restart;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final l10n = context.l10n;
    final enabled = onResend != null;

    // A Wrap, not a Row: the prompt and its action are one sentence, and it
    // does not fit a phone-width card in every language.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          l10n.otpNotReceived,
          style: context.textTheme.labelLarge?.copyWith(
            color: semantic.textPlaceholder,
          ),
        ),
        const SizedBox(width: AppSizes.p4),
        TextButton(
          onPressed: enabled
              ? () {
                  onResend!.call();
                  restart();
                }
              : null,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            l10n.otpResend,
            style: context.textTheme.labelLarge?.copyWith(
              color: enabled ? semantic.secondary : semantic.textPlaceholder,
              decoration: TextDecoration.underline,
              decorationColor: enabled
                  ? semantic.secondary
                  : AppColors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
