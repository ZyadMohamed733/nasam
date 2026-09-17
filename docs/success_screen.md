# Reusable success screen

Use `SuccessScreen` from `lib/shared/widgets/success_screen.dart` after an operation succeeds. It owns the circular reveal, checkmark, confetti, content entrance, responsive layout, and reduced-motion behavior. The feature owns localized strings and navigation.

```dart
SuccessScreen(
  title: localizedSuccessTitle,
  message: localizedSuccessDescription, // optional
  actionLabel: localizedButtonLabel,
  onAction: () => context.go(destinationRoute),
)
```

The same widget works for password reset, subscriptions, payments, and saved changes. Pass `icon` to reveal different artwork or `showConfetti: false` to omit confetti. By default it uses the supplied brand checkmark. The animation plays once per mounted screen; use a new key for a new success event if reusing the same widget location. No success route or authentication dependency is built into the shared widget.

`PasswordResetSuccessPage` demonstrates using it with localized copy and a login action. Use the existing `appTransitionPage` when registering another feature's success route.
