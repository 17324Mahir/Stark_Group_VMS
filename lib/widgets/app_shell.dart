import 'package:flutter/material.dart';
import '../core/utils/responsive.dart';
import '../router/app_router.dart';
import '../screens/dashboard/dashboard_overview_screen.dart';
import '../screens/vehicles/vehicle_list_screen.dart';

/// Top-level shell layout providing desktop sidebar navigation, header,
/// and responsive mobile drawer for the admin console.
class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onSelectDestination(int index) {
    setState(() => _selectedIndex = index);
  }

  void _handleLogout() {
    Navigator.of(context).pushReplacementNamed(AppRouter.loginRoute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final showSidebar = isDesktop || isTablet;

    final bodyContent = switch (_selectedIndex) {
      0 => const VehicleListScreen(),
      1 => DashboardOverviewScreen(
          onNavigateToVehicles: () => _onSelectDestination(0),
        ),
      _ => _buildSettingsPlaceholder(theme),
    };

    return Scaffold(
      drawer: showSidebar ? null : _buildMobileDrawer(theme),
      appBar: AppBar(
        title: Row(
          children: [
            if (!showSidebar)
              const SizedBox.shrink()
            else ...[
              const Icon(Icons.directions_car_filled_rounded, size: 22),
              const SizedBox(width: 10),
              const Text(
                'Stark VMS Admin Console',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.dns_outlined,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Frontend Mock Data',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              AppThemeMode.toggle(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (showSidebar) _buildSidebar(theme),
          Expanded(child: bodyContent),
        ],
      ),
    );
  }

  /// Desktop & Tablet side navigation bar
  Widget _buildSidebar(ThemeData theme) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.dividerTheme.color ?? theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          _buildSidebarItem(
            icon: Icons.directions_car_outlined,
            selectedIcon: Icons.directions_car,
            label: 'Fleet Vehicles',
            index: 0,
            theme: theme,
          ),
          _buildSidebarItem(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            label: 'Fleet Overview',
            index: 1,
            theme: theme,
          ),
          _buildSidebarItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'System Settings',
            index: 2,
            theme: theme,
          ),
          const Spacer(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary,
                  child: const Text(
                    'AD',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin User',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'admin@stark-vms.io',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required ThemeData theme,
  }) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _onSelectDestination(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 20,
                  color: isSelected ? theme.colorScheme.primary : Colors.grey[600],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mobile navigation drawer
  Widget _buildMobileDrawer(ThemeData theme) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car, color: Colors.white, size: 36),
                    SizedBox(height: 8),
                    Text(
                      'STARK VMS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Fleet Vehicles'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onSelectDestination(0);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Fleet Overview'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onSelectDestination(1);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('System Settings'),
              selected: _selectedIndex == 2,
              onTap: () {
                _onSelectDestination(2);
                Navigator.of(context).pop();
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPlaceholder(ThemeData theme) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.settings_suggest_outlined, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              const Text(
                'System Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Configure fleet alerts, backend API connection URLs, and user roles.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper notifier for dynamic light/dark theme switching across the app.
class AppThemeMode {
  static final ValueNotifier<ThemeMode> notifier = ValueNotifier(ThemeMode.light);

  static void toggle(BuildContext context) {
    if (notifier.value == ThemeMode.light) {
      notifier.value = ThemeMode.dark;
    } else {
      notifier.value = ThemeMode.light;
    }
  }
}
