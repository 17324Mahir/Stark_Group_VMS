import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Represents the operational status of a vehicle.
enum VehicleStatus {
  active('Active'),
  maintenance('In Maintenance'),
  reserved('Reserved'),
  outOfService('Out of Service');

  final String displayName;
  const VehicleStatus(this.displayName);

  Color get color {
    switch (this) {
      case VehicleStatus.active:
        return AppTheme.statusActive;
      case VehicleStatus.maintenance:
        return AppTheme.statusMaintenance;
      case VehicleStatus.reserved:
        return AppTheme.statusReserved;
      case VehicleStatus.outOfService:
        return AppTheme.statusOutOfService;
    }
  }

  IconData get icon {
    switch (this) {
      case VehicleStatus.active:
        return Icons.check_circle_outline;
      case VehicleStatus.maintenance:
        return Icons.build_outlined;
      case VehicleStatus.reserved:
        return Icons.bookmark_border;
      case VehicleStatus.outOfService:
        return Icons.warning_amber_rounded;
    }
  }
}

/// Represents the physical body type of a vehicle.
enum VehicleType {
  sedan('Sedan', Icons.directions_car_outlined),
  suv('SUV', Icons.airport_shuttle_outlined),
  truck('Truck', Icons.local_shipping_outlined),
  van('Van', Icons.directions_bus_outlined),
  electric('Electric Vehicle', Icons.electric_car_outlined),
  hybrid('Hybrid', Icons.eco_outlined);

  final String displayName;
  final IconData icon;
  const VehicleType(this.displayName, this.icon);
}

/// Represents the powertrain/fuel type.
enum FuelType {
  gasoline('Gasoline / Petrol'),
  diesel('Diesel'),
  electric('Electric'),
  hybrid('Plug-in Hybrid');

  final String displayName;
  const FuelType(this.displayName);
}

/// Vehicle entity model representing a fleet asset.
class Vehicle {
  final String id;
  final String plateNumber;
  final String make;
  final String model;
  final int year;
  final String vin;
  final VehicleType type;
  final FuelType fuelType;
  final VehicleStatus status;
  final int mileage;
  final String? assignedDriver;
  final DateTime? lastServiceDate;

  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.vin,
    required this.type,
    required this.fuelType,
    required this.status,
    required this.mileage,
    this.assignedDriver,
    this.lastServiceDate,
  });

  /// Full formatted title (e.g., "2024 Toyota RAV4")
  String get fullName => '$year $make $model';

  /// Formatted mileage display
  String get formattedMileage =>
      '${mileage.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} km';

  Vehicle copyWith({
    String? id,
    String? plateNumber,
    String? make,
    String? model,
    int? year,
    String? vin,
    VehicleType? type,
    FuelType? fuelType,
    VehicleStatus? status,
    int? mileage,
    String? assignedDriver,
    DateTime? lastServiceDate,
  }) {
    return Vehicle(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      type: type ?? this.type,
      fuelType: fuelType ?? this.fuelType,
      status: status ?? this.status,
      mileage: mileage ?? this.mileage,
      assignedDriver: assignedDriver ?? this.assignedDriver,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
    );
  }

  /// Converts model to Map for future REST API integration.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plateNumber': plateNumber,
      'make': make,
      'model': model,
      'year': year,
      'vin': vin,
      'type': type.name,
      'fuelType': fuelType.name,
      'status': status.name,
      'mileage': mileage,
      'assignedDriver': assignedDriver,
      'lastServiceDate': lastServiceDate?.toIso8601String(),
    };
  }

  /// Factory constructor to parse JSON/Map from future REST API integration.
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as String,
      plateNumber: map['plateNumber'] as String,
      make: map['make'] as String,
      model: map['model'] as String,
      year: (map['year'] as num).toInt(),
      vin: map['vin'] as String,
      type: VehicleType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => VehicleType.sedan,
      ),
      fuelType: FuelType.values.firstWhere(
        (e) => e.name == map['fuelType'],
        orElse: () => FuelType.gasoline,
      ),
      status: VehicleStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => VehicleStatus.active,
      ),
      mileage: (map['mileage'] as num).toInt(),
      assignedDriver: map['assignedDriver'] as String?,
      lastServiceDate: map['lastServiceDate'] != null
          ? DateTime.tryParse(map['lastServiceDate'] as String)
          : null,
    );
  }
}

