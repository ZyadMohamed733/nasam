# `_template` — the reference feature slice

Copy this directory to start a feature. It exists to demonstrate the rules
below, so keep it copyable: if you change a convention here, change it
everywhere.

```
_template/
  data/         datasources/ · models/ · mappers/ · repositories/
  domain/       entities/ · repositories/ · usecases/
  presentation/ bloc/ · pages/ · widgets/
```

## Which layer may import what

- `domain/` imports **nothing** from Flutter, Dio, SharedPreferences or any
  other package that knows about IO. It is plain Dart. This is the rule most
  Clean Architecture attempts break first.
- `data/` may import `domain/`. Never the reverse.
- `presentation/` may import `domain/`. It must not import `data/`.

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

## Models, entities and the mapper

`TemplateModel` is the wire shape and is deliberately messy — snake_case keys
via `@JsonKey`, nullable fields, a date as an ISO string, and `row_version`
that the domain does not want. `TemplateEntity` is fully typed and non-null.

The mapper is where nulls get defaults, strings become `DateTime`s and unwanted
fields are dropped. If you copy this slice and your model and entity end up
identical, that is a signal your model is not modelling the real API — not a
signal to delete the mapper.

## Dependency injection

- Blocs are `@injectable` (a new instance per page). Never `@lazySingleton` —
  a shared bloc leaks state between screens.
- Repositories, datasources and services are `@LazySingleton(as: Interface)`.
- Widgets receive dependencies **by constructor**. Do not call `getIt<T>()`
  inside `build()`; `AppScaffold` is the one place the shared chrome resolves
  its dependencies.

## Presentation

- Read colours as `Theme.of(context).colorScheme.*` and text as
  `Theme.of(context).textTheme.*`. Do not branch on
  `Theme.of(context).brightness`.
- Use `AppSizes` constants for spacing, radii and icon sizes. ScreenUtil's
  `.sp` is for text only, inside the theme — no `.w`, `.h` or `.r`.
- Validators return a typed `ValidationError`; resolve it with
  `context.validator(...)` or `error.resolve(context)` at the widget layer.
- Any user-visible string goes in both ARB files. Counts use ICU `plural` with
  all six Arabic categories — see `vehicleCount` for the pattern.

## Tests

Each slice should carry, at minimum: a mapper test covering null and malformed
input, a repository test covering the cache-fallback rules, a usecase test and
a bloc test. Shared mocks live in `test/helpers/mock_helper.dart` and fixtures
in `test/helpers/fixtures.dart` — use them rather than redefining your own.
