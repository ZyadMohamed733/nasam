# Auth backend integration — implementation plan

> **Superseded:** refresh is handled by `core/auth/TokenRefresher`. The
> repository refresh method and `RefreshAccessTokenUseCase` described below
> were removed.

Source: `https://nasam-v2-api-dev.nasam.net/docs` (NestJS/Swagger, read via
`/docs-json` on 2026-09-22). Covers the six flows asked for: login, forgot
password, reset password, verify OTP, resend OTP, refresh token.

## Decisions already made (with the user)

| Question | Decision |
|---|---|
| `x-tenant` header (required on every call from a native client — a request with no `Origin` and no `x-tenant` is answered `404`) | `saudi-tracking` |
| `config/dev.json` `BASE_URL` (currently `https://api-dev.nasam.app/v1`, a different host than the real API) | Update to `https://nasam-v2-api-dev.nasam.net/api/v1`. `WS_URL` is left as a placeholder; `AppConfigLoader.hostsAgree` is relaxed so a mismatched WS host doesn't crash startup — WebSocket wiring is a separate task |
| Password reset completion (`forget-password` emails a **link with a token**, not an OTP; there is no "verify code → get token" endpoint) | **Web-only for now.** The app calls `forget-password` and shows a "check your email" confirmation. The link is opened and completed on the web; no in-app new-password screen is wired to it yet. The existing `resetPassword(resetToken, newPassword)` plumbing is still implemented against the real endpoint (data/domain layers), just not reachable from a route today — ready for deep-linking later |

## What "verify OTP" / "resend OTP" actually are

This is the one place the request's plain-language description and the real
API diverge, worth stating up front: `verify-otp` / `resend-otp` are the
**second factor of login**, not part of password reset.

- `POST /auth/login` with a correct password on a 2FA-enabled account returns
  `{ requiresOtp: true }` and **no tokens**. It is not an error — it's a normal
  200.
- `POST /auth/verify-otp` (`username` + 6-digit `code`) finishes signing in:
  tokens + user come back, same shape as a non-2FA login.
- `POST /auth/resend-otp` (`username`) sends a fresh code; the login attempt
  it belongs to expires in 30 minutes.
- The 6-digit code, resend cooldown (60s) and hourly send budget (3/hour,
  escalating cooldown after) are **shared** between the code `login` sends and
  the code `resend-otp` sends — a `429` from one means the other is also
  spent, and the client must not treat "go back and log in again" as a way
  around it.

The app already has an OTP-entry screen (`AppOtpInput`, `OtpVerificationPage`,
`OtpCubit`), built against a *mocked* password-reset flow. It is repurposed
for login 2FA rather than rebuilt — see "Presentation layer" below.

## API reference

Base path: `/api/v1`. All auth endpoints also accept `x-lang: en|ar` (defaults
`en`) for translated error/success copy — send the app's current locale.

### `POST /auth/login`
Request `LoginDto`: `{ username: string(3-50), password: string }`.
Header: `X-Client: mobile` (see below).

200, one of:
```jsonc
{ "message": "...", "data": { "requiresOtp": false, "accessToken": "...", "refreshToken": "...", "user": { ... } } }
{ "message": "...", "data": { "requiresOtp": true } }
```
`refreshToken` is only present when `X-Client: mobile` was sent — otherwise
it's an HttpOnly cookie the app can't read anyway. Always send the header.

Errors: `400` (missing `username`/`password`, `message: string[]`), `401`
(bad credentials — same message for unknown user / wrong password / inactive
account, show verbatim), `429` (2FA-code budget spent; `Retry-After` header +
minutes in `message`).

### `POST /auth/verify-otp`
Request `VerifyOtpDto`: `{ username: string, code: string(6, digits) }`.
200: same `data` shape as a non-2FA login (`accessToken`, `refreshToken` if
mobile, `user` — no `requiresOtp` field this time).
Errors: `401`, message distinguishes invalid / expired / attempts-exhausted —
**show verbatim**, and only offer "resend" for the last two.

### `POST /auth/resend-otp`
Request `ResendOtpDto`: `{ username: string }`.
200: `{ "message": "..." }`.
Errors: `400`, `401` (no login attempt in progress — send back to login),
`429` (cooldown or hourly budget; `Retry-After` header).

### `POST /auth/refresh-access-token`
Request `RefreshTokenDto`: `{ refreshToken?: string }` — a native client
always sends this (it has no cookie jar); the cookie wins if both are
present, which never happens for us.
200: `{ "data": { "accessToken": "...", "user": { ... } } }` — **note: no
`message` key, and the payload is nested one level under `data` same as
everywhere else.** Refresh token is **not rotated** — keep reusing the stored
one.
Errors: `401` (missing/invalid/revoked) → treat as session over.

