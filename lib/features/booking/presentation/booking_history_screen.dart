import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_press_scale.dart';
import '../../../core/widgets/surface_container.dart';
import '../domain/booking_model.dart';
import '../providers/booking_provider.dart';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    HapticFeedback.mediumImpact();
    await ref.read(bookingListProvider.notifier).loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingListProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: topPadding + 16,
              left: AppSpacing.screenPadding,
              right: AppSpacing.screenPadding,
              bottom: 16,
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
                Text('Reservations',
                    style: AppTypography.displaySmall),
                const Spacer(),
                AnimatedPressScale(
                  onTap: _refresh,
                  child: SurfaceContainer(
                    borderRadius: 12,
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.refresh,
                        color: AppColors.textSecondary, size: 20),
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(3),
              dividerHeight: 0,
              labelStyle: AppTypography.labelLarge,
              unselectedLabelStyle: AppTypography.labelMedium,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textTertiary,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Upcoming'),
                      if (state.upcoming.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${state.upcoming.length}',
                            style: AppTypography.overline.copyWith(
                              color: AppColors.accent,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'Past'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: state.isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2,
              ),
            )
                : TabBarView(
              controller: _tabController,
              children: [
                _BookingList(
                  bookings: state.upcoming,
                  emptyIcon: Icons.calendar_today_rounded,
                  emptyTitle: 'No upcoming reservations',
                  emptySubtitle:
                  'Your next adventure is just a tap away',
                  onRefresh: _refresh,
                  onBookingTap: (b) =>
                      context.push('/venue/${b.venueId}'),
                  onCancel: (b) => _showCancelDialog(context, b),
                ),
                _BookingList(
                  bookings: state.past,
                  emptyIcon: Icons.history_rounded,
                  emptyTitle: 'No past reservations',
                  emptySubtitle:
                  'Your booking history will appear here',
                  onRefresh: _refresh,
                  onBookingTap: (b) =>
                      context.push('/venue/${b.venueId}'),
                  onCancel: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, BookingModel booking) {
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            24,
            AppSpacing.screenPadding,
            MediaQuery.of(sheetContext).padding.bottom + 24,
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
              Text('Cancel Reservation',
                  style: AppTypography.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to cancel your reservation at ${booking.venueName}?',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Reason for cancellation (optional)',
                  fillColor: AppColors.surfaceElevated,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AnimatedPressScale(
                      onTap: () => Navigator.pop(sheetContext),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.buttonSecondary,
                          borderRadius: BorderRadius.circular(
                              AppSpacing.buttonRadius),
                        ),
                        child: Center(
                          child: Text('Keep Reservation',
                              style: AppTypography.labelLarge),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedPressScale(
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        HapticFeedback.mediumImpact();
                        await ref
                            .read(bookingListProvider.notifier)
                            .cancelBooking(
                          booking.id,
                          reason: reasonController.text.isNotEmpty
                              ? reasonController.text
                              : null,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(
                              AppSpacing.buttonRadius),
                        ),
                        child: Center(
                          child: Text('Cancel',
                              style: AppTypography.labelLarge
                                  .copyWith(color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Booking List
// ─────────────────────────────────────────────

class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;
  final ValueChanged<BookingModel> onBookingTap;
  final ValueChanged<BookingModel>? onCancel;

  const _BookingList({
    required this.bookings,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
    required this.onBookingTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return _EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: 4,
        ),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _BookingCard(
            booking: bookings[index],
            onTap: () => onBookingTap(bookings[index]),
            onCancel: onCancel != null
                ? () => onCancel!(bookings[index])
                : null,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Booking Card
// ─────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;
  final VoidCallback? onCancel;

  const _BookingCard({
    required this.booking,
    required this.onTap,
    this.onCancel,
  });

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return AppColors.success;
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.checkedIn:
        return AppColors.accent;
      case BookingStatus.completed:
        return AppColors.textTertiary;
      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        return AppColors.error;
      case BookingStatus.refunded:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return AnimatedPressScale(
      onTap: onTap,
      child: SurfaceContainer(
        borderRadius: AppSpacing.cardRadius,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: booking.venueImageUrl.isNotEmpty
                        ? Image.network(
                      booking.venueImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _Placeholder(name: booking.venueName),
                    )
                        : _Placeholder(name: booking.venueName),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              booking.venueName,
                              style: AppTypography.titleLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              booking.status.displayName,
                              style: AppTypography.overline.copyWith(
                                color: _statusColor,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(booking.serviceName,
                          style: AppTypography.caption),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              color: AppColors.textTertiary, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${dayNames[booking.date.weekday - 1]}, '
                                '${monthNames[booking.date.month - 1]} ${booking.date.day}',
                            style: AppTypography.labelMedium,
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.access_time_rounded,
                              color: AppColors.textTertiary, size: 12),
                          const SizedBox(width: 4),
                          Text(booking.startTime,
                              style: AppTypography.labelMedium),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 0.5, color: AppColors.border),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.people_outline_rounded,
                    color: AppColors.textTertiary, size: 15),
                const SizedBox(width: 4),
                Text(
                  '${booking.guestCount} guest${booking.guestCount > 1 ? 's' : ''}',
                  style: AppTypography.labelMedium,
                ),
                const Spacer(),
                Text(
                  '\$${booking.totalAmount.toStringAsFixed(0)}',
                  style: AppTypography.price.copyWith(fontSize: 17),
                ),
              ],
            ),
            if (onCancel != null && booking.canCancel) ...[
              const SizedBox(height: 14),
              AnimatedPressScale(
                onTap: onCancel,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: Text('Cancel Reservation',
                        style: AppTypography.labelLarge
                            .copyWith(color: AppColors.error)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String name;
  const _Placeholder({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTypography.headlineLarge
              .copyWith(color: AppColors.textMuted),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.textTertiary, size: 32),
            ),
            const SizedBox(height: 24),
            Text(title, style: AppTypography.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: AppTypography.bodyMedium,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}