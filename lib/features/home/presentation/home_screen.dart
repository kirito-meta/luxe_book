import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_press_scale.dart';
import '../../../core/widgets/surface_container.dart';
import '../domain/venue_model.dart';
import '../domain/category_model.dart';
import '../providers/home_provider.dart';
import '../../profile/providers/profile_provider.dart';

/// Curated venue images — high-resolution Unsplash URLs
/// that resolve reliably. Used as fallbacks when Supabase
/// venue records have no cover_image_url.
const _fallbackImages = [
  'https://images.unsplash.com/photo-1566417713940-fe7c737a9ef2?w=800&q=80',
  'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80',
  'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=800&q=80',
  'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800&q=80',
  'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?w=800&q=80',
  'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80',
  'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=800&q=80',
];

String _imageFor(VenueModel v, int index) {
  if (v.imageUrl.isNotEmpty) return v.imageUrl;
  return _fallbackImages[index % _fallbackImages.length];
}

const _categories = [
  CategoryModel(id: 'all', name: 'All', icon: Icons.apps_rounded),
  CategoryModel(id: 'nightclub', name: 'Nightlife', icon: Icons.nightlife_rounded),
  CategoryModel(id: 'restaurant', name: 'Dining', icon: Icons.restaurant_rounded),
  CategoryModel(id: 'spa', name: 'Wellness', icon: Icons.spa_rounded),
  CategoryModel(id: 'event', name: 'Events', icon: Icons.celebration_rounded),
  CategoryModel(id: 'hotel', name: 'Stays', icon: Icons.hotel_rounded),
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeProvider);
    final profile = ref.watch(profileProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    final trending = selectedCategory == 'all'
        ? home.trending
        : home.trending.where((v) => v.category == selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeProvider.notifier).loadAll(),
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── Header ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  topPadding + 16,
                  AppSpacing.screenPadding,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting,
                            style: AppTypography.overline,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.displayName.isNotEmpty
                                ? profile.displayName
                                : 'Welcome back',
                            style: AppTypography.displaySmall,
                          ),
                        ],
                      ),
                    ),
                    AnimatedPressScale(
                      onTap: () => context.go('/notifications'),
                      child: SurfaceContainer(
                        borderRadius: 14,
                        padding: const EdgeInsets.all(11),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedPressScale(
                      onTap: () => context.go('/profile'),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceElevated,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipOval(
                          child: profile.avatarUrl.isNotEmpty
                              ? Image.network(
                            profile.avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                profile.displayName.isNotEmpty
                                    ? profile.displayName[0].toUpperCase()
                                    : '?',
                                style: AppTypography.labelLarge
                                    .copyWith(color: AppColors.textTertiary),
                              ),
                            ),
                          )
                              : Center(
                            child: Text(
                              profile.displayName.isNotEmpty
                                  ? profile.displayName[0].toUpperCase()
                                  : '?',
                              style: AppTypography.labelLarge
                                  .copyWith(color: AppColors.textTertiary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Search Bar ─────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding, 24, AppSpacing.screenPadding, 0,
                ),
                child: AnimatedPressScale(
                  scaleDown: 0.98,
                  onTap: () => context.push('/search'),
                  child: SurfaceContainer(
                    borderRadius: 14,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: AppColors.textTertiary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Search venues, experiences...',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textTertiary),
                        ),
                        const Spacer(),
                        Container(
                          width: 1,
                          height: 20,
                          color: AppColors.border,
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.tune,
                            color: AppColors.textTertiary, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Categories ─────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 28),
                child: SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = selectedCategory == cat.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AnimatedPressScale(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref.read(selectedCategoryProvider.notifier).state = cat.id;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.buttonPrimary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                  color: AppColors.border,
                                  width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cat.icon,
                                  size: 16,
                                  color: isSelected
                                      ? AppColors.buttonPrimaryText
                                      : AppColors.textTertiary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  cat.name,
                                  style: AppTypography.labelLarge.copyWith(
                                    fontSize: 12,
                                    color: isSelected
                                        ? AppColors.buttonPrimaryText
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Featured Hero ──────────────────
            if (home.featured.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: _HeroCarousel(
                    venues: home.featured,
                    onTap: (v) => context.push('/venue/${v.id}'),
                  ),
                ),
              ),
            ],

            // ── Trending ───────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding, 36, AppSpacing.screenPadding, 0,
                ),
                child: _SectionHeader(
                  title: 'Trending',
                  action: 'See all',
                  onAction: () => context.push('/search'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: trending.isEmpty && !home.isLoading
                    ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding),
                  child: SurfaceContainer(
                    borderRadius: AppSpacing.cardRadius,
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No venues in this category yet',
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ),
                )
                    : SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding),
                    physics: const BouncingScrollPhysics(),
                    itemCount: trending.length,
                    itemBuilder: (context, index) {
                      return _VenueCard(
                        venue: trending[index],
                        imageUrl: _imageFor(trending[index], index),
                        onTap: () => context.push(
                            '/venue/${trending[index].id}'),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Live Now ───────────────────────
            if (home.live.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding, 36, AppSpacing.screenPadding, 0,
                  ),
                  child: _SectionHeader(
                    title: 'Happening Now',
                    action: 'View all',
                    onAction: () => context.go('/explore'),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding),
                      physics: const BouncingScrollPhysics(),
                      itemCount: home.live.length,
                      itemBuilder: (context, index) {
                        return _LiveCard(
                          venue: home.live[index],
                          imageUrl: _imageFor(home.live[index], index + 3),
                          onTap: () => context.push(
                              '/venue/${home.live[index].id}'),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],

            // ── Curated Grid ───────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding, 36, AppSpacing.screenPadding, 0,
                ),
                child: _SectionHeader(
                  title: 'Curated for You',
                  action: 'More',
                  onAction: () => context.push('/search'),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 16, AppSpacing.screenPadding, 0,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index >= home.trending.length) return null;
                    final v = home.trending[index];
                    return _GridCard(
                      venue: v,
                      imageUrl: _imageFor(v, index),
                      onTap: () => context.push('/venue/${v.id}'),
                    );
                  },
                  childCount: home.trending.length.clamp(0, 6),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 120),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// HERO CAROUSEL
// ═══════════════════════════════════════════════════

class _HeroCarousel extends StatefulWidget {
  final List<VenueModel> venues;
  final ValueChanged<VenueModel> onTap;

  const _HeroCarousel({required this.venues, required this.onTap});

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  late final PageController _controller;
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.9)
      ..addListener(() {
        setState(() => _page = _controller.page ?? 0);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.venues.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final venue = widget.venues[index];
              final parallax = (index - _page).abs();
              final scale = (1 - parallax * 0.06).clamp(0.9, 1.0);

              return Transform.scale(
                scale: scale,
                child: AnimatedPressScale(
                  onTap: () => widget.onTap(venue),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          AppSpacing.cardRadiusLg),
                      border: Border.all(
                          color: AppColors.border, width: 0.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          AppSpacing.cardRadiusLg),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            _imageFor(venue, index),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: AppColors.card),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: AppColors.imageOverlay,
                            ),
                          ),
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 20,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (venue.isLive)
                                  Padding(
                                    padding:
                                    const EdgeInsets.only(bottom: 8),
                                    child: _LiveIndicator(
                                        count: venue.liveCount),
                                  ),
                                Text(
                                  venue.name,
                                  style: AppTypography.headlineLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.star_rounded,
                                        color: AppColors.accent,
                                        size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${venue.rating}',
                                      style: AppTypography.labelLarge
                                          .copyWith(
                                          color: AppColors.accent,
                                          fontSize: 12),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${venue.reviewCount})',
                                      style: AppTypography.caption
                                          .copyWith(fontSize: 11),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'From \$${venue.priceFrom.toInt()}',
                                      style: AppTypography.price
                                          .copyWith(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        // Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.venues.length, (i) {
            final dist = (_page - i).abs().clamp(0.0, 1.0);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: dist < 0.5 ? 20 : 6,
              height: 3,
              decoration: BoxDecoration(
                color: dist < 0.5
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// VENUE CARD (horizontal rail)
// ═══════════════════════════════════════════════════

class _VenueCard extends StatelessWidget {
  final VenueModel venue;
  final String imageUrl;
  final VoidCallback onTap;

  const _VenueCard({
    required this.venue,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPressScale(
      onTap: onTap,
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.surfaceElevated),
                    ),
                    if (venue.tags.isNotEmpty)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.background
                                .withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            venue.tags.first,
                            style: AppTypography.overline.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 8,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: AppTypography.titleMedium
                        .copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: AppColors.accent, size: 13),
                      const SizedBox(width: 3),
                      Text(
                        '${venue.rating}',
                        style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textPrimary),
                      ),
                      Text(
                        ' · ${venue.location}',
                        style: AppTypography.caption
                            .copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'From \$${venue.priceFrom.toInt()}',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.accent,
                          fontSize: 12,
                        ),
                      ),
                      if (venue.isLive)
                        _LiveDot(),
                    ],
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

// ═══════════════════════════════════════════════════
// LIVE CARD
// ═══════════════════════════════════════════════════

class _LiveCard extends StatelessWidget {
  final VenueModel venue;
  final String imageUrl;
  final VoidCallback onTap;

  const _LiveCard({
    required this.venue,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPressScale(
      onTap: onTap,
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: AppColors.live.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(AppSpacing.cardRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.card),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.imageOverlay,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LiveIndicator(count: venue.liveCount),
                    const Spacer(),
                    Text(
                      venue.name,
                      style: AppTypography.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      venue.tagline,
                      style: AppTypography.caption.copyWith(
                          color: AppColors.white60),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

// ═══════════════════════════════════════════════════
// GRID CARD
// ═══════════════════════════════════════════════════

class _GridCard extends StatelessWidget {
  final VenueModel venue;
  final String imageUrl;
  final VoidCallback onTap;

  const _GridCard({
    required this.venue,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPressScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(AppSpacing.cardRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.card),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.imageOverlay,
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      venue.name,
                      style: AppTypography.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: AppColors.accent, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          '${venue.rating}',
                          style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 11),
                        ),
                        const Spacer(),
                        Text(
                          '\$${venue.priceFrom.toInt()}',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.accent,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

// ═══════════════════════════════════════════════════
// SHARED COMPONENTS
// ═══════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTypography.headlineMedium),
        const Spacer(),
        AnimatedPressScale(
          onTap: onAction,
          child: Text(
            action,
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.accent),
          ),
        ),
      ],
    );
  }
}

class _LiveIndicator extends StatelessWidget {
  final int count;
  const _LiveIndicator({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.live,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'LIVE',
            style: AppTypography.overline.copyWith(
              color: AppColors.live,
              fontSize: 8,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: AppColors.live,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.live.withValues(alpha: 0.4),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}