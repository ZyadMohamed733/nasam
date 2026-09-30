import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';
import 'hit_target.dart';

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
    this.isRequired = false,
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
  }) : _search = false,
       searchColors = null,
       clearTooltip = null,
       searchIcon = null;

  /// The design's search component (`647:8276`): a 40-tall filled box with a
  /// search icon at the start and, once there is a query, a clear button at
  /// the end that empties [controller] and reports `''` to [onChanged].
  ///
  /// No label, helper or validation. The box is drawn 40 tall inside a 48
  /// touch target, so place it with 4 less space above and below than the
  /// design shows. The spare 4 on each side is the field's, not a gap.
  const AppTextField.search({
    super.key,
    required TextEditingController this.controller,
    this.hint,
    this.onChanged,
    this.focusNode,
    this.clearTooltip,
    this.searchColors,
    this.searchIcon,
    this.textInputAction = TextInputAction.search,
  }) : _search = true,
       label = null,
       isRequired = false,
       helperText = null,
       validator = null,
       keyboardType = TextInputType.text,
       obscureText = false,
       prefixIcon = null,
       suffixIcon = null,
       errorText = null,
       readOnly = false,
       enabled = true,
       maxLines = 1,
       forceLtr = false,
       autofillHints = null,
       inputFormatters = null;

  final bool _search;

  /// The search variant's colours. Defaults to the semantic tokens.
  final AppSearchFieldColors? searchColors;

  /// The search variant's clear button.
  final String? clearTooltip;

  /// The search variant's leading icon, an SVG asset. Defaults to the
  /// design's magnifier.
  final String? searchIcon;

  /// The drawn box of the search variant, for tests that measure it.
  static const searchBoxKey = ValueKey('app-text-field-search-box');

  final String? label;

  /// Appends the design's red asterisk to the label. It marks the field as
  /// required to a sighted reader; the semantics flag is what says so to
  /// everyone else.
  final bool isRequired;

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

/// The colours of [AppTextField.search].
@immutable
class AppSearchFieldColors {
  const AppSearchFieldColors({
    required this.fill,
    required this.border,
    required this.icon,
    required this.text,
  });

  AppSearchFieldColors.fallback(AppSemanticColors s)
    : fill = s.containerBackground,
      border = s.containerBorder,
      icon = s.iconSecondary,
      text = s.textColor;

  final Color fill;
  final Color border;
  final Color icon;

  /// Typed text. The hint is this at half opacity, as the design draws it.
  final Color text;
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  FocusNode? _ownFocusNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    _ownFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget._search) return _searchField(context);
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
          Semantics(
            label: widget.label,
            child: Text.rich(
              TextSpan(
                text: widget.label,
                children: widget.isRequired
                    ? [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: semantic.failText),
                        ),
                      ]
                    : null,
              ),
              style: context.textTheme.labelMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppSizes.p8),
        ],
        _input(context, field, semantic, hasError: error != null),
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
        fillColor: enabled ? semantic.containerBackground : semantic.hover,
        // Vertical padding is what sizes the drawn box, and 12 is not a taste
        // decision: bodyMedium is 16 on a 20/16 line, so its line box is 20,
        // and 20 + 2*12 is the design's 44. Setting a BoxConstraints minHeight
        // instead grows the decorator without growing the painted container,
        // which is how this shipped as a 28-tall outline floating in a 44 slot.
        // Padding still gives way to a larger text scale rather than clipping.
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p8,
          vertical: AppSizes.p12,
        ),
        // Without this the decorator imposes a 48 interactive minimum on the
        // suffix and the password field ends up 4 taller than every other
        // field on the form. The button keeps its own 32-wide tap target.
        suffixIconConstraints: const BoxConstraints(
          minWidth: AppSizes.iconButtonSmall,
          minHeight: AppSizes.p24,
          maxHeight: AppSizes.inputHeight,
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
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: AppSizes.iconButtonSmall,
                  minHeight: AppSizes.p24,
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

  /// The search variant. The [TextField] fills the whole 48-tall touch target,
  /// so its semantics node and its tap area are both 48; the 40-tall box is
  /// drawn behind it.
  Widget _searchField(BuildContext context) {
    final semantic = context.semanticColors;
    final colors =
        widget.searchColors ?? AppSearchFieldColors.fallback(semantic);
    final controller = widget.controller!;
    final style = context.textTheme.labelLarge?.copyWith(color: colors.text);
    final none = InputBorder.none;
    final iconFilter = ColorFilter.mode(colors.icon, BlendMode.srcIn);
    return SizedBox(
      height: kMinInteractiveDimension,
      child: ListenableBuilder(
        listenable: Listenable.merge([controller, _focusNode]),
        builder: (context, _) {
          final hasQuery = controller.text.isNotEmpty;
          final focused = _focusNode.hasFocus;
          return Stack(
            children: [
              Positioned.fill(
                child: Center(
                  // Keeps a neighbour's extended touch target off the box.
                  child: HitTargetExtender.obstacle(
                    child: DecoratedBox(
                      key: AppTextField.searchBoxKey,
                      decoration: BoxDecoration(
                        color: colors.fill,
                        border: Border.all(
                          color: focused ? semantic.primary : colors.border,
                          width: focused ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSizes.searchFieldRadius,
                        ),
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        height: AppSizes.searchFieldHeight,
                      ),
                    ),
                  ),
                ),
              ),
              TextField(
                controller: controller,
                focusNode: _focusNode,
                textInputAction: widget.textInputAction,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.center,
                style: style,
                onChanged: widget.onChanged,
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  border: none,
                  enabledBorder: none,
                  focusedBorder: none,
                  disabledBorder: none,
                  errorBorder: none,
                  focusedErrorBorder: none,
                  contentPadding: EdgeInsetsDirectional.only(
                    end: hasQuery ? 0 : AppSizes.searchFieldPaddingH,
                  ),
                  hintText: widget.hint,
                  hintStyle: style?.copyWith(
                    color: colors.text.withValues(alpha: .5),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: AppSizes.searchFieldPaddingH,
                      end: AppSizes.searchFieldIconGap,
                    ),
                    child: SvgPicture.asset(
                      widget.searchIcon ?? AppAssets.poiSearch,
                      width: AppSizes.searchFieldIcon,
                      height: AppSizes.searchFieldIcon,
                      colorFilter: iconFilter,
                      excludeFromSemantics: true,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(),
                  suffixIcon: hasQuery
                      ? IconButton(
                          tooltip: widget.clearTooltip,
                          // Its ink stays inside the 40-tall box.
                          splashRadius: AppSizes.searchFieldHeight / 2,
                          onPressed: () {
                            controller.clear();
                            widget.onChanged?.call('');
                          },
                          icon: SvgPicture.asset(
                            AppAssets.poiClose,
                            width: AppIconSize.small.value,
                            height: AppIconSize.small.value,
                            colorFilter: iconFilter,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
