import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_component_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// A horizontal progress stepper (`561:5230`): a 16dp indicator per step,
/// joined by 2dp lines, with its label under it. 36 tall, steps sharing the
/// width equally, step 1 at the start (the right in RTL).
///
/// Steps before [current] are done (a filled dot with a check), [current] is
/// active (a filled dot with a white centre), the rest are still to come (a
/// white dot with a grey centre). A [current] past the last step marks every
/// step done. The current step and those before it label in bold 14; the
/// rest in regular 12.
class AppStepper extends StatelessWidget {
  const AppStepper({super.key, required this.steps, required this.current});

  final List<String> steps;

  /// Zero-based.
  final int current;

  static const double height = 36;
  static const double paddingH = 4;
  static const double indicator = 16;
  static const double centre = 8;
  static const double check = 12;
  static const double line = 2;

  @override
  Widget build(BuildContext context) {
    final colors = AppComponentColors.of(context);
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: paddingH),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < steps.length; i++)
              Expanded(
                child: _Step(
                  label: steps[i],
                  index: i,
                  count: steps.length,
                  state: i < current
                      ? _State.done
                      : i == current
                      ? _State.active
                      : _State.todo,
                  colors: colors,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _State { done, active, todo }

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.index,
    required this.count,
    required this.state,
    required this.colors,
  });

  final String label;
  final int index, count;
  final _State state;
  final AppComponentColors colors;

  @override
  Widget build(BuildContext context) {
    final reached = state != _State.todo;
    // A step's own half-lines: the one in from the previous step and the one
    // out to the next carry the active colour once the step is reached.
    Widget half({required bool show}) => Expanded(
      child: show
          ? Container(
              height: AppStepper.line,
              color: reached ? colors.stepperActive : colors.stepperInactive,
            )
          : const SizedBox.shrink(),
    );
    final style = reached
        ? AppTextStyles.bodyMB.copyWith(color: colors.stepperDoneLabel)
        : AppTextStyles.bodySR20.copyWith(color: colors.stepperInactiveLabel);
    return Semantics(
      label: label,
      selected: state == _State.active,
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox(
              height: AppStepper.indicator,
              child: Row(
                children: [
                  half(show: index > 0),
                  _Indicator(state: state, colors: colors),
                  half(show: index < count - 1),
                ],
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: style,
            ),
          ],
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.state, required this.colors});

  final _State state;
  final AppComponentColors colors;

  @override
  Widget build(BuildContext context) {
    final filled = state != _State.todo;
    final s = context.semanticColors;
    return Container(
      width: AppStepper.indicator,
      height: AppStepper.indicator,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? colors.stepperActive : s.containerBackground,
      ),
      child: switch (state) {
        _State.done => Icon(
          Icons.check,
          size: AppStepper.check,
          color: s.primaryButtonText,
        ),
        _State.active || _State.todo => Container(
          width: AppStepper.centre,
          height: AppStepper.centre,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? s.primaryButtonText : colors.stepperInactive,
          ),
        ),
      },
    );
  }
}
