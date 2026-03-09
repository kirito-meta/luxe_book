import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/surface_container.dart';
import '../../../../core/widgets/animated_press_scale.dart';
import '../../domain/venue_detail_model.dart';

class AvailabilityGrid extends StatefulWidget {
  final List<AvailabilitySlot> slots;
  const AvailabilityGrid({super.key, required this.slots});

  @override
  State<AvailabilityGrid> createState() => _AvailabilityGridState();
}

class _AvailabilityGridState extends State<AvailabilityGrid> {
  int _selectedDateIndex = 0;
  int _selectedSlotIndex = -1;

  final _dates = List.generate(14, (i) => DateTime.now().add(Duration(days: i)));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Availability', style: AppTypography.headlineMedium),
        const SizedBox(height: 16),

        // Date selector
        SizedBox(
          height: 76,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _dates.length,
            itemBuilder: (context, index) {
              final date = _dates[index];
              final isSelected = _selectedDateIndex == index;
              final isToday = index == 0;
              final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

              return AnimatedPressScale(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedDateIndex = index;
                    _selectedSlotIndex = -1;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 54,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent
                          : isToday
                              ? AppColors.accent.withValues(alpha: 0.3)
                              : AppColors.border.withValues(alpha: 0.3),
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 12)]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayNames[date.weekday - 1],
                        style: AppTypography.labelSmall.copyWith(
                          color: isSelected ? Colors.white.withValues(alpha: 0.7) : AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 4, height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.white : AppColors.accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Time slots
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.slots.asMap().entries.map((entry) {
            final index = entry.key;
            final slot = entry.value;
            final isSelected = _selectedSlotIndex == index;
            final isAvailable = slot.isAvailable;

            return AnimatedPressScale(
              onTap: isAvailable
                  ? () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedSlotIndex = index);
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: (MediaQuery.of(context).size.width - 52) / 2,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : !isAvailable
                          ? AppColors.surface.withValues(alpha: 0.3)
                          : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accent
                        : !isAvailable
                            ? AppColors.border.withValues(alpha: 0.15)
                            : AppColors.border.withValues(alpha: 0.3),
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${slot.startTime} – ${slot.endTime}',
                          style: AppTypography.labelLarge.copyWith(
                            fontSize: 13,
                            color: isAvailable ? AppColors.textPrimary : AppColors.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 10),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Capacity bar
                    Stack(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: slot.fillPercent.clamp(0.0, 1.0),
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: slot.fillPercent > 0.85
                                  ? const Color(0xFFFF5252)
                                  : slot.fillPercent > 0.6
                                      ? AppColors.accent
                                      : AppColors.accent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAvailable ? '${slot.spotsLeft} spots left' : 'Sold out',
                      style: AppTypography.caption.copyWith(
                        fontSize: 10,
                        color: !isAvailable
                            ? AppColors.textTertiary
                            : slot.spotsLeft < 10
                                ? const Color(0xFFFF5252)
                                : AppColors.textSecondary,
                        fontWeight: slot.spotsLeft < 10 ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}