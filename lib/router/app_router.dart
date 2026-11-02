import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../screens/auth/login_screen.dart';
import '../screens/vehicles/vehicle_form_screen.dart';
import '../widgets/app_shell.dart';

/// Centralized route generator and route paths for Stark VMS.
class AppRouter {
  static const String loginRoute = '/login';
  static const String vehiclesRoute = '/vehicles';
  static const String vehicleNewRoute = '/vehicles/new';
  static const String vehicleEditRoute = '/vehicles/edit';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );

      case vehiclesRoute:
      case '/':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AppShell(initialIndex: 0),
        );

      case vehicleNewRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const VehicleFormScreen(),
        );

      case vehicleEditRoute:
        final vehicle = settings.arguments as Vehicle?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => VehicleFormScreen(vehicleToEdit: vehicle),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
    }
  }
}

