import 'package:flutter/material.dart';

/// Supported vehicle operational statuses.
enum VehicleStatus {
  active('Active'),
  inactive('Inactive'),
  maintenance('Maintenance');

  final String label;
  const VehicleStatus(this.label);

  /// Status badge text color
  Color get textColor {
    switch (this) {
      case VehicleStatus.active:
        return const Color(0xFF15803D); // Green 700
      case VehicleStatus.inactive:
        return const Color(0xFF475569); // Slate 600
      case VehicleStatus.maintenance:
        return const Color(0xFFB45309); // Amber 700
    }
  }

  /// Status badge background tint
  Color get backgroundColor {
    switch (this) {
      case VehicleStatus.active:
        return const Color(0xFFDCFCE7); // Green 100
      case VehicleStatus.inactive:
        return const Color(0xFFF1F5F9); // Slate 100
      case VehicleStatus.maintenance:
        return const Color(0xFFFEF3C7); // Amber 100
    }
  }

  /// Status badge border color
  Color get borderColor {
    switch (this) {
      case VehicleStatus.active:
        return const Color(0xFF86EFAC); // Green 300
      case VehicleStatus.inactive:
        return const Color(0xFFCBD5E1); // Slate 300
      case VehicleStatus.maintenance:
        return const Color(0xFFFCD34D); // Amber 300
    }
  }

  /// Indicator dot color
  Color get dotColor {
    switch (this) {
      case VehicleStatus.active:
        return const Color(0xFF16A34A); // Green 600
      case VehicleStatus.inactive:
        return const Color(0xFF64748B); // Slate 500
      case VehicleStatus.maintenance:
        return const Color(0xFFD97706); // Amber 600
    }
  }
}

/// Core vehicle domain model representing a fleet asset in the Stark Group VMS.
class Vehicle {
  final String id;
  final String vehicleNumber;
  final String company;
  final String type;
  final String brand;
  final String model;
  final VehicleStatus status;

  const Vehicle({
    required this.id,
    required this.vehicleNumber,
    required this.company,
    required this.type,
    required this.brand,
    required this.model,
    required this.status,
  });

  /// Full brand and model display name (e.g. "Toyota Camry")
  String get brandModel => '$brand $model';

  Vehicle copyWith({
    String? id,
    String? vehicleNumber,
    String? company,
    String? type,
    String? brand,
    String? model,
    VehicleStatus? status,
  }) {
    return Vehicle(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      company: company ?? this.company,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleNumber': vehicleNumber,
      'company': company,
      'type': type,
      'brand': brand,
      'model': model,
      'status': status.name,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as String,
      vehicleNumber: map['vehicleNumber'] as String,
      company: map['company'] as String,
      type: map['type'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      status: VehicleStatus.values.firstWhere(
        (s) => s.name.toUpperCase() == (map['status'] as String).toUpperCase(),
        orElse: () => VehicleStatus.active,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vehicle &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          vehicleNumber == other.vehicleNumber;

  @override
  int get hashCode => id.hashCode ^ vehicleNumber.hashCode;
}
