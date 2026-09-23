import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/tracking_vehicle.dart';
import '../dummy_data/tracking_all_dummy_data.dart';
import '../widgets/tracking_vehicle_card.dart';
import '../widgets/tracking_vehicle_search_field.dart';

class TrackingVehiclesPage extends StatefulWidget {
  const TrackingVehiclesPage({
    super.key,
    required this.title,
    required this.status,
  });

  final String title;
  final VehicleStatus? status;

  @override
  State<TrackingVehiclesPage> createState() => _TrackingVehiclesPageState();
}

class _TrackingVehiclesPageState extends State<TrackingVehiclesPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final vehicles = TrackingAllDummyData.vehicles.where((vehicle) {
      final matchesStatus = widget.status == null || vehicle.status == widget.status;
      final matchesQuery = vehicle.name.toLowerCase().contains(query) ||
          vehicle.code.toLowerCase().contains(query) ||
          vehicle.driver.toLowerCase().contains(query);
      return matchesStatus && matchesQuery;
    });

    return Semantics(
      label: widget.title,
      child: Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Column(
          children: [
            TrackingVehicleSearchField(
              onChanged: (value) => setState(() => _query = value),
            ),
            SizedBox(height: 8.h),
            for (final vehicle in vehicles) ...[
              TrackingVehicleCard(vehicle: vehicle),
              SizedBox(height: 6.h),
            ],
          ],
        ),
      ),
    );
  }
}
