import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_press_scale.dart';
import '../../../core/widgets/surface_container.dart';
import '../../../core/widgets/accent_container.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profile.isLoading && profile.data == null
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
          strokeWidth: 2,
        ),
      )
          : CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding + 16,
                left: AppSpacing.screenPadding,
                right: AppSpacing.screenPadding,
              ),
              child: Row(
                children: [
                  Text('Profile',
                      style: AppTypography.displaySmall),
                  const Spacer(),
                  AnimatedPressScale(
                    onTap: () => context.push('/settings'),
                    child: SurfaceContainer(
                      borderRadius: 12,
                      padding: const EdgeInsets.all(10),
                      child: const Icon(Icons.settings_outlined,
                          color: AppColors.textSecondary,
                          size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                28,
                AppSpacing.screenPadding,
                0,
              ),
              child: SurfaceContainer(
                borderRadius: AppSpacing.cardRadiusLg,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceElevated,
                            border: Border.all(
                                color: AppColors.border),
                          ),
                          child: ClipOval(
                            child: profile.avatarUrl.isNotEmpty
                                ? Image.network(
                              profile.avatarUrl,
                              fit: BoxFit.cover,
                              width: 64,
                              height: 64,
                              errorBuilder: (_, __, ___) =>
                                  _InitialAvatar(
                                      name: profile
                                          .displayName),
                            )
                                : _InitialAvatar(
                                name: profile.displayName),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.displayName.isNotEmpty
                                    ? profile.displayName
                                    : 'Set up your profile',
                                style: AppTypography.headlineLarge,
                              ),
                              if (profile.username.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '@${profile.username}',
                                  style: AppTypography.caption,
                                ),
                              ],
                              const SizedBox(height: 2),
                              Text(
                                profile.email,
                                style: AppTypography.caption
                                    .copyWith(
                                    color:
                                    AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                        AnimatedPressScale(
                          onTap: () =>
                              context.push('/profile/edit'),
                          child: SurfaceContainer(
                            borderRadius: 10,
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                                Icons.edit_outlined,
                                color: AppColors.textSecondary,
                                size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Tier & stats
                    Row(
                      children: [
                        _TierBadge(tier: profile.loyaltyTier),
                        const SizedBox(width: 10),
                        _StatPill(
                          label: 'Points',
                          value: '${profile.loyaltyPoints}',
                        ),
                        const SizedBox(width: 10),
                        _StatPill(
                          label: 'Bookings',
                          value: '${profile.totalBookings}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                16,
                AppSpacing.screenPadding,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SurfaceContainer(
                      borderRadius: AppSpacing.cardRadius,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text('TOTAL SPENT',
                              style: AppTypography.overline),
                          const SizedBox(height: 8),
                          Text(
                            '\$${profile.totalSpent.toStringAsFixed(0)}',
                            style: AppTypography.price.copyWith(
                                fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SurfaceContainer(
                      borderRadius: AppSpacing.cardRadius,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text('MEMBER SINCE',
                              style: AppTypography.overline),
                          const SizedBox(height: 8),
                          Text(
                            'Jan 2025',
                            style: AppTypography.price.copyWith(
                              fontSize: 24,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // Menu sections
          _MenuSection(
            title: 'ACCOUNT',
            items: [
              _MenuItemData(
                icon: Icons.person_outline,
                label: 'Edit Profile',
                onTap: () => context.push('/profile/edit'),
              ),
              _MenuItemData(
                icon: Icons.receipt_long_outlined,
                label: 'My Reservations',
                onTap: () => context.push('/bookings'),
              ),
              _MenuItemData(
                icon: Icons.favorite_border,
                label: 'Saved Venues',
                onTap: () {},
              ),
              _MenuItemData(
                icon: Icons.credit_card_outlined,
                label: 'Payment Methods',
                onTap: () {},
              ),
            ],
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          _MenuSection(
            title: 'PREFERENCES',
            items: [
              _MenuItemData(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => context.push('/settings'),
              ),
              _MenuItemData(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () {},
              ),
            ],
          ),

          SliverToBoxAdapter(
              child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 120)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Components
// ─────────────────────────────────────────────────

class _InitialAvatar extends StatelessWidget {
  final String name;
  const _InitialAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTypography.displayMedium
              .copyWith(color: AppColors.textTertiary),
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final String tier;
  const _TierBadge({required this.tier});

  Color get _color {
    switch (tier.toLowerCase()) {
      case 'obsidian':
        return AppColors.textPrimary;
      case 'platinum':
        return const Color(0xFF9EA3A8);
      case 'gold':
        return AppColors.accent;
      case 'silver':
        return const Color(0xFF8A8D90);
      default:
        return const Color(0xFF8B7355);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, color: _color, size: 14),
          const SizedBox(width: 6),
          Text(
            tier.toUpperCase(),
            style: AppTypography.overline.copyWith(
              color: _color,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: AppTypography.labelLarge
                  .copyWith(fontSize: 12, color: AppColors.textPrimary)),
          const SizedBox(width: 4),
          Text(label,
              style: AppTypography.overline.copyWith(fontSize: 9)),
        ],
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItemData> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(title, style: AppTypography.overline),
            ),
            SurfaceContainer(
              borderRadius: AppSpacing.cardRadius,
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    AnimatedPressScale(
                      onTap: items[i].onTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        child: Row(
                          children: [
                            Icon(items[i].icon,
                                color: AppColors.textSecondary,
                                size: 20),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(items[i].label,
                                  style: AppTypography.titleMedium),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppColors.textTertiary,
                                size: 20),
                          ],
                        ),
                      ),
                    ),
                    if (i < items.length - 1)
                      Container(
                        height: 0.5,
                        margin: const EdgeInsets.only(left: 50),
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}