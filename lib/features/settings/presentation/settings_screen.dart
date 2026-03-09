import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_press_scale.dart';
import '../../../core/widgets/surface_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding + 16,
                left: AppSpacing.screenPadding,
                right: AppSpacing.screenPadding,
                bottom: 24,
              ),
              child: Row(
                children: [
                  AnimatedPressScale(
                    onTap: () => Navigator.pop(context),
                    child: SurfaceContainer(
                      borderRadius: 12,
                      padding: const EdgeInsets.all(10),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.textPrimary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Settings', style: AppTypography.displaySmall),
                ],
              ),
            ),
          ),

          // Notifications section
          _SectionHeader(title: 'NOTIFICATIONS'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: SurfaceContainer(
                borderRadius: AppSpacing.cardRadius,
                child: Column(
                  children: [
                    _ToggleRow(
                      icon: Icons.notifications_outlined,
                      title: 'Push Notifications',
                      subtitle: 'Booking confirmations, reminders',
                      value: profile.notificationsEnabled,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        ref
                            .read(profileProvider.notifier)
                            .toggleNotifications(val);
                      },
                    ),
                    _Divider(),
                    _ToggleRow(
                      icon: Icons.mail_outline,
                      title: 'Email Updates',
                      subtitle: 'Weekly picks and promotions',
                      value: true,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                      },
                    ),
                    _Divider(),
                    _ToggleRow(
                      icon: Icons.campaign_outlined,
                      title: 'Marketing',
                      subtitle: 'New venues and exclusive offers',
                      value: false,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // Privacy section
          _SectionHeader(title: 'PRIVACY & DATA'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: SurfaceContainer(
                borderRadius: AppSpacing.cardRadius,
                child: Column(
                  children: [
                    _ToggleRow(
                      icon: Icons.location_on_outlined,
                      title: 'Location Services',
                      subtitle: 'Find nearby venues',
                      value: profile.locationEnabled,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        ref
                            .read(profileProvider.notifier)
                            .toggleLocation(val);
                      },
                    ),
                    _Divider(),
                    _NavigationRow(
                      icon: Icons.shield_outlined,
                      title: 'Privacy Policy',
                      onTap: () {},
                    ),
                    _Divider(),
                    _NavigationRow(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () {},
                    ),
                    _Divider(),
                    _NavigationRow(
                      icon: Icons.download_outlined,
                      title: 'Download My Data',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // Preferences section
          _SectionHeader(title: 'PREFERENCES'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: SurfaceContainer(
                borderRadius: AppSpacing.cardRadius,
                child: Column(
                  children: [
                    _SelectionRow(
                      icon: Icons.language,
                      title: 'Language',
                      value: 'English',
                      onTap: () => _showLanguageSheet(context),
                    ),
                    _Divider(),
                    _SelectionRow(
                      icon: Icons.attach_money,
                      title: 'Currency',
                      value: profile.preferredCurrency,
                      onTap: () => _showCurrencySheet(context, ref),
                    ),
                    _Divider(),
                    _NavigationRow(
                      icon: Icons.credit_card_outlined,
                      title: 'Payment Methods',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // Support section
          _SectionHeader(title: 'SUPPORT'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: SurfaceContainer(
                borderRadius: AppSpacing.cardRadius,
                child: Column(
                  children: [
                    _NavigationRow(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      onTap: () {},
                    ),
                    _Divider(),
                    _NavigationRow(
                      icon: Icons.chat_bubble_outline,
                      title: 'Contact Support',
                      onTap: () {},
                    ),
                    _Divider(),
                    _NavigationRow(
                      icon: Icons.bug_report_outlined,
                      title: 'Report a Problem',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 36)),

          // Sign out
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: AnimatedPressScale(
                onTap: () => _showLogoutConfirmation(context, ref),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                    BorderRadius.circular(AppSpacing.buttonRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      'Sign Out',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Version
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding + 24),
                child: Text(
                  'LUXEBOOK  ·  v1.0.0  ·  Build 42',
                  style: AppTypography.overline.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          24,
          AppSpacing.screenPadding,
          MediaQuery.of(ctx).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),
            Text('Sign Out?', style: AppTypography.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'You will need to sign in again to access your account.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: AnimatedPressScale(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.buttonSecondary,
                        borderRadius:
                        BorderRadius.circular(AppSpacing.buttonRadius),
                      ),
                      child: Center(
                        child: Text('Cancel',
                            style: AppTypography.labelLarge),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedPressScale(
                    onTap: () async {
                      Navigator.pop(ctx);
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go('/login');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.buttonPrimary,
                        borderRadius:
                        BorderRadius.circular(AppSpacing.buttonRadius),
                      ),
                      child: Center(
                        child: Text('Sign Out',
                            style: AppTypography.labelLarge
                                .copyWith(color: AppColors.buttonPrimaryText)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final languages = ['English', 'Español', 'Français', 'Deutsch', '日本語', '中文'];
    _showSelectionSheet(context, 'Language', languages, 'English', (_) {});
  }

  void _showCurrencySheet(BuildContext context, WidgetRef ref) {
    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD'];
    final current = ref.read(profileProvider).preferredCurrency;
    _showSelectionSheet(context, 'Currency', currencies, current, (val) {
      ref.read(profileProvider.notifier).updateProfile({'preferred_currency': val});
    });
  }

  void _showSelectionSheet(
      BuildContext context,
      String title,
      List<String> options,
      String current,
      ValueChanged<String> onSelect,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          24,
          AppSpacing.screenPadding,
          MediaQuery.of(ctx).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(title, style: AppTypography.headlineLarge),
            const SizedBox(height: 20),
            ...options.map((option) {
              final isSelected = option == current;
              return AnimatedPressScale(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(option);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        option,
                        style: AppTypography.titleMedium.copyWith(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(Icons.check_rounded,
                            color: AppColors.accent, size: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Row Components
// ─────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 48,
            height: 28,
            child: FittedBox(
              child: Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.accent,
                activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
                inactiveThumbColor: AppColors.textTertiary,
                inactiveTrackColor: AppColors.border,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _NavigationRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPressScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: AppTypography.titleMedium),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SelectionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SelectionRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPressScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: AppTypography.titleMedium),
            ),
            Text(value, style: AppTypography.caption),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right,
                color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.only(left: 50),
      color: AppColors.border.withValues(alpha: 0.5),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          0,
          AppSpacing.screenPadding,
          10,
        ),
        child: Text(title, style: AppTypography.overline),
      ),
    );
  }
}