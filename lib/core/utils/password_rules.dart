/// The individual rules a password has to satisfy.
///
/// `AppValidators.password` answers one question — is this acceptable — and
/// returns a single `PasswordTooWeakError` whatever the reason. That is right
/// for a field error, but a new-password screen shows a live checklist, and a
/// checklist needs to know which rules pass and which do not. This is that
/// breakdown; the two must agree, so the validator is defined in terms of it.
enum PasswordRule {
  minLength,
  uppercase,
  lowercase,
  digit,
  specialCharacter;

  /// Whether [value] satisfies this rule on its own.
  bool isSatisfiedBy(String? value) {
    if (value == null || value.isEmpty) return false;
    return switch (this) {
      PasswordRule.minLength => value.length >= PasswordRules.minLength,
      PasswordRule.uppercase => value.contains(RegExp(r'[A-Z]')),
      PasswordRule.lowercase => value.contains(RegExp(r'[a-z]')),
      PasswordRule.digit => value.contains(RegExp(r'[0-9]')),
      PasswordRule.specialCharacter => value.contains(
        RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
      ),
    };
  }
}

/// The result of checking a password against every [PasswordRule].
class PasswordRules {
  const PasswordRules(this.satisfied);

  /// Evaluates [value] against every rule.
  factory PasswordRules.of(String? value) => PasswordRules({
    for (final rule in PasswordRule.values)
      if (rule.isSatisfiedBy(value)) rule,
  });

  static const int minLength = 8;

  final Set<PasswordRule> satisfied;

  bool has(PasswordRule rule) => satisfied.contains(rule);

  bool get isValid => satisfied.length == PasswordRule.values.length;

  /// The rules still outstanding, in the order the checklist lists them.
  Iterable<PasswordRule> get unmet =>
      PasswordRule.values.where((rule) => !has(rule));
}
