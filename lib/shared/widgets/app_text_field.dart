import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';

/// The design's text input, built as the fixed-height block the design draws.
///
/// The block is a 8pt-gapped column: a 20pt label row, the 44pt input, and an
/// 11pt helper line. That comes to [AppSizes.inputBlockHeight] (72) without
/// helper text and [AppSizes.inputBlockWithHelper] (91) with it, which is what
/// lets a form lay out to the design's spacing without measuring children.
///
/// Those totals are what the block measures at the design's own text scale,
/// not a cap on it. The label and helper rows are sized by their text and the
/// input has a 44pt *minimum*, so the block grows when the user raises the
/// system font size. Pinning the rows to 20 and 11 instead was tried and
/// clips: every size in the type scale is a `.sp`, so it scales with the
/// device and the accessibility setting while a hard-coded box does not, and
/// Arabic — which sits taller in its line box than Latin — loses its top half
/// first.
///
/// Holding those heights means the input cannot render its own helper and
/// error text — `InputDecorator` grows to fit that, and the block stops being
/// 72. So validation lives in an enclosing [FormField] and the message is
/// drawn on the block's own helper line. `Form`, `validate()` and `reset()`
/// behave exactly as they would with a `TextFormField`.
///
/// Alignment is deliberately not overridden anywhere: the design's stack
/// alignment is MAX, which is what `start` already resolves to under RTL.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.forceLtr = false,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
  });

  final String? label;
  final String? hint;

  /// Drawn on the helper line when there is no error. Its presence is what
  /// makes the block 91 rather than 72.
  final String? helperText;

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  /// An error supplied from outside — a server-side rejection, usually. Takes
  /// precedence over the validator's message.
  final String? errorText;

  final bool readOnly;
  final bool enabled;
  final int maxLines;

  /// Pins the field to LTR for content that is never RTL in this domain:
  /// plate numbers, IMEIs, VINs, phone numbers, coordinates, email.
  final bool forceLtr;

  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.controller?.text ?? '',
      validator: widget.validator,
      enabled: widget.enabled,
      // The block draws its own message, so the field never auto-validates
      // into a layout change.
      builder: (field) {
        final error = widget.errorText ?? field.errorText;
        return _block(context, field, error);
      },
    );
  }

  Widget _block(
    BuildContext context,
    FormFieldState<String> field,
    String? error,
  ) {
    final semantic = context.semanticColors;
    final message = error ?? widget.helperText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: context.textTheme.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.p8),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.inputHeight),
          child: _input(context, field, semantic, hasError: error != null),
        ),
        if (message != null) ...[
          const SizedBox(height: AppSizes.p8),
          Text(
            message,
            style: context.textTheme.labelSmall?.copyWith(
              color: error != null
                  ? semantic.failText
                  : semantic.textPlaceholder,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _input(
    BuildContext context,
    FormFieldState<String> field,
    AppSemanticColors semantic, {
    required bool hasError,
  }) {
    final enabled = widget.enabled;

    OutlineInputBorder border(Color color, [double width = 1.0]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r8),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      obscureText: _obscureText,
      readOnly: widget.readOnly,
      enabled: enabled,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      // Left null so Flutter infers direction per content: forcing it from the
      // app locale mis-renders plate numbers, IMEIs and emails.
      textDirection: widget.forceLtr ? TextDirection.ltr : null,
      style: context.textTheme.bodyMedium?.copyWith(
        color: enabled ? semantic.textColor : semantic.textPlaceholder,
      ),
      onChanged: (value) {
        field.didChange(value);
        widget.onChanged?.call(value);
      },
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        // The design has no dedicated disabled fill; `hover` is the palette's
        // subtle neutral and reads as inert against the page.
        fillColor: enabled
            ? semantic.containerBackground
            : semantic.hover,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p8,
          vertical: AppSizes.p4,
        ),
        hintText: widget.hint,
        // `textDirection` above governs typed text only; the hint is laid out
        // by InputDecorator in the ambient directionality. Without this, a
        // plate-number hint of "1234 ABC" is bidi-reordered to "ABC 1234"
        // inside an Arabic build — the placeholder then shows a format the
        // field will not produce.
        hintTextDirection: widget.forceLtr ? TextDirection.ltr : null,
        hintStyle: context.textTheme.bodyMedium?.copyWith(
          color: semantic.textPlaceholder,
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: AppSizes.iconSm,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : widget.suffixIcon,
        border: border(semantic.containerBorder),
        enabledBorder: border(
          hasError ? semantic.failText : semantic.containerBorder,
        ),
        focusedBorder: border(
          hasError ? semantic.failText : semantic.primary,
          1.5,
        ),
        disabledBorder: border(semantic.containerBorder),
      ),
    );
  }
}