### `POST /auth/logout`
Request `RefreshTokenDto` (same as above). Always `200`. Call unconditionally
on sign-out; don't gate it on having a token.

### `POST /auth/forget-password`
Request `ForgetPasswordDto`: `{ email: string }`.
200 always, same message regardless of whether the email exists (`{
"message": "If an account exists for that email address, a password reset
link has been sent to it." }`) — **never imply the address was found or not**.
Errors: `400` invalid email, `429` rate limit.

### `PATCH /auth/reset-password` *(implemented, not yet UI-reachable)*
Request `ResetPasswordDto`: `{ resetToken: string, newPassword: string }`.
200: `{ "message": "..." }`.
Errors: `400` (invalid/expired/used token, weak password, reused password).

### `user` object (returned by login / verify-otp / refresh)
```jsonc
{
  "id": "uuid", "username": "...", "email": "...",
  "nameEn": "...", "nameAr": "...",      // either may be null — fall back to username
  "account": {
    "id": "uuid", "type": "COMPANY", "nameEn": "...", "nameAr": "...",
    "email": "...", "phoneNumber1": "...", "phoneNumber2": null, "fax": null,
    "createdAt": "...", "updatedAt": "...",
    "currency": { "id": "uuid", "code": "SAR", "nameEn": "...", "nameAr": "...", "symbol": "﷼", "createdAt": "...", "updatedAt": "..." }
  },
  "type": "ADMIN" | "EMPLOYEE" | "CLIENT_ADMIN" | "CLIENT_EMPLOYEE",
  "permissions": ["core.user_management.user_management_list.view", "..."]
}
```
No role field anywhere — `permissions` (flat expression strings) is the only
authorization signal; `type` is for display/labelling only.

## Error-shape corrections needed in `core/errors`

The current `ExceptionMapper` was written against assumptions this API
doesn't match:

1. **401 message is currently hardcoded** (`'Your session has expired...'`)
   for every 401. The API's own `message` must be shown verbatim for
   login/verify-otp/resend-otp/refresh — those are always a plain string in
   the body. Fix: read `err.response.data['message']` when it's a `String`
   and use it as the exception message; keep the generic fallback only when
   the body has none.
2. **Validation errors arrive as `400`, not `422`**, and `message` is either
   a single `String` (one business-rule failure, e.g. "email must be a valid
   email address") or a `String[]` (class-validator's default "`<field> <constraint>`"
   sentences, e.g. `"username is required"`) — **not** the
   `{"errors": {"field": [...]}}` shape `parseFieldErrors` currently expects.
   Fix: add a `400` branch to `ExceptionMapper` that builds a
   `ValidationException` from either shape, deriving a per-field key from the
   leading token of each sentence (matches class-validator's default
   format) so `AppTextField`s can still highlight their own error.
3. **429 has no case at all** today (falls through to `UnknownException`).
   Fix: add a `RateLimitException`/`RateLimitFailure` carrying
   `retryAfterSeconds` (from the `Retry-After` header, falling back to
   parsing the minutes out of `message` if the header is missing) so the OTP
   resend button can disable itself and count down instead of just showing
   red text.

`FailureMapper`'s switch stays exhaustive — adding `RateLimitException` means
adding the matching `RateLimitFailure` arm in the same commit, which the
compiler will enforce.

## Domain layer (`features/auth/domain/`)

- `entities/`: `UserEntity`, `AccountEntity`, `CurrencyEntity`, `AuthSessionEntity`
  (`accessToken` + `refreshToken` + `user`), `UserType` enum. Drop nothing —
  `AuthTokensEntity` is superseded by `AuthSessionEntity` (it needs `user` now).
- `repositories/auth_repository.dart`: replace `login(email, password)` →
  `login(username, password)` returning
  `Either<Failure, LoginResult>` where `LoginResult` is a sealed type of
  `LoginRequiresOtp` | `LoginSucceeded(AuthSessionEntity)` — `requiresOtp` is
  success, not failure, so it must not be forced through `Left(Failure)`.
  Add `verifyOtp(username, code)`, `resendOtp(username)`,
  `refreshAccessToken()`, `logout()`, keep `forgetPassword(email)` and
  `resetPassword(resetToken, newPassword)`. **Remove** `verifyResetCode` —
  no such endpoint exists.
- `usecases/`: `LoginUseCase`, `VerifyOtpUseCase`, `ResendOtpUseCase`,
  `RefreshAccessTokenUseCase`, `LogoutUseCase`, `ForgetPasswordUseCase`
  (rename from `RequestPasswordResetUseCase` to match the endpoint's actual
  name), `ResetPasswordUseCase` (kept). **Remove** `VerifyResetCodeUseCase`.

