/// Every route the app has, as a constant or a typed builder.
///
/// Call sites use these and never spell a path: a parameterised route built
/// by string interpolation at the call site is how an id ends up unencoded, or
/// a query parameter misspelt, in one place out of five.
class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';

  /// Login's second factor, for accounts with 2FA.
  static const String otpVerification = '/verify-code';

  // Password recovery, in the order it is walked: email, emailed code, new
  // password, then success (which is outside the flow, so reaching it ends
  // the flow and drops its reset token).
  static const String forgotPassword = '/forgot-password';
  static const String resetCode = '/forgot-password/verify';
  static const String newPassword = '/forgot-password/new-password';
  static const String passwordResetSuccess = '/password-reset-success';

  static const String home = '/';
  static const String alertsLog = '/alerts-log';
  static const String alertDetailsPattern = ':alertId';

  /// A Home destination; query state preserves the existing asset route stack.
  static const String homeViewParam = 'view';
  static const String poiView = 'poi';
  static const String alertsView = 'alerts';
  static const String poi = '/?view=poi';
  static const String alerts = '/?view=alerts';
  static const String poiCreate = '/poi/create?view=poi';
  static const String poiImport = '/poi/import?view=poi';
  static const String poiIdParam = 'poiId';
  static const String poiDetailsPattern = 'poi/:$poiIdParam';
  static String poiDetails(String id) =>
      '/poi/${Uri.encodeComponent(id)}?view=poi';
  static String poiEdit(String id) =>
      '/poi/${Uri.encodeComponent(id)}/edit?view=poi';
  static const String error = '/error';

  /// Route patterns for the tracking screens, nested under [home] so opening one
  /// directly builds home → details → playback as its back stack. Relative, as
  /// go_router requires for child routes.
  static const String assetDetailsPattern = 'assets/:$assetIdParam';
  static const String assetPlaybackPattern = 'playback';
  static const String assetPlaybackMapPattern = 'map';
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

  /// `/alerts-log/<id>` opens one alert from the history list.
  static String alertDetails(String alertId) =>
      '$alertsLog/${Uri.encodeComponent(alertId)}';

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

  /// `/assets/<id>/playback/map`, the map view launched from the legacy summary.
  static String assetPlaybackMap(
    String assetId, {
    DateTime? from,
    DateTime? to,
  }) {
    final uri = Uri.parse(assetPlayback(assetId, from: from, to: to));
    return uri.replace(path: '${uri.path}/$assetPlaybackMapPattern').toString();
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
