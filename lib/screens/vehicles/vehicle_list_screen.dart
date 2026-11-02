import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';
import '../../data/vehicle_repository.dart';
import '../../models/vehicle.dart';
import '../../router/app_router.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

/// Primary Fleet Management screen displaying all registered vehicles.
class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final _searchController = TextEditingController();
  VehicleStatus? _statusFilter;
  VehicleType? _typeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _statusFilter = null;
      _typeFilter = null;
    });
  }

  bool get _hasActiveFilters =>
      _searchController.text.isNotEmpty ||
      _statusFilter != null ||
      _typeFilter != null;

  Future<void> _confirmDelete(Vehicle vehicle) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Vehicle',
      message:
          'Are you sure you want to remove ${vehicle.plateNumber} (${vehicle.fullName}) from the fleet registry? This action cannot be undone.',
      confirmLabel: 'Delete Vehicle',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      VehicleRepository.instance.delete(vehicle.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vehicle ${vehicle.plateNumber} was deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = VehicleRepository.instance;

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final filteredVehicles = repo.filter(
          searchQuery: _searchController.text,
          statusFilter: _statusFilter,
          typeFilter: _typeFilter,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildKpiMetrics(context, repo),
              const SizedBox(height: 24),
              _buildFilterBar(context),
              const SizedBox(height: 16),
              if (filteredVehicles.isEmpty)
                _buildEmptyState(context)
              else if (Responsive.isDesktop(context) || Responsive.isTablet(context))
                _buildDesktopTable(context, filteredVehicles)
              else
                _buildMobileCardList(context, filteredVehicles),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fleet Vehicles',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitor, filter, and maintain active vehicle registrations.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRouter.vehicleNewRoute);
          },
          icon: const Icon(Icons.add, size: 20),
          label: Text(isMobile ? 'Register' : 'Register Vehicle'),
        ),
      ],
    );
  }

  Widget _buildKpiMetrics(BuildContext context, VehicleRepository repo) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    final cards = [
      StatCard(
        title: 'Total Fleet',
        value: repo.totalCount.toString(),
        icon: Icons.directions_car_rounded,
        color: const Color(0xFF1E40AF),
        subtitle: 'Registered assets',
      ),
      StatCard(
        title: 'Active in Field',
        value: repo.activeCount.toString(),
        icon: Icons.check_circle_outline,
        color: const Color(0xFF10B981),
        subtitle: '${((repo.activeCount / (repo.totalCount == 0 ? 1 : repo.totalCount)) * 100).round()}% fleet availability',
      ),
      StatCard(
        title: 'In Maintenance',
        value: repo.maintenanceCount.toString(),
        icon: Icons.build_outlined,
        color: const Color(0xFFF59E0B),
        subtitle: 'Scheduled or repair',
      ),
      StatCard(
        title: 'Avg Fleet Odometer',
        value: '${(repo.averageMileage / 1000).toStringAsFixed(1)}k km',
        icon: Icons.speed_outlined,
        color: const Color(0xFF8B5CF6),
        subtitle: 'Across all units',
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .map((c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: c,
                  ),
                ))
            .toList()
          ..last = Expanded(child: cards.last),
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 16),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: cards
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: c,
                ))
            .toList(),
      );
    }
  }

  Widget _buildFilterBar(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isDesktop
            ? Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildSearchTextField(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildStatusDropdown(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildTypeDropdown(),
                  ),
                  if (_hasActiveFilters) ...[
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text('Reset'),
                    ),
                  ],
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSearchTextField(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatusDropdown()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTypeDropdown()),
                    ],
                  ),
                  if (_hasActiveFilters) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear Filters'),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildSearchTextField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search by plate, make, model, VIN, or driver...',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<VehicleStatus?>(
      key: ValueKey(_statusFilter),
      initialValue: _statusFilter,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Filter by Status',
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('All Statuses'),
        ),
        ...VehicleStatus.values.map(
          (s) => DropdownMenuItem(
            value: s,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(s.displayName),
              ],
            ),
          ),
        ),
      ],
      onChanged: (val) => setState(() => _statusFilter = val),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<VehicleType?>(
      key: ValueKey(_typeFilter),
      initialValue: _typeFilter,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Filter by Body Type',
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('All Body Types'),
        ),
        ...VehicleType.values.map(
          (t) => DropdownMenuItem(
            value: t,
            child: Text(t.displayName),
          ),
        ),
      ],
      onChanged: (val) => setState(() => _typeFilter = val),
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Vehicle> vehicles) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Registry Entries (${vehicles.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'Click edit to modify details',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 950),
              child: DataTable(
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('VEHICLE')),
                  DataColumn(label: Text('PLATE / VIN')),
                  DataColumn(label: Text('TYPE & FUEL')),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('ODOMETER')),
                  DataColumn(label: Text('ASSIGNED DRIVER')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rows: vehicles.map((vehicle) {
                  return DataRow(
                    cells: [
                      // Vehicle Make/Model
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                              child: Icon(vehicle.type.icon, size: 18, color: theme.colorScheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${vehicle.make} ${vehicle.model}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Model Year: ${vehicle.year}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Plate & VIN
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey[400]!),
                              ),
                              child: Text(
                                vehicle.plateNumber,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              vehicle.vin,
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      // Type & Fuel
                      DataCell(
                        Text('${vehicle.type.displayName} • ${vehicle.fuelType.displayName}'),
                      ),
                      // Status
                      DataCell(
                        StatusBadge(status: vehicle.status),
                      ),
                      // Mileage
                      DataCell(
                        Text(vehicle.formattedMileage),
                      ),
                      // Driver
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: vehicle.assignedDriver != null ? Colors.blueGrey : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              vehicle.assignedDriver ?? 'Unassigned',
                              style: TextStyle(
                                fontStyle: vehicle.assignedDriver == null ? FontStyle.italic : FontStyle.normal,
                                color: vehicle.assignedDriver == null ? Colors.grey : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Actions
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              tooltip: 'Edit Vehicle',
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  AppRouter.vehicleEditRoute,
                                  arguments: vehicle,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              color: theme.colorScheme.error,
                              tooltip: 'Delete Vehicle',
                              onPressed: () => _confirmDelete(vehicle),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCardList(BuildContext context, List<Vehicle> vehicles) {
    final theme = Theme.of(context);

    return Column(
      children: vehicles.map((vehicle) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      vehicle.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    StatusBadge(status: vehicle.status, compact: true),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        vehicle.plateNumber,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${vehicle.type.displayName} • ${vehicle.formattedMileage}'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Driver: ${vehicle.assignedDriver ?? "Unassigned"}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          AppRouter.vehicleEditRoute,
                          arguments: vehicle,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: theme.colorScheme.error,
                      onPressed: () => _confirmDelete(vehicle),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No vehicles found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No fleet records match your current search and filter settings.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
