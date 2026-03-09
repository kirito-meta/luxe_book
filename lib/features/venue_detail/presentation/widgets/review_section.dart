import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/surface_container.dart';
import '../../../../core/widgets/animated_press_scale.dart';
import '../../domain/venue_detail_model.dart';

class ReviewSection extends StatelessWidget {
  final List<VenueReviewModel> reviews;
  final double averageRating;
  final int totalReviews;

  const ReviewSection({
    super.key,
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Reviews', style: AppTypography.headlineMedium),
            const Spacer(),
            AnimatedPressScale(
              onTap: () {},
              child: Text('See all', style: AppTypography.caption.copyWith(color: AppColors.accent)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Rating summary
        SurfaceContainer(
          borderRadius: 20,

          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: AppTypography.displayLarge.copyWith(fontSize: 44, color: AppColors.accent),
                  ),
                  Row(
                    children: List.generate(5, (i) {
                      final filled = i < averageRating.floor();
                      final partial = i == averageRating.floor() && averageRating % 1 > 0;
                      return Icon(
                        filled || partial ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: AppColors.accent,
                        size: 18,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalReviews reviews',
                    style: AppTypography.caption.copyWith(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _RatingBar(label: 'Ambiance', value: 4.8),
                    const SizedBox(height: 8),
                    _RatingBar(label: 'Service', value: 4.7),
                    const SizedBox(height: 8),
                    _RatingBar(label: 'Value', value: 4.2),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Review cards
        ...reviews.map((review) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _ReviewCard(review: review),
        )),
      ],
    );
  }
}

class _RatingBar extends StatelessWidget {
  final String label;
  final double value;

  const _RatingBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 65,
          child: Text(label, style: AppTypography.caption.copyWith(fontSize: 11)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (value / 5).clamp(0.0, 1.0),
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(value.toStringAsFixed(1), style: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary, fontSize: 11)),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final VenueReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final daysDiff = DateTime.now().difference(review.createdAt).inDays;
    final timeAgo = daysDiff == 0
        ? 'Today'
        : daysDiff == 1
            ? 'Yesterday'
            : daysDiff < 30
                ? '$daysDiff days ago'
                : '${(daysDiff / 30).floor()} months ago';

    return SurfaceContainer(
      borderRadius: 18,

      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.3),
                      AppColors.accentMuted.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    review.userName.isNotEmpty ? review.userName[0] : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                    Text(timeAgo, style: AppTypography.caption.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppColors.accent,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          if (review.title != null) ...[
            const SizedBox(height: 12),
            Text(review.title!, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
          ],
          if (review.body != null) ...[
            const SizedBox(height: 8),
            Text(
              review.body!,
              style: AppTypography.bodyMedium.copyWith(height: 1.5),
            ),
          ],

          // Owner reply
          if (review.ownerReply != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: AppColors.accent, width: 3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.reply_rounded, color: AppColors.accent, size: 14),
                      const SizedBox(width: 6),
                      Text('Owner', style: AppTypography.labelSmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(review.ownerReply!, style: AppTypography.bodyMedium.copyWith(fontSize: 13, height: 1.4)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          // Helpful
          AnimatedPressScale(
            onTap: () {},
            child: Row(
              children: [
                const Icon(Icons.thumb_up_outlined, color: AppColors.textTertiary, size: 14),
                const SizedBox(width: 6),
                Text('Helpful (${review.helpfulCount})', style: AppTypography.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}