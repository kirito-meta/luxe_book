import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_press_scale.dart';
import '../../../core/widgets/surface_container.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authProvider.notifier).signUp(
        email: email,
        password: password,
        displayName: name,
      );
      if (mounted) context.go('/home');
    } catch (e) {
      setState(
              () => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            topPadding + 60,
            AppSpacing.screenPadding,
            bottomPadding + 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'L',
                    style: TextStyle(
                      color: AppColors.background,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              Text('Create account', style: AppTypography.displayMedium),
              const SizedBox(height: 8),
              Text(
                'Join to discover exclusive venues',
                style: AppTypography.bodyLarge,
              ),
              const SizedBox(height: 48),

              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: AppColors.error, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_error!,
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.error)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Text('FULL NAME', style: AppTypography.overline),
              const SizedBox(height: 8),
              SurfaceContainer(
                borderRadius: AppSpacing.inputRadius,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Your full name',
                    hintStyle: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 16),
                    prefixIcon: const Icon(Icons.person_outline,
                        color: AppColors.textTertiary, size: 18),
                    prefixIconConstraints:
                    const BoxConstraints(minWidth: 36),
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text('EMAIL', style: AppTypography.overline),
              const SizedBox(height: 8),
              SurfaceContainer(
                borderRadius: AppSpacing.inputRadius,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'your@email.com',
                    hintStyle: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 16),
                    prefixIcon: const Icon(Icons.mail_outline,
                        color: AppColors.textTertiary, size: 18),
                    prefixIconConstraints:
                    const BoxConstraints(minWidth: 36),
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text('PASSWORD', style: AppTypography.overline),
              const SizedBox(height: 8),
              SurfaceContainer(
                borderRadius: AppSpacing.inputRadius,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Min 6 characters',
                    hintStyle: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 16),
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppColors.textTertiary, size: 18),
                    prefixIconConstraints:
                    const BoxConstraints(minWidth: 36),
                    fillColor: Colors.transparent,
                    filled: true,
                    suffixIcon: GestureDetector(
                      onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textTertiary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              AnimatedPressScale(
                onTap: _isLoading ? null : _signup,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  decoration: BoxDecoration(
                    color: AppColors.buttonPrimary,
                    borderRadius:
                    BorderRadius.circular(AppSpacing.buttonRadius),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.background,
                      ),
                    )
                        : Text(
                      'Create Account',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.buttonPrimaryText,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  'By creating an account, you agree to our\nTerms of Service and Privacy Policy',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textTertiary, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 36),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Already have an account? ',
                        style: AppTypography.bodyMedium),
                    AnimatedPressScale(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Sign in',
                        style: AppTypography.labelLarge
                            .copyWith(color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}