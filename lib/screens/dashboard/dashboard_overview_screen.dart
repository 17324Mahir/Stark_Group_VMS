import 'package:flutter/material.dart';
import '../../data/vehicle_repository.dart';
import '../../models/vehicle.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

/// Overview summary screen displaying fleet analytics and operational health.
class DashboardOverviewScreen extends StatelessWidget {
  final VoidCallback onNavigateToVehicles;

  const DashboardOverviewScreen({
    super.key,
    required this.onNavigateToVehicles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = VehicleRepository.instance;

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final total = repo.totalCount == 0 ? 1 : repo.totalCount;
        final activePct = ((repo.activeCount / total) * 100).round();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fleet Operational Dashboard',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Live overview of fleet readiness, maintenance schedule, and asset distribution.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Operational Readiness',
                      value: '$activePct%',
                      icon: Icons.shield_outlined,
                      color: Colors.teal,
                      subtitle: '${repo.activeCount} of ${repo.totalCount} operational',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Requires Service',
                      value: '${repo.maintenanceCount}',
                      icon: Icons.warning_amber_rounded,
                      color: Colors.amber,
                      subtitle: 'Needs workshop attention',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Reserved Units',
                      value: '${repo.reservedCount}',
                      icon: Icons.calendar_today_outlined,
                      color: Colors.indigo,
                      subtitle: 'Allocated for missions',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Maintenance & Flagged Vehicles',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: onNavigateToVehicles,
                            child: const Text('View All Vehicles →'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...repo.vehicles
                          .where((v) =>
                              v.status == VehicleStatus.maintenance ||
                              v.status == VehicleStatus.outOfService)
                          .map((v) => ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: v.status.color.withValues(alpha: 0.15),
                                  child: Icon(v.type.icon, color: v.status.color, size: 20),
                                ),
                                title: Text(v.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Plate: ${v.plateNumber} • Odometer: ${v.formattedMileage}'),
                                trailing: StatusBadge(status: v.status),
                              )),
                      if (repo.maintenanceCount == 0 && repo.outOfServiceCount == 0)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'All fleet vehicles are active and healthy!',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