## Data layer (`features/auth/data/`)

- `models/`: `LoginRequestModel`, `VerifyOtpRequestModel`,
  `ResendOtpRequestModel`, `RefreshTokenRequestModel`, `ForgetPasswordRequestModel`,
  `ResetPasswordRequestModel` (all thin, `@JsonKey` only where the wire name
  differs), plus `UserModel`/`AccountModel`/`CurrencyModel`/`AuthSessionModel`
  for the response side. Freezed + `json_serializable`, matching the existing
  `AuthTokensModel` pattern.
- `mappers/auth_mapper.dart`: model → entity, `nameEn`/`nameAr` nulls stay
  null (the *presentation* layer decides the username fallback, not the
  mapper — matches "nulls get defaults ... at the mapper" only where the
  default is a real domain concern; a display fallback is a UI concern).
- `datasources/remote/auth_remote_datasource.dart`: delete
  `AuthRemoteDataSourceMock`; add `AuthRemoteDataSourceImpl` using the
  injected `Dio`, one method per endpoint above, each wrapping its Dio call
  in `try`/`on DioException catch (e) { throw ExceptionMapper.fromDioException(e); }`
  per `FEATURE_CONVENTIONS.md` ("no `DioException` may escape
  `data/datasources/`").
- `repositories/auth_repository_impl.dart`: same `_guard` shape as today.
  `login`/`verifyOtp` persist tokens **and** the user profile on success
  (see Secure storage below); `logout` clears everything regardless of
  whether the network call succeeds (the local session ends either way — the
  server call is best-effort cleanup, not a precondition for signing out
  locally: catch and ignore its failure after clearing storage).

## Core: network, config, secure storage

- `dio_client.dart`: add default headers `X-Client: mobile` and
  `x-tenant: saudi-tracking` (a constant for now — becomes configurable if
  the app ever needs to serve more than one tenant) to `BaseOptions.headers`,
  alongside the existing `Content-Type`/`Accept`.
- `auth_interceptor.dart`: `_refreshPath` → `/auth/refresh-access-token`;
  the response parse becomes `data?['data']?['accessToken']` /
  `['refreshToken']` (currently reads `data?['accessToken']` directly, one
  level too shallow for this API's `{message, data: {...}}` envelope) — this
  was written against a guess, not the real shape, so it silently never
  refreshed anything against a real backend.
- `app_config_loader.dart`: `hostsAgree` becomes a warning-only check (log via
  `AppLogger`, don't throw) rather than a `StateError` — per the decision
  above.
- `config/dev.json`: `BASE_URL` → `https://nasam-v2-api-dev.nasam.net/api/v1`.
- `secure_storage_service.dart`: add `saveUser(String json)` /
  `getUser()` / `deleteUser()` alongside the token methods. The
  authenticated user (name, email, permissions, account) moves from
  `StorageService`'s `keyUserData` (`SharedPreferences`, unencrypted) to
  here — this is the explicit ask ("store user data securely using
  flutter_secure_storage"). `clearAll()` already wipes the whole secure
  store, so logout needs no extra call. `StorageService.saveUserData` /
  `getUserData` are removed as now-dead (nothing else uses them; grep
  confirms).
- `auth_service.dart`: `AuthServiceImpl.login` is currently a hand-rolled
  mock inside the *service* (parallel to, and now made redundant by, the
  real repository). Delete the mock body; `AuthService` becomes a thin
  read-only view (`isAuthenticated`, `accessToken`, `currentUser`) that
  `RouteGuard` and any "who's signed in" UI reads — the actual sign-in/out
  side effects live in `AuthRepositoryImpl`, which is the only place that
  should write tokens, matching how `login()` already documents itself
  ("Persisting here ... is what makes the session real").

## Presentation layer

- **`LoginCubit`**: `submit` takes `username` (not `email`); on
  `LoginRequiresOtp`, emit a new `AuthFormStatus` (`LoginNeedsOtp(username)`)
  instead of `AuthFormSucceeded`, so `LoginPage` can route to the OTP screen
  instead of home.
- **`LoginPage`**: field already reads `loginUsernameLabel`/hint (it was
  built as a username field even though the cubit currently calls the param
  `email` — just the cubit's naming was wrong); listener adds the
  `LoginNeedsOtp` case → `context.push(AppRoutes.otpVerification, extra: username)`.
- **`OtpCubit`**: rebuilt on `VerifyOtpUseCase` + `ResendOtpUseCase` (was
  `VerifyResetCodeUseCase` + `RequestPasswordResetUseCase` — the reset-flow
  pair, no longer applicable). `submit` takes `username`, emits
  `AuthFormSucceeded` (nothing further to carry — the repository already
  persisted the session, same pattern as `LoginCubit`).
- **`OtpVerificationPage`**: `_codeLength` 5 → 6 (matches the API and
  actually matches the *existing* `otpSubtitle` copy, "six-digit", which the
  5-box UI already contradicted); constructor param renamed `email` →
  `username` throughout (it's threaded from `LoginPage`/`route extra` now,
  not from `ForgotPasswordPage`).
- **`ForgotPasswordCubit`**: unchanged shape, calls the renamed
  `ForgetPasswordUseCase`.
- **`ForgotPasswordPage`**: per the web-only decision, `AuthFormSucceeded` no
  longer pushes to `otpVerification` — it shows an inline "check your email"
  confirmation (reuses the existing `SuccessScreen` widget the way
  `PasswordResetSuccessPage` already does, in place, no new route) with a
  "back to sign in" action. `NewPasswordPage`/`NewPasswordCubit`/
  `PasswordResetSuccessPage`/`AppRoutes.newPassword`/
  `AppRoutes.passwordResetSuccess` are **left in place** (they're a correct,
  working implementation of `PATCH /reset-password`) but no route pushes to
  them anymore — they're exactly what a future deep-link handler needs to
  land on, noted with a comment pointing at this doc.
- **`route_guard.dart` / `app_routes.dart`**: `otpVerification` stays public
  (still pre-auth) but is reached from `login` now, not `forgotPassword`; its
  `redirect` guard (must arrive with `state.extra` or bounce) still applies,
  target changes to `AppRoutes.login` instead of `AppRoutes.forgotPassword`
  when it's missing.
- **Logout**: no call site exists yet (there's no settings/profile screen in
  the app today) — `LogoutUseCase` is implemented and DI-registered so the
  first screen that adds a "sign out" action has nothing left to build, but
  wiring an actual button is out of scope here (nothing in the current UI
  calls for one).

## Localization

New/changed ARB keys (added to `app_ar.arb` first, per convention):
`otpTitle`/`otpSubtitle` copy stays (still "enter the six-digit code"), but
now needs a version keyed by `username` display rather than assuming an
email was just typed — check whether `otpSubtitle(email)` reads naturally as
`otpSubtitle(username)` or needs a copy change (the 2FA code is emailed to
whatever address is on file, which the client doesn't know — the message
likely becomes "We sent a code to your registered email" with no
interpolation, rather than quoting an address the app was never given).
`forgotPasswordCheckEmailTitle`/`...Subtitle` for the new inline confirmation
state. Rate-limit copy (`Try again in {minutes} minute(s)`) for the 429 case
on login/resend-otp.

## Tests

`FEATURE_CONVENTIONS.md` notes auth has no tests yet and cubits are "the
place to start." This change adds real network behavior for the first time,
so it adds:
- `ExceptionMapper` tests for the three corrected cases (400 string vs.
  array, verbatim 401 message, 429 → `RateLimitFailure`).
- `AuthRepositoryImpl` tests: login → `LoginRequiresOtp` vs
  `LoginSucceeded`, token+user persistence on success, logout clears storage
  even when the network call throws.
- `LoginCubit`, `OtpCubit` tests for the new branch/rename.
- `AuthInterceptor` test for the fixed refresh path/response parsing
  (it already has a `refreshClientFactory` seam built for exactly this).

## Explicitly out of scope this pass

- `PATCH /auth/change-password`, `PATCH /auth/activate-account`,
  `POST /auth/activation-link-status`, `POST /auth/reset-link-status`,
  `POST /auth/resend-activation-link` — none were asked for; `change-password`
  in particular needs a settings screen that doesn't exist yet.
- Real deep-linking for the reset-password email link (App Links /
  Universal Links) — needs the email's actual link format and
  domain-association hosting, likely a joint task with the backend/web team.
- WebSocket URL/host for the new environment — `hostsAgree` is relaxed, not
  fixed; tracking's live updates are unaffected either way since they don't
  touch auth.

## Rollout order

1. Config/network plumbing (tenant + client headers, dev `BASE_URL`, relaxed
   `hostsAgree`, `SecureStorageService` user methods).
2. Error-mapping corrections (`ExceptionMapper`/`FailureMapper`).
3. Domain layer (entities, repository interface, usecases).
4. Data layer (models, mapper, real datasource, repository impl) — replaces
   the mock; `AuthInterceptor` refresh fix rides along since it touches the
   same endpoint.
5. Presentation layer (cubit/page changes for login 2FA branch and the
   web-only forgot-password confirmation) + routing.
6. DI registration, ARB strings, tests.

Each step should compile and (where it has coverage) pass tests on its own —
this is ordered so a partial run still leaves the app in a working state
against the mock behavior it's replacing, one seam at a time, rather than a
single all-or-nothing patch.
