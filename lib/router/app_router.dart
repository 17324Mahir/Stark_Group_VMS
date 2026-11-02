import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/vehicle.dart';
import '../screens/auth/login_screen.dart';
import '../screens/vehicles/vehicle_form_screen.dart';
import '../screens/vehicles/vehicle_list_screen.dart';
import '../widgets/app_shell.dart';

/// Centralized route definitions and page generator for Stark Group VMS.
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
          builder: (_) => const VehicleListScreen(),
        );

      case vehicleNewRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const VehicleFormScreen(),
        );

      case vehicleEditRoute:
        final vehicle = settings.arguments as Vehicle?;
        if (vehicle == null) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const _VehicleNotFoundScreen(),
          );
        }
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

/// Recovery screen when attempting to navigate to an edit route without a valid vehicle.
class _VehicleNotFoundScreen extends StatelessWidget {
  const _VehicleNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Vehicle Not Found',
      showBackButton: true,
      onBack: () => Navigator.of(context).pushReplacementNamed(AppRouter.vehiclesRoute),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.space32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.errorRed),
                const SizedBox(height: AppTheme.space16),
                const Text(
                  'Vehicle Record Not Found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: AppTheme.space8),
                const Text(
                  'The requested vehicle record could not be loaded or was removed from the registry.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
                const SizedBox(height: AppTheme.space24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(AppRouter.vehiclesRoute);
                  },
                  child: const Text('Return to Vehicles'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
