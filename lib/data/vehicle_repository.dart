import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';
import 'mock_data.dart';

/// Field options for sorting the vehicle list.
enum VehicleSortField {
  vehicleNumber,
  company,
}

/// Shared in-memory source of truth for the Stark Group Vehicle Management System.
///
/// Changes persist in memory for the active browser session and reset on refresh.
class VehicleRepository extends ChangeNotifier {
  static final VehicleRepository instance = VehicleRepository._internal();

  VehicleRepository._internal() {
    _vehicles.addAll(initialMockVehicles);
  }

  final List<Vehicle> _vehicles = [];

  /// Unmodifiable view of all vehicle records.
  List<Vehicle> get allVehicles => List.unmodifiable(_vehicles);

  /// Total count of all vehicles registered in the fleet.
  int get totalCount => _vehicles.length;

  /// Resets in-memory fleet to initial mock seed records.
  void reset() {
    _vehicles.clear();
    _vehicles.addAll(initialMockVehicles);
    notifyListeners();
  }

  /// Check whether a vehicle number already exists (case-insensitive).
  /// [excludeId] allows excluding the record currently being edited.
  bool isVehicleNumberDuplicate(String vehicleNumber, {String? excludeId}) {
    final normalized = vehicleNumber.trim().toLowerCase();
    return _vehicles.any((v) {
      if (excludeId != null && v.id == excludeId) return false;
      return v.vehicleNumber.trim().toLowerCase() == normalized;
    });
  }

  /// Retrieve a vehicle by its unique stable ID.
  Vehicle? getById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Register a new vehicle.
  void add(Vehicle vehicle) {
    _vehicles.insert(0, vehicle);
    notifyListeners();
  }

  /// Update an existing vehicle record while preserving its stable ID.
  void update(Vehicle vehicle) {
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
      notifyListeners();
    }
  }

  /// Delete a vehicle by its unique ID.
  void delete(String id) {
    _vehicles.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  /// Filter, search, and sort vehicles against the shared in-memory dataset.
  List<Vehicle> query({
    String? searchQuery,
    VehicleStatus? statusFilter,
    String? companyFilter,
    VehicleSortField sortField = VehicleSortField.vehicleNumber,
    bool sortAscending = true,
  }) {
    // 1. Filter
    final filtered = _vehicles.where((vehicle) {
      // Search matching Vehicle Number, Company, Brand, and Model
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        final matches = vehicle.vehicleNumber.toLowerCase().contains(q) ||
            vehicle.company.toLowerCase().contains(q) ||
            vehicle.brand.toLowerCase().contains(q) ||
            vehicle.model.toLowerCase().contains(q);
        if (!matches) return false;
      }

      // Status filter
      if (statusFilter != null && vehicle.status != statusFilter) {
        return false;
      }

      // Company filter
      if (companyFilter != null &&
          companyFilter.isNotEmpty &&
          companyFilter != 'All Companies' &&
          vehicle.company != companyFilter) {
        return false;
      }

      return true;
    }).toList();

    // 2. Sort
    filtered.sort((a, b) {
      int comparison;
      switch (sortField) {
        case VehicleSortField.vehicleNumber:
          comparison = a.vehicleNumber.compareTo(b.vehicleNumber);
          break;
        case VehicleSortField.company:
          comparison = a.company.compareTo(b.company);
          break;
      }
      return sortAscending ? comparison : -comparison;
    });

    return filtered;
  }
}
