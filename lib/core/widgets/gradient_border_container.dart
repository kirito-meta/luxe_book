import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A container with a subtle accent-colored border.
/// Used sparingly for featured or elevated content.
class AccentContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color borderColor;

  const AccentContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
    this.borderColor = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}