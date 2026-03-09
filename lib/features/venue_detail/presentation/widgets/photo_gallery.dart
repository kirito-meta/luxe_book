import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/animated_press_scale.dart';

class PhotoGallery extends StatelessWidget {
  final List<String> imageUrls;
  const PhotoGallery({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Row(
            children: [
              Text('Photos', style: AppTypography.headlineMedium),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${imageUrls.length}',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              AnimatedPressScale(
                onTap: () {},
                child: Text('View all', style: AppTypography.caption.copyWith(color: AppColors.accent)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            physics: const BouncingScrollPhysics(),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final colors = [
                [AppColors.accent, AppColors.accentMuted],
                [AppColors.accent, const Color(0xFF26A69A)],
                [const Color(0xFFFFB74D), const Color(0xFFFF8E53)],
                [const Color(0xFF9C27B0), AppColors.accent],
                [AppColors.accentMuted, AppColors.accentMuted],
                [const Color(0xFF42A5F5), AppColors.accent],
                [AppColors.accent, AppColors.accent],
                [AppColors.accent, const Color(0xFFFF8E53)],
              ];
              final gradColors = colors[index % colors.length];

              return AnimatedPressScale(
                onTap: () {},
                child: Container(
                  width: 130,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradColors[0].withValues(alpha: 0.3),
                        gradColors[1].withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_rounded,
                      color: gradColors[0].withValues(alpha: 0.4),
                      size: 36,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}