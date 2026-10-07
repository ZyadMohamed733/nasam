# Feature conventions

The layer rules every feature slice follows. `lib/features/auth/` is the worked
example — read it alongside this.

These rules used to live in `lib/features/_template/`, a slice that existed only
to demonstrate them. It was deleted once auth became a real one. The difference
matters when you read the examples: a template can be built to show every rule,
whereas auth is shaped by what signing in actually needs, so it exercises most of
them and deliberately opts out of two. Both are marked below.

```
auth/
  data/         datasources/ · models/ · mappers/ · repositories/
  domain/       entities/ · repositories/ · usecases/
  presentation/ cubit/ · pages/ · widgets/
```

## Which layer may import what

- `domain/` imports **nothing** from Flutter, Dio, SharedPreferences or any
  other package that knows about IO. It is plain Dart. This is the rule most
  Clean Architecture attempts break first.
- `data/` may import `domain/`. Never the reverse.
- `presentation/` may import `domain/`. It must not import `data/`.

`AuthRepository` in `domain/repositories/` names only `AuthTokensEntity` and
`Failure`; `AuthRepositoryImpl` in `data/` is the only file that knows a
datasource exists.

## Errors

- Datasources catch `DioException` and throw the matching `AppException` via
  `ExceptionMapper`. **No `DioException` may escape `data/datasources/`.**
- Repositories catch `AppException` and map it to a `Failure` with
  `FailureMapper`, returning `Either<Failure, T>`. The switch there is
  exhaustive on purpose: a new exception without a failure is a compile error.
- Never write a domain type into `DioException.error` and cast it back out.
  That makes the error contract depend on an interceptor being in the chain.
- Fall back to a cache only for `NetworkException` and `TimeoutException`.
  Serving cached data on a 401, 403 or 422 makes an error look like success.

`AuthRepositoryImpl` funnels all four operations through one `_guard` helper
rather than repeating the try/catch. That is a convenience, not a rule — a
repository whose operations need different fallback behaviour should not share
one.

> **Auth does not demonstrate the cache rule.** It has no local datasource and no
> fallback at all, deliberately: every call it makes is a credential exchange,
> and a stale answer to "are these credentials good" is worse than an error. A
> feature that reads data the user can look at offline *should* cache, and should
> follow the rule above when it does. Do not copy auth's absence of a cache as
> though it were the default.

## Models, entities and the mapper

The model is the wire shape — `@JsonKey` for snake_case, nullable fields, dates
as strings, and any field the domain does not want. The entity is fully typed
and non-null. The mapper is where nulls get defaults, strings become `DateTime`s
and unwanted fields are dropped.

> **Auth is the thin case.** `AuthTokensModel` → `AuthTokensEntity` is almost an
> identity function, because the payload is two opaque strings with nothing to
> normalise; the only thing the model carries that the entity does not is the
> snake_case key names. That is legitimate *here* and unusual everywhere else.
>
> If you copy a slice and your model and entity come out identical for a payload
> with dates, optional fields or server-side bookkeeping columns in it, that is a
> signal your model is not modelling the real API — not a signal to delete the
> mapper. Keep the mapper even when it is thin: it is the seam that stops a
> server rename from reaching the domain.

## Dependency injection

- Blocs and cubits are registered as factories (a new instance per page). Never
  share them as singletons — shared state would leak between screens.
- Repositories, datasources and services are registered as lazy singletons,
  using their interface type where appropriate.
- Widgets receive dependencies **by constructor**. Do not call `getIt<T>()`
  inside `build()`; `AppScaffold` is the one place the shared chrome resolves
  its dependencies.
- Feature registration functions must pass only the dependencies a class
  requires and leave optional configuration at its constructor defaults.

Auth pages take an optional cubit (`LoginPage({this.cubit})`) and fall back to
`getIt` when it is null. That keeps the page testable without a container while
the route still builds it with no arguments.

## Presentation

- Read colours as `Theme.of(context).colorScheme.*`, or
  `context.semanticColors.*` for the design tokens Material has no role for —
  the button and icon states, the hover fills, the success/fail pair. Text is
  `Theme.of(context).textTheme.*`. Do not branch on
  `Theme.of(context).brightness`.
- Use `AppSizes` constants for spacing, radii and icon sizes. ScreenUtil's
  `.sp` is for text only, inside the theme — no `.w`, `.h` or `.r`.
- Do not pin a text row to a fixed height. Every size in the scale is a `.sp`,
  so it grows with the device and the accessibility setting while a hard-coded
  box does not, and Arabic loses its top half first. Use a minimum instead —
  see `AppTextField`.
- Validators return a typed `ValidationError`; resolve it with
  `context.validator(...)` or `error.resolve(context)` at the widget layer.
- Any user-visible string goes in both ARB files. **`app_ar.arb` is the
  template**: Arabic is the source language, so placeholder and plural
  declarations are read from there, and a new key is added to it first. Counts
  use ICU `plural` with all six Arabic categories — see `vehicleCount`.
- Leave direction to `Directionality`. A `Row`, a `PageView` and `start`
  alignment already flip under Arabic. Reach for `TextDirection.ltr` only for
  content that is never RTL — plate numbers, IMEIs, emails, one-time codes —
  and set it on the hint as well as the field, or bidi reorders the placeholder.

### Cubit or bloc

Use a cubit when the screen calls one method per user action and the caller
never needs to inspect the request — every auth screen is this. Use a bloc when
events carry data worth logging or replaying, or when several event types
converge on one state machine.

`AuthFormStatus` is shared by all four auth cubits rather than each declaring
its own idle/loading/failure trio. Look for that before writing a fourth
near-identical state class.

## Tests

A slice should carry, at minimum: a mapper test covering null and malformed
input, a repository test covering whatever fallback rules it has, a usecase test
and a bloc or cubit test. Shared mocks live in `test/helpers/mock_helper.dart`;
`test/helpers/widget_harness.dart` pumps a widget inside the real theme, the
design frame and the localisation delegates.

> **Auth has no tests yet.** They were deferred to keep the feature work moving,
> so auth is the example for structure, not for coverage. The cubits are the
> place to start.

Widget tests measure on the design frame (402×874 at 1:1) because `.sp` resolves
to design points there and a measured height can be compared with a number from
the Figma file. `pumpInApp` does this for you. Goldens additionally need
`loadAppFonts` from `test/helpers/font_loader.dart`, or text renders in the
built-in test face and the file proves nothing about the typeface.
