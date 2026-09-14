import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';

/// The design's one-time-code block: a row of boxed digit fields, an expiry
/// countdown, the submit action and a resend link, in that order.
///
/// The digit count and the countdown are parameters rather than constants —
/// the code length and validity window are a backend decision, and the design
/// drawing five boxes at 03:30 is one case, not a rule.
///
/// The row follows the ambient [Directionality] rather than being pinned LTR.
/// Under Arabic that means the first box is the rightmost and the code fills
/// right to left, which is how the design draws a partly-entered code. The
/// advance logic is index-based, so it needs no direction of its own.
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
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _remaining = widget.validity;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
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

  String get _value => _controllers.map((c) => c.text).join();

  bool get _expired => _remaining == Duration.zero;

  void _onDigitChanged(int index, String value) {
    // A paste lands as several characters in one box; spread it across the row.
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < digits.length && index + i < widget.length; i++) {
        _controllers[index + i].text = digits[i];
      }
      final next = (index + digits.length).clamp(0, widget.length - 1);
      _focusNodes[next].requestFocus();
    } else if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final joined = _value;
    widget.onChanged?.call(joined);
    if (joined.length == widget.length) widget.onCompleted?.call(joined);
    setState(() {});
  }

  static String _format(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (var i = 0; i < widget.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSizes.p16),
              // Flexible rather than a fixed 52: the boxes fill the card on
              // whatever width it has, and stay square doing it.
              Expanded(child: _digitBox(context, semantic, i)),
            ],
          ],
        ),
        const SizedBox(height: AppSizes.p16),
        _Countdown(
          remaining: _remaining,
          expired: _expired,
          format: _format,
        ),
        if (widget.errorText != null) ...[
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

  Widget _digitBox(BuildContext context, AppSemanticColors semantic, int i) {
    final hasError = widget.errorText != null;
    final filled = _controllers[i].text.isNotEmpty;

    return AspectRatio(
      aspectRatio: 1,
      child: Semantics(
        label: context.l10n.otpFieldLabel(i + 1, widget.length),
        child: TextField(
          controller: _controllers[i],
          focusNode: _focusNodes[i],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: context.textTheme.displaySmall?.copyWith(
            // A filled box carries the brand colour, which is what separates
            // it from an empty one at a glance.
            color: hasError ? semantic.failText : semantic.primary,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => _onDigitChanged(i, value),
          decoration: InputDecoration(
            counterText: '',
            isDense: true,
            filled: true,
            fillColor: semantic.containerBackground,
            contentPadding: EdgeInsets.zero,
            border: _border(semantic.containerBorder),
            enabledBorder: _border(
              hasError
                  ? semantic.failText
                  : filled
                  ? semantic.primary
                  : semantic.containerBorder,
            ),
            focusedBorder: _border(
              hasError ? semantic.failText : semantic.primary,
              1.5,
            ),
          ),
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, [double width = 1.0]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.r8),
        borderSide: BorderSide(color: color, width: width),
      );
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
          TextSpan(
            text: clock,
            style: TextStyle(color: semantic.failText),
          ),
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
