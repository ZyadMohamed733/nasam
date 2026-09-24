/// Every route the app has, as a constant or a typed builder.
///
/// Call sites use these and never spell a path: a parameterised route built
/// by string interpolation at the call site is how an id ends up unencoded, or
/// a query parameter misspelt, in one place out of five.
class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';

  // The password reset flow, in the order it is walked.
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/verify-code';
  static const String newPassword = '/new-password';
  static const String passwordResetSuccess = '/password-reset-success';

  static const String home = '/';
  static const String error = '/error';

  /// Route patterns for the tracking screens, nested under [home] so opening one
  /// directly builds home → details → playback as its back stack. Relative, as
  /// go_router requires for child routes.
  static const String assetDetailsPattern = 'assets/:$assetIdParam';
  static const String assetPlaybackPattern = 'playback';
  static const String assetIdParam = 'assetId';

  /// The playback range, as ISO dates.
  static const String fromDateParam = 'from';
  static const String toDateParam = 'to';

  /// Where to carry on after signing in. Named apart from the playback
  /// dates so a return target that is itself a playback link keeps its own
  /// `from`/`to` intact inside this one value.
  static const String returnToParam = 'returnTo';

  /// `/assets/<id>`. The id is encoded, so an id with a slash or a space still
  /// lands on this route rather than on some other path.
  static String assetDetails(String assetId) =>
      '/assets/${Uri.encodeComponent(assetId)}';

  /// `/assets/<id>/playback`, with an optional `from`/`to` range as ISO dates.
  static String assetPlayback(String assetId, {DateTime? from, DateTime? to}) {
    final query = {
      if (from != null) fromDateParam: isoDate(from),
      if (to != null) toDateParam: isoDate(to),
    };
    return Uri(
      path: '${assetDetails(assetId)}/playback',
      queryParameters: query.isEmpty ? null : query,
    ).toString();
  }

  /// `/login?returnTo=<target>`: sign in, then carry on to [target].
  static String loginReturningTo(String target) =>
      Uri(path: login, queryParameters: {returnToParam: target}).toString();

  /// `/verify-code?returnTo=<target>`, so the return target survives the second
  /// factor as well as the first.
  static String otpVerificationReturningTo(String? target) => Uri(
    path: otpVerification,
    queryParameters: target == null ? null : {returnToParam: target},
  ).toString();

  /// `YYYY-MM-DD`, the form the playback range travels in.
  static String isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
