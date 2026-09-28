import 'package:flutter/widgets.dart';

import '../errors/failures.dart';
import '../extensions/context_extensions.dart';

/// What to show the user for a [Failure].
///
/// Failures that carry the backend's own message — a rejected code, an
/// unknown account, a password the policy refuses, a rate limit — show it
/// as it is: it is specific, and `x-lang` has already put it in the user's
/// language. Failures the app describes itself (no connection, a timeout, a
/// server fault, a response it cannot use) get the localized message
/// instead of the mapper's English fallback.
extension FailureL10n on Failure {
  String resolve(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      NetworkFailure() => l10n.errorNetwork,
      TimeoutFailure() => l10n.errorTimeout,
      UnknownFailure() || CacheFailure() => l10n.errorGeneric,
      ServerFailure(:final code)
          when code == null ||
              int.tryParse(code) == null ||
              int.parse(code) >= 500 =>
        l10n.errorGeneric,
      _ => message,
    };
  }
}
