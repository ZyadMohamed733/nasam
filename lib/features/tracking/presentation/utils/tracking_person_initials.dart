import 'package:characters/characters.dart';

/// Builds an avatar label from a person's first and second name parts.
abstract final class TrackingPersonInitials {
  static const fallback = '?';

  static String fromName(String? name) {
    final parts = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2);

    final initials = parts
        .map((part) => part.characters.first)
        .join()
        .toUpperCase();

    return initials.isEmpty ? fallback : initials;
  }
}
