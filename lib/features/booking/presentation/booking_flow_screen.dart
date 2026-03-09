import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_press_scale.dart';
import '../../../core/widgets/surface_container.dart';
import '../../venue_detail/domain/venue_detail_model.dart';

class BookingFlowSheet extends StatefulWidget {
  final VenueDetailModel venue;
  final VenueServiceModel selectedService;
  final List<AvailabilitySlot> availableSlots;

  const BookingFlowSheet({
    super.key,
    required this.venue,
    required this.selectedService,
    required this.availableSlots,
  });

  @override
  State<BookingFlowSheet> createState() => _BookingFlowSheetState();
}

class _BookingFlowSheetState extends State<BookingFlowSheet> {
  int _currentStep = 0;
  AvailabilitySlot? _selectedSlot;
  int _guestCount = 1;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep == 0 && _selectedSlot == null) return;
    if (_currentStep < 2) {
      HapticFeedback.selectionClick();
      setState(() => _currentStep++);
    } else {
      _confirmBooking();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  void _confirmBooking() {
    HapticFeedback.heavyImpact();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking confirmed!',
            style: AppTypography.labelLarge.copyWith(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  double get _subtotal => widget.selectedService.price * _guestCount;
  double get _tax => _subtotal * 0.08;
  double get _total => _subtotal + _tax;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              topPadding + 12,
              AppSpacing.screenPadding,
              16,
            ),
            child: Row(
              children: [
                AnimatedPressScale(
                  onTap: _back,
                  child: SurfaceContainer(
                    borderRadius: 12,
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      _currentStep == 0 ? Icons.close : Icons.arrow_back,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text('Book ${widget.venue.name}',
                    style: AppTypography.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),

          // Progress
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: Row(
              children: List.generate(3, (i) {
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: i <= _currentStep
                          ? AppColors.accent
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding, vertical: 8),
            child: Row(
              children: [
                _StepLabel(text: 'Time', isActive: _currentStep >= 0),
                const Spacer(),
                _StepLabel(text: 'Details', isActive: _currentStep >= 1),
                const Spacer(),
                _StepLabel(text: 'Confirm', isActive: _currentStep >= 2),
              ],
            ),
          ),

          // Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _currentStep == 0
                  ? _TimeStep(
                key: const ValueKey(0),
                slots: widget.availableSlots,
                selectedSlot: _selectedSlot,
                onSelect: (s) => setState(() => _selectedSlot = s),
              )
                  : _currentStep == 1
                  ? _DetailsStep(
                key: const ValueKey(1),
                service: widget.selectedService,
                guestCount: _guestCount,
                onGuestChanged: (c) =>
                    setState(() => _guestCount = c),
                notesController: _notesController,
              )
                  : _ReviewStep(
                key: const ValueKey(2),
                venue: widget.venue,
                service: widget.selectedService,
                slot: _selectedSlot!,
                guestCount: _guestCount,
                notes: _notesController.text,
                subtotal: _subtotal,
                tax: _tax,
                total: _total,
              ),
            ),
          ),

          // Bottom bar
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              16,
              AppSpacing.screenPadding,
              bottomPadding + 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                  top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total',
                        style: AppTypography.caption
                            .copyWith(fontSize: 11)),
                    Text('\$${_total.toStringAsFixed(2)}',
                        style: AppTypography.price),
                  ],
                ),
                const Spacer(),
                AnimatedPressScale(
                  onTap: (_currentStep == 0 && _selectedSlot == null)
                      ? null
                      : _next,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: (_currentStep == 0 && _selectedSlot == null)
                          ? AppColors.buttonSecondary
                          : AppColors.buttonPrimary,
                      borderRadius:
                      BorderRadius.circular(AppSpacing.buttonRadius),
                    ),
                    child: Text(
                      _currentStep == 2 ? 'Confirm' : 'Continue',
                      style: AppTypography.labelLarge.copyWith(
                        color: (_currentStep == 0 && _selectedSlot == null)
                            ? AppColors.textTertiary
                            : AppColors.buttonPrimaryText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  final String text;
  final bool isActive;
  const _StepLabel({required this.text, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.overline.copyWith(
        color: isActive ? AppColors.accent : AppColors.textMuted,
        fontSize: 9,
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// STEP 1: Time Selection
// ═══════════════════════════════════════════════

class _TimeStep extends StatelessWidget {
  final List<AvailabilitySlot> slots;
  final AvailabilitySlot? selectedSlot;
  final ValueChanged<AvailabilitySlot> onSelect;

  const _TimeStep({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      physics: const BouncingScrollPhysics(),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = selectedSlot?.id == slot.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AnimatedPressScale(
            onTap: slot.isAvailable ? () => onSelect(slot) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.08)
                    : slot.isAvailable
                    ? AppColors.surface
                    : AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accent.withValues(alpha: 0.4)
                      : AppColors.border,
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${slot.startTime} – ${slot.endTime}',
                        style: AppTypography.titleMedium.copyWith(
                          color: slot.isAvailable
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${slot.spotsLeft} spots left',
                        style: AppTypography.caption.copyWith(
                          color: slot.spotsLeft < 5
                              ? AppColors.warning
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Fill bar
                  SizedBox(
                    width: 60,
                    height: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: slot.fillPercent,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(
                          slot.fillPercent > 0.8
                              ? AppColors.error
                              : slot.fillPercent > 0.5
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: AppColors.background, size: 14),
                    )
                  else if (!slot.isAvailable)
                    Text('Full',
                        style: AppTypography.overline
                            .copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════
// STEP 2: Details
// ═══════════════════════════════════════════════

class _DetailsStep extends StatelessWidget {
  final VenueServiceModel service;
  final int guestCount;
  final ValueChanged<int> onGuestChanged;
  final TextEditingController notesController;

  const _DetailsStep({
    super.key,
    required this.service,
    required this.guestCount,
    required this.onGuestChanged,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service info
          SurfaceContainer(
            borderRadius: 14,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.confirmation_number_outlined,
                      color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.name, style: AppTypography.titleMedium),
                      Text(service.description,
                          style: AppTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Text('\$${service.price.toInt()}',
                    style: AppTypography.price.copyWith(fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Guest count
          Text('GUESTS', style: AppTypography.overline),
          const SizedBox(height: 12),
          SurfaceContainer(
            borderRadius: 14,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.people_outline,
                    color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '$guestCount guest${guestCount > 1 ? 's' : ''}',
                    style: AppTypography.titleMedium,
                  ),
                ),
                AnimatedPressScale(
                  onTap: guestCount > 1
                      ? () => onGuestChanged(guestCount - 1)
                      : null,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: guestCount > 1
                          ? AppColors.surfaceElevated
                          : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(Icons.remove,
                        color: guestCount > 1
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedPressScale(
                  onTap: guestCount < service.maxGuests
                      ? () => onGuestChanged(guestCount + 1)
                      : null,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: guestCount < service.maxGuests
                          ? AppColors.surfaceElevated
                          : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(Icons.add,
                        color: guestCount < service.maxGuests
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notes
          Text('SPECIAL REQUESTS', style: AppTypography.overline),
          const SizedBox(height: 12),
          SurfaceContainer(
            borderRadius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: notesController,
              maxLines: 3,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Allergies, celebrations, preferences...',
                hintStyle: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                fillColor: Colors.transparent,
                filled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// STEP 3: Review
// ═══════════════════════════════════════════════

class _ReviewStep extends StatelessWidget {
  final VenueDetailModel venue;
  final VenueServiceModel service;
  final AvailabilitySlot slot;
  final int guestCount;
  final String notes;
  final double subtotal;
  final double tax;
  final double total;

  const _ReviewStep({
    super.key,
    required this.venue,
    required this.service,
    required this.slot,
    required this.guestCount,
    required this.notes,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Your Booking',
              style: AppTypography.headlineLarge),
          const SizedBox(height: 24),

          // Summary card
          SurfaceContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _SummaryRow(
                    label: 'Venue', value: venue.name),
                _SummaryRow(
                    label: 'Package', value: service.name),
                _SummaryRow(
                    label: 'Time',
                    value: '${slot.startTime} – ${slot.endTime}'),
                _SummaryRow(
                    label: 'Guests', value: '$guestCount'),
                if (notes.isNotEmpty)
                  _SummaryRow(label: 'Notes', value: notes),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Price breakdown
          SurfaceContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _PriceRow(
                  label:
                  '${service.name} × $guestCount',
                  amount: subtotal,
                ),
                const SizedBox(height: 8),
                _PriceRow(label: 'Tax & fees', amount: tax),
                const SizedBox(height: 12),
                Container(height: 0.5, color: AppColors.border),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Total',
                        style: AppTypography.titleLarge),
                    const Spacer(),
                    Text('\$${total.toStringAsFixed(2)}',
                        style: AppTypography.price),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Points earned
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.star_outline_rounded,
                    color: AppColors.accent, size: 18),
                const SizedBox(width: 10),
                Text(
                  'You\'ll earn ${(total * 0.1).round()} loyalty points',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: AppTypography.caption
                    .copyWith(color: AppColors.textTertiary)),
          ),
          Expanded(
            child: Text(value, style: AppTypography.titleMedium),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  const _PriceRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTypography.bodyMedium),
        const Spacer(),
        Text('\$${amount.toStringAsFixed(2)}',
            style: AppTypography.labelLarge),
      ],
    );
  }
}