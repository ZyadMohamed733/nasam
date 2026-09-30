import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';

/// A form label (`82:13525`): 14 on a 20 line, with the design's red
/// asterisk after it when the field is required.
class AppFormLabel extends StatelessWidget {
  const AppFormLabel(this.text, {super.key, this.isRequired = false});

  final String text;
  final bool isRequired;

  static const double gap = 4;

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    final style = context.textTheme.bodySmall?.copyWith(color: s.textColor);
    return Row(
      children: [
        Flexible(child: Text(text, style: style)),
        if (isRequired) ...[
          const SizedBox(width: gap),
          ExcludeSemantics(
            child: Text('*', style: style?.copyWith(color: s.failText)),
          ),
        ],
      ],
    );
  }
}

/// The design's form field (`85:352`): an [AppFormLabel], 8 below it a
/// white input with a 1px border and radius 8, at least 44 tall.
///
/// The input's text is inset 16 by 12 — the design's 8/4 padding around an
/// 8-padded text wrap — so a one-line field is 20 + 2×12 = 44. [valueStyle]
/// sets the typed text: POI names and notes are Bold 14, coordinates
/// Regular 12.
///
/// The label and input are one semantics node, and tapping the label focuses
/// the input, so the field's touch target includes its label.
class AppFormField extends StatefulWidget {
  const AppFormField({
    super.key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.hint,
    this.valueStyle,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.minLines,
    this.maxLines = 1,
    this.forceLtr = false,
    this.enabled = true,
    this.inputKey,
  });

  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final String? hint;
  final TextStyle? valueStyle;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int? maxLines;

  /// Pins the text and hint to LTR — coordinates, codes.
  final bool forceLtr;
  final bool enabled;

  /// On the drawn input, for tests that measure it.
  final Key? inputKey;

  static const double labelGap = 8;
  static const double inputHeight = 44;
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  @override
  State<AppFormField> createState() => _AppFormFieldState();
}

class _AppFormFieldState extends State<AppFormField> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    final style =
        widget.valueStyle ??
        context.textTheme.bodySmall?.copyWith(color: s.textColor);
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r8),
          borderSide: BorderSide(color: color, width: width),
        );
    final direction = widget.forceLtr ? TextDirection.ltr : null;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: widget.enabled ? _focus.requestFocus : null,
            child: AppFormLabel(widget.label, isRequired: widget.isRequired),
          ),
          const SizedBox(height: AppFormField.labelGap),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppFormField.inputHeight,
            ),
            child: TextFormField(
              key: widget.inputKey,
              controller: widget.controller,
              focusNode: _focus,
              enabled: widget.enabled,
              validator: widget.validator,
              onChanged: widget.onChanged,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              textDirection: direction,
              // Pinned-LTR text still lines up with the ambient start: right
              // in Arabic, as the design draws coordinates.
              textAlign: widget.forceLtr
                  ? (Directionality.of(context) == TextDirection.rtl
                        ? TextAlign.right
                        : TextAlign.left)
                  : TextAlign.start,
              style: style?.copyWith(
                color: widget.enabled ? style.color : s.textPlaceholder,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: s.containerBackground,
                contentPadding: AppFormField.contentPadding,
                hintText: widget.hint,
                hintTextDirection: direction,
                hintStyle: style?.copyWith(
                  color: s.textPlaceholder,
                  fontWeight: FontWeight.w400,
                ),
                errorStyle: context.textTheme.labelSmall?.copyWith(
                  color: s.failText,
                ),
                errorMaxLines: 2,
                border: border(s.containerBorder),
                enabledBorder: border(s.containerBorder),
                disabledBorder: border(s.containerBorder),
                focusedBorder: border(s.primary, 1.5),
                errorBorder: border(s.failText),
                focusedErrorBorder: border(s.failText, 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A form field that opens a chooser (`539:13769`): an [AppFormLabel], 8
/// below it a 40-tall box with an optional leading glyph, the value — or the
/// placeholder — and a down chevron at the end.
///
/// The whole block, label included, is one button, so its target is the
/// label and box together (72 at the design's text scale).
class AppSelectField extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.onTap,
    this.value,
    this.leading,
    this.isRequired = false,
    this.errorText,
    this.boxKey,
  });

  final String label;
  final String placeholder;
  final VoidCallback? onTap;

  /// Null shows [placeholder].
  final String? value;

  /// 24 square, at the start of the box.
  final Widget? leading;
  final bool isRequired;
  final String? errorText;

  /// On the drawn box, for tests that measure it.
  final Key? boxKey;

  static const double boxHeight = 40;
  static const double leadingInset = 16;
  static const double leadingGap = 12;
  static const double chevronBox = 32;
  static const double chevron = 16;
  static const double chevronInset = 8;

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    final text = context.textTheme;
    final error = errorText;
    final radius = BorderRadius.circular(AppSizes.r8);
    final shape = RoundedRectangleBorder(
      borderRadius: radius,
      side: BorderSide(color: error == null ? s.containerBorder : s.failText),
    );
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppFormLabel(label, isRequired: isRequired),
              const SizedBox(height: AppFormField.labelGap),
              Material(
                key: boxKey,
                color: s.containerBackground,
                shape: shape,
                child: InkWell(
                  onTap: onTap,
                  customBorder: shape,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: boxHeight),
                    child: Row(
                      children: [
                        const SizedBox(width: leadingInset),
                        if (leading != null) ...[
                          IconTheme.merge(
                            data: IconThemeData(color: s.textColor),
                            child: SizedBox.square(
                              dimension: AppSizes.iconMd,
                              child: leading,
                            ),
                          ),
                          const SizedBox(width: leadingGap),
                        ],
                        Expanded(
                          child: Text(
                            value ?? placeholder,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(
                              color: value == null
                                  ? s.textPlaceholder
                                  : s.textColor,
                            ),
                          ),
                        ),
                        SizedBox.square(
                          dimension: chevronBox,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: chevron,
                            color: s.textPlaceholder,
                          ),
                        ),
                        const SizedBox(width: chevronInset),
                      ],
                    ),
                  ),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: AppSizes.p4),
                Text(
                  error,
                  style: text.labelSmall?.copyWith(color: s.failText),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
