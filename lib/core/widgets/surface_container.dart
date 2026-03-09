import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A clean elevated surface container. No blur, no glass.
/// Just a subtle background lift with optional border.
class SurfaceContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? color;
  final bool showBorder;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SurfaceContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.color,
    this.showBorder = true,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(color: AppColors.border, width: 0.5)
            : null,
      ),
      child: child,
    );
  }
}