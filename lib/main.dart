import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'widgets/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StarkVmsApp());
}

/// Root application widget for Stark Vehicle Management System.
class StarkVmsApp extends StatelessWidget {
  const StarkVmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeMode.notifier,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          title: 'Stark VMS - Vehicle Management System',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          initialRoute: AppRouter.loginRoute,
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}
