import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/surface_container.dart';
import '../../../../core/widgets/animated_press_scale.dart';
import '../../domain/venue_detail_model.dart';

class ImmersiveHeader extends StatelessWidget {
  final VenueDetailModel venue;
  final double scrollOffset;
  final bool isFavorited;
  final VoidCallback onFavorite;
  final AnimationController heartController;

  const ImmersiveHeader({
    super.key,
    required this.venue,
    required this.scrollOffset,
    required this.isFavorited,
    required this.onFavorite,
    required this.heartController,
  });

  @override
  Widget build(BuildContext context) {
    final headerHeight = 380.0;
    final parallax = scrollOffset * 0.4;
    final opacity = (1 - (scrollOffset / headerHeight).clamp(0.0, 1.0)).clamp(0.0, 1.0);

    return SizedBox(
      height: headerHeight,
      child: Stack(
        children: [
          // Background image / gradient
          Positioned(
            top: -parallax,
            left: 0, right: 0,
            height: headerHeight + 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.35),
                    AppColors.accentMuted.withValues(alpha: 0.2),
                    AppColors.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Animated floating orbs
          Positioned(
            top: 40 - parallax * 0.3,
            right: -30,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 120 - parallax * 0.5,
            left: -40,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentMuted.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          Positioned(
            left: 20, right: 20,
            bottom: 20,
            child: Opacity(
              opacity: opacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Live badge
                  if (venue.isLive)
                    _LiveBadgeInline(count: venue.liveCount),
                  if (venue.isLive) const SizedBox(height: 12),

                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      venue.category.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Name
                  Text(venue.name, style: AppTypography.displayLarge.copyWith(fontSize: 34)),
                  const SizedBox(height: 6),

                  // Tagline
                  Text(
                    venue.tagline,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Location row
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.textTertiary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${venue.address}, ${venue.city}',
                        style: AppTypography.caption.copyWith(fontSize: 12),
                      ),
                      const Spacer(),
                      // Favorite button
                      AnimatedPressScale(
                        onTap: onFavorite,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 1.3).animate(
                            CurvedAnimation(parent: heartController, curve: Curves.elasticOut),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isFavorited
                                  ? AppColors.accentMuted.withValues(alpha: 0.2)
                                  : AppColors.surface.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isFavorited ? AppColors.accentMuted : AppColors.textSecondary,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadgeInline extends StatefulWidget {
  final int count;
  const _LiveBadgeInline({required this.count});

  @override
  State<_LiveBadgeInline> createState() => _LiveBadgeInlineState();
}

class _LiveBadgeInlineState extends State<_LiveBadgeInline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SurfaceContainer(
      borderRadius: 10,

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _blinkController,
            builder: (context, _) => Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF4444),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF4444).withValues(alpha: 0.5 * _blinkController.value),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text('LIVE', style: AppTypography.labelSmall.copyWith(color: const Color(0xFFFF6666), fontSize: 10, fontWeight: FontWeight.w900)),
          const SizedBox(width: 8),
          Text('${widget.count} people here now', style: AppTypography.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}