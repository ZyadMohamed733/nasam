import 'package:flutter/material.dart';

/// Shared loading spinner using the app's loading accent color.
class LoadingIndicatorWidget extends StatelessWidget {
  const LoadingIndicatorWidget({super.key});

  static const Color color = Color(0xFF972FA3);

  @override
  Widget build(BuildContext context) =>
      const CircularProgressIndicator(color: color);
}
