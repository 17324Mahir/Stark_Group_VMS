import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';
import '../../router/app_router.dart';

/// Admin Login screen for the Vehicle Management System.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@stark-vms.io');
  final _passwordController = TextEditingController(text: '••••••••••••');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      // Simulate instantaneous admin authentication
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacementNamed(AppRouter.vehiclesRoute);
      });
    }
  }

  void _fillDemoCredentials() {
    setState(() {
      _emailController.text = 'fleet.admin@stark-vms.io';
      _passwordController.text = 'StarkVMS2026!';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 960 : 480,
            ),
            child: Card(
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              child: isDesktop
                  ? IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _buildBrandingPanel(theme)),
                          Expanded(child: _buildLoginForm(theme)),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMobileHeader(theme),
                        _buildLoginForm(theme),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// Side branding panel for desktop screens
  Widget _buildBrandingPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.85),
            const Color(0xFF0F172A),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'STARK VMS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enterprise Fleet Management Platform',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Centralized administration, real-time status monitoring, and vehicle lifecycle control designed for desktop operations.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              _buildFeatureBullet(Icons.check_circle_outline, 'Real-time fleet tracking & audit'),
              const SizedBox(height: 12),
              _buildFeatureBullet(Icons.build_circle_outlined, 'Preventative maintenance cycles'),
              const SizedBox(height: 12),
              _buildFeatureBullet(Icons.security, 'Role-based access control'),
            ],
          ),
          const SizedBox(height: 60),
          Text(
            'Frontend Admin Foundation • v1.0.0',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }

  /// Compact header for mobile/tablet screens
  Widget _buildMobileHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      color: theme.colorScheme.primary,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'STARK VMS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vehicle Management System',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// Login form content
  Widget _buildLoginForm(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sign In',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter your administrative credentials to continue',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address / Username',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email or username';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (val) => setState(() => _rememberMe = val ?? false),
                    ),
                    const Text('Remember workstation'),
                  ],
                ),
                TextButton(
                  onPressed: _fillDemoCredentials,
                  child: const Text('Fill Demo Info'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign In to Dashboard', style: TextStyle(fontSize: 15)),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Static Mode: No credentials are sent over the network. Click Sign In to explore.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
