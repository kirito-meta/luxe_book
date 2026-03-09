import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_press_scale.dart';
import '../../../core/widgets/surface_container.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String bookingId;

  const BookingConfirmationScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const Spacer(),
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.success, size: 40),
              ),
              const SizedBox(height: 28),
              Text('Booking Confirmed',
                  style: AppTypography.displaySmall),
              const SizedBox(height: 10),
              Text(
                'Your reservation has been confirmed.\nCheck your email for details.',
                style: AppTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              SurfaceContainer(
                borderRadius: 14,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text('Booking ID',
                        style: AppTypography.caption),
                    const Spacer(),
                    Text(
                      bookingId.length > 8
                          ? '${bookingId.substring(0, 8)}...'
                          : bookingId,
                      style: AppTypography.labelLarge
                          .copyWith(fontFamily: 'monospace'),
                    ),
                    const SizedBox(width: 8),
                    AnimatedPressScale(
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: bookingId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied!',
                                style: AppTypography.labelLarge
                                    .copyWith(color: Colors.white)),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Icon(Icons.copy,
                          color: AppColors.textTertiary, size: 16),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),

              // Actions
              AnimatedPressScale(
                onTap: () => context.go('/bookings'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.buttonPrimary,
                    borderRadius:
                    BorderRadius.circular(AppSpacing.buttonRadius),
                  ),
                  child: Center(
                    child: Text('View My Bookings',
                        style: AppTypography.labelLarge.copyWith(
                            color: AppColors.buttonPrimaryText)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedPressScale(
                onTap: () => context.go('/home'),
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
                    child: Text('Back to Home',
                        style: AppTypography.labelLarge),
                  ),
                ),
              ),
              SizedBox(height: bottomPadding),
            ],
          ),
        ),
      ),
    );
  }
}