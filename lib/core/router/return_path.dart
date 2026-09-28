import 'app_routes.dart';

/// Where to go after signing in, validated.
///
/// The target arrives in a query parameter anyone can write, so it is treated
/// as untrusted: only an in-app path is accepted. Anything that could leave
/// the app — a scheme, a host, a protocol-relative `//host`, a backslash that
/// some parsers read as a separator — is rejected, as are the sign-in screens
/// themselves, which would loop. A rejected target is not an error; the user
/// just lands on home.
abstract final class ReturnPath {
  /// Routes that make no sense to return to after signing in.
  static const _excluded = {
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.forgotPassword,
    AppRoutes.resetCode,
    AppRoutes.otpVerification,
    AppRoutes.newPassword,
    AppRoutes.passwordResetSuccess,
  };

  /// [raw] if it is a safe in-app path, else null.
  static String? sanitize(String? raw) {
    if (raw == null) return null;
    // Checked before trimming: trim() strips control characters at the ends,
    // which would launder a smuggled newline into a clean-looking path.
    if (raw.codeUnits.any((c) => c < 0x20 || c == 0x7f)) return null;
    final value = raw.trim();
    if (value.isEmpty || value.length > 2048) return null;
    if (!value.startsWith('/') || value.startsWith('//')) return null;
    if (value.contains(r'\')) return null;

    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    if (uri.hasScheme || uri.hasAuthority || uri.userInfo.isNotEmpty) {
      return null;
    }
    if (_excluded.contains(uri.path)) return null;
    return uri.toString();
  }
}
