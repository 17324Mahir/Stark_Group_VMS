import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';
import 'mock_data.dart';

/// In-memory repository managing vehicle state.
/// Designed as a clean abstraction so it can be swapped with a REST API
/// client (calling the Spring Boot backend) without altering the UI layers.
class VehicleRepository extends ChangeNotifier {
  // Singleton pattern for simple and direct access across screens.
  static final VehicleRepository instance = VehicleRepository._internal();
  VehicleRepository._internal() {
    _vehicles.addAll(initialMockVehicles);
  }

  final List<Vehicle> _vehicles = [];

  /// Unmodifiable view of all vehicles.
  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  /// Total count of vehicles.
  int get totalCount => _vehicles.length;

  /// Active vehicles count.
  int get activeCount =>
      _vehicles.where((v) => v.status == VehicleStatus.active).length;

  /// Maintenance vehicles count.
  int get maintenanceCount =>
      _vehicles.where((v) => v.status == VehicleStatus.maintenance).length;

  /// Reserved vehicles count.
  int get reservedCount =>
      _vehicles.where((v) => v.status == VehicleStatus.reserved).length;

  /// Out of service vehicles count.
  int get outOfServiceCount =>
      _vehicles.where((v) => v.status == VehicleStatus.outOfService).length;

  /// Average mileage across all fleet vehicles.
  int get averageMileage {
    if (_vehicles.isEmpty) return 0;
    final total = _vehicles.fold<int>(0, (sum, v) => sum + v.mileage);
    return (total / _vehicles.length).round();
  }

  /// Retrieve a vehicle by its unique ID.
  Vehicle? getById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Add a new vehicle to the fleet.
  void add(Vehicle vehicle) {
    _vehicles.insert(0, vehicle);
    notifyListeners();
  }

  /// Update an existing vehicle.
  void update(Vehicle vehicle) {
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
      notifyListeners();
    }
  }

  /// Delete a vehicle by ID.
  void delete(String id) {
    _vehicles.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  /// Filter and search vehicles.
  List<Vehicle> filter({
    String? searchQuery,
    VehicleStatus? statusFilter,
    VehicleType? typeFilter,
  }) {
    return _vehicles.where((vehicle) {
      // Query filter (searches plate, make, model, VIN, driver)
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final matchesQuery = vehicle.plateNumber.toLowerCase().contains(query) ||
            vehicle.make.toLowerCase().contains(query) ||
            vehicle.model.toLowerCase().contains(query) ||
            vehicle.vin.toLowerCase().contains(query) ||
            (vehicle.assignedDriver?.toLowerCase().contains(query) ?? false);
        if (!matchesQuery) return false;
      }

      // Status filter
      if (statusFilter != null && vehicle.status != statusFilter) {
        return false;
      }

      // Type filter
      if (typeFilter != null && vehicle.type != typeFilter) {
        return false;
      }

      return true;
    }).toList();
  }
}

