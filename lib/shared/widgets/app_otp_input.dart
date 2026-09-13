import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';

/// The design's one-time-code block: a row of boxed digit fields, an expiry
/// countdown and a resend action.
///
/// The digit count and the countdown are parameters rather than constants —
/// the code length and validity window are a backend decision, and the design
/// drawing a six-box row at 03:30 is an illustration of one case, not a rule.
///
/// Digits are pinned LTR. A one-time code is a number, and Arabic renders
/// numerals left-to-right inside an RTL page; letting the boxes inherit RTL
/// would put the first digit the user types on the right of the row while the
/// value reads the other way.
class AppOtpInput extends StatefulWidget {
  const AppOtpInput({
    super.key,
    this.length = 6,
    this.validity = const Duration(minutes: 3, seconds: 30),
    this.onCompleted,
    this.onChanged,
    this.onResend,
    this.errorText,
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
    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
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
    final l10n = context.l10n;

    return SizedBox(
      width: _blockWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The row itself is always LTR; see the class doc.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < widget.length; i++)
                  _digitBox(context, semantic, i),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.p16),
          Text(
            _expired
                ? l10n.otpExpired
                : l10n.otpExpiresIn(_format(_remaining)),
            style: context.textTheme.labelLarge?.copyWith(
              color: _expired ? semantic.failText : semantic.textPlaceholder,
            ),
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
          const SizedBox(height: AppSizes.p16),
          // A Wrap, not a Row: the prompt and its action are one sentence, and
          // it does not fit the design's 360pt block in every language — the
          // English pair is 439pt wide and overflowed before this.
          Wrap(
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
                onPressed: widget.onResend == null
                    ? null
                    : () {
                        widget.onResend!.call();
                        _startCountdown();
                      },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.otpResend,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: semantic.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// The design draws the block at 360x294. Width is fixed here; height is
  /// left to the content so the block still lays out when the error line
  /// appears or the user's text scale is above the default.
  static const double _blockWidth = 360.0;

  Widget _digitBox(BuildContext context, AppSemanticColors semantic, int i) {
    final hasError = widget.errorText != null;
    final filled = _controllers[i].text.isNotEmpty;

    return SizedBox(
      width: AppSizes.iconButtonMedium,
      height: AppSizes.buttonHeight,
      child: Semantics(
        label: context.l10n.otpFieldLabel(i + 1, widget.length),
        child: TextField(
          controller: _controllers[i],
          focusNode: _focusNodes[i],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: context.textTheme.bodyLarge?.copyWith(
            color: semantic.textColor,
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
