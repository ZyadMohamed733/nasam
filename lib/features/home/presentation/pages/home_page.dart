import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Center(
        child: Text(
          'Home Screen Placeholder',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
