import 'package:flutter/material.dart';
import '../../core/errors/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../data/auth/auth_service.dart';
import '../../router/app_router.dart';

/// Admin Login screen for the Stark Group VMS.
///
/// Authenticates against Spring Boot POST /api/auth/login, receiving a signed JWT access token.
/// Employs full inline validation, keyboard submission, loading indicators, and error mapping.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _authErrorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    setState(() {
      _authErrorMessage = null;
    });
    AuthService.instance.clearExpiredNotice();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text; // Do NOT trim password

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.instance.login(email, password);

      if (!mounted) return;

      _passwordController.clear();
      setState(() => _isSubmitting = false);

      Navigator.of(context).pushReplacementNamed(AppRouter.vehiclesRoute);
    } on ApiException catch (e) {
      if (!mounted) return;
      _passwordController.clear();
      setState(() {
        _isSubmitting = false;
        _authErrorMessage = e.message;
      });
      _passwordFocusNode.requestFocus();
    } on NetworkException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _authErrorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      _passwordController.clear();
      setState(() {
        _isSubmitting = false;
        _authErrorMessage = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutralBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.space24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  side: const BorderSide(color: AppTheme.borderNeutral),
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    MediaQuery.sizeOf(context).width < 400
                        ? AppTheme.space20
                        : AppTheme.space32,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBrandHeader(),
                        const SizedBox(height: AppTheme.space24),
                        const Divider(height: 1),
                        const SizedBox(height: AppTheme.space24),
                        ValueListenableBuilder<String?>(
                          valueListenable: AuthService.instance.sessionExpiredMessage,
                          builder: (context, sessionNotice, _) {
                            if (sessionNotice != null) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppTheme.space16),
                                child: _buildSessionNoticeAlert(sessionNotice),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        if (_authErrorMessage != null) ...[
                          _buildAuthErrorAlert(_authErrorMessage!),
                          const SizedBox(height: AppTheme.space16),
                        ],
                        _buildEmailField(),
                        const SizedBox(height: AppTheme.space16),
                        _buildPasswordField(),
                        const SizedBox(height: AppTheme.space24),
                        _buildSubmitButton(),
                        const SizedBox(height: AppTheme.space24),
                        _buildSecurityNotice(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.navy900,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Text(
                'STARK GROUP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.borderSubtle,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.borderNeutral),
              ),
              child: const Text(
                'VMS',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.space16),
        const Text(
          'Sign in to your account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: AppTheme.space4),
        const Text(
          'Administrative console for managing fleet operations and vehicle records.',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textMuted,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionNoticeAlert(String message) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space12),
      decoration: BoxDecoration(
        color: AppTheme.statusMaintenanceBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.statusMaintenanceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppTheme.statusMaintenanceText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.statusMaintenanceText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthErrorAlert(String message) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space12),
      decoration: BoxDecoration(
        color: AppTheme.errorRedBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.errorRedBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: AppTheme.errorRed,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.errorRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email address',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: AppTheme.space4),
        TextFormField(
          controller: _emailController,
          enabled: !_isSubmitting,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
          decoration: const InputDecoration(
            hintText: 'user@starkgroup.test',
          ),
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return 'Please enter your email address.';
            }
            final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
            if (!emailRegex.hasMatch(trimmed)) {
              return 'Please enter a valid email address.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: AppTheme.space4),
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          enabled: !_isSubmitting,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleSubmit(),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: AppTheme.textMuted,
              ),
              tooltip: _obscurePassword ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _handleSubmit,
      child: _isSubmitting
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text('Sign in'),
    );
  }

  Widget _buildSecurityNotice() {
    return const Center(
      child: Text(
        'Protected by Spring Security · Signed JWT Bearer Authentication\nTokens are stored in memory only and expire after 15 minutes',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: AppTheme.textMuted,
          height: 1.4,
        ),
      ),
    );
  }
}
