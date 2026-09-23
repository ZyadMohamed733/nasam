import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../tracking/domain/tracking_vehicle.dart';
import '../../../tracking/presentation/tracking_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) =>
      TrackingPage(repository: getIt<TrackingRepository>());
}
