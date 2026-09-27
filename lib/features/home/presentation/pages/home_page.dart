import 'package:flutter/material.dart';

import '../../../tracking/presentation/pages/tracking_page.dart';

/// Home is the tracking screen. Its cubit is provided by the route.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const TrackingPage();
}
