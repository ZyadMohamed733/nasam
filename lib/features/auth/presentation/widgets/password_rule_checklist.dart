import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/password_rules.dart';

/// The live "what is still missing" list under a new-password field.
///
/// Renders every rule at all times, met or not, rather than only the
/// outstanding ones: a list that shrinks as you type moves the fields under
/// your cursor, and you cannot see what you have already satisfied.
class PasswordRuleChecklist extends StatelessWidget {
  const PasswordRuleChecklist({
    super.key,
    required this.rules,
    required this.matches,
  });

  final PasswordRules rules;
  final bool matches;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final rule in PasswordRule.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.p4),
            child: _RuleRow(label: _label(context, rule), met: rules.has(rule)),
          ),
        _RuleRow(label: context.l10n.passwordRuleMatches, met: matches),
      ],
    );
  }

  String _label(BuildContext context, PasswordRule rule) {
    final l10n = context.l10n;
    return switch (rule) {
      PasswordRule.minLength => l10n.passwordRuleMinLength(
        PasswordRules.minLength,
      ),
      PasswordRule.uppercase => l10n.passwordRuleUppercase,
      PasswordRule.lowercase => l10n.passwordRuleLowercase,
      PasswordRule.digit => l10n.passwordRuleDigit,
      PasswordRule.specialCharacter => l10n.passwordRuleSpecialCharacter,
    };
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final colour = met ? semantic.successText : semantic.failText;

    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: AppSizes.iconSm,
          color: colour,
          // Colour alone must not carry the state — the label below is
          // announced with it, so the icon itself adds nothing for a reader.
          semanticLabel: null,
        ),
        const SizedBox(width: AppSizes.p8),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(color: colour),
          ),
        ),
      ],
    );
  }
}
