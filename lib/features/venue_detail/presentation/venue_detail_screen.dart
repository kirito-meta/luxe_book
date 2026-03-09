import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/surface_container.dart';
import '../../../core/widgets/animated_press_scale.dart';
import '../../../core/widgets/gradient_border_container.dart';
import '../domain/venue_detail_model.dart';
import '../../booking/presentation/booking_flow_screen.dart';
import 'widgets/immersive_header.dart';
import 'widgets/availability_grid.dart';
import 'widgets/review_section.dart';
import 'widgets/photo_gallery.dart';

class VenueDetailScreen extends ConsumerStatefulWidget {
  final String venueId;
  const VenueDetailScreen({super.key, required this.venueId});

  @override
  ConsumerState<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends ConsumerState<VenueDetailScreen>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _fabController;
  late final AnimationController _heartController;
  late final Animation<double> _fabScale;
  double _scrollOffset = 0;
  bool _isFavorited = false;
  int _selectedServiceIndex = 0;

  static final _venue = VenueDetailModel(
    id: '1',
    name: 'Nebula Rooftop',
    tagline: 'Sky-high cocktails & cosmic vibes',
    description:
    'Perched atop the tallest tower in the Arts District, Nebula Rooftop redefines nightlife with its '
        '360° panoramic views, molecular mixology bar, and world-class DJ residencies. '
        'Our space features three distinct zones: the open-air Sky Deck for stargazing, '
        'the Infinity Lounge with its suspended glass floor, and the exclusive Cosmos VIP area. '
        'Every detail—from the bioluminescent cocktail garnishes to the reactive LED ceiling—has been '
        'crafted to create an otherworldly experience.',
    coverImageUrl: '',
    galleryUrls: List.generate(8, (_) => ''),
    category: 'Nightlife',
    rating: 4.9,
    reviewCount: 2341,
    priceFrom: 45,
    address: '1200 Skyline Blvd, Floor 52',
    city: 'Downtown Core',
    priceTier: 3,
    maxCapacity: 350,
    isLive: true,
    liveCount: 284,
    isVerified: true,
    isFeatured: true,
    tags: ['Rooftop', 'DJ Sets', 'VIP', 'Cocktails', 'Views'],
    amenities: [
      'Valet Parking',
      'Coat Check',
      'Private Rooms',
      'Bottle Service',
      'Smoking Terrace',
      'Wheelchair Access',
      'Full Kitchen',
      'Live Music',
    ],
    openingHours: {
      'Mon': 'Closed',
      'Tue': '6PM – 2AM',
      'Wed': '6PM – 2AM',
      'Thu': '6PM – 3AM',
      'Fri': '5PM – 4AM',
      'Sat': '5PM – 4AM',
      'Sun': '4PM – 12AM',
    },
    phone: '+1 (555) 234-5678',
    website: 'https://nebularooftop.com',
    services: const [
      VenueServiceModel(
        id: 's1',
        name: 'General Admission',
        description: 'Access to main floor and Sky Deck',
        price: 45,
        durationMinutes: 240,
        maxGuests: 1,
        category: 'entry',
      ),
      VenueServiceModel(
        id: 's2',
        name: 'VIP Table (4 guests)',
        description: 'Reserved table in Infinity Lounge with bottle',
        price: 320,
        durationMinutes: 300,
        maxGuests: 4,
        category: 'vip',
      ),
      VenueServiceModel(
        id: 's3',
        name: 'Cosmos Suite (8 guests)',
        description: 'Private suite with dedicated host, 2 bottles',
        price: 850,
        durationMinutes: 300,
        maxGuests: 8,
        category: 'vip',
      ),
      VenueServiceModel(
        id: 's4',
        name: 'Birthday Package',
        description: 'Decorated area, cake, champagne, photographer',
        price: 550,
        durationMinutes: 300,
        maxGuests: 10,
        category: 'event',
      ),
      VenueServiceModel(
        id: 's5',
        name: 'Cocktail Masterclass',
        description: 'Learn molecular mixology from our head bartender',
        price: 120,
        durationMinutes: 90,
        maxGuests: 2,
        category: 'experience',
      ),
    ],
    reviews: [
      VenueReviewModel(
        id: 'r1',
        userName: 'Jessica M.',
        rating: 5,
        title: 'Absolutely magical',
        body:
        'The view alone is worth it, but the cocktails and atmosphere take it to another level. The Cosmos VIP was an unforgettable experience.',
        ambianceRating: 5,
        serviceRating: 5,
        valueRating: 4,
        helpfulCount: 42,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      VenueReviewModel(
        id: 'r2',
        userName: 'Marcus T.',
        rating: 5,
        title: 'Best nightlife in the city',
        body:
        'The DJ lineup is always incredible. Sound system is top-tier. Staff knows how to make you feel special.',
        ambianceRating: 5,
        serviceRating: 5,
        valueRating: 5,
        helpfulCount: 28,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      VenueReviewModel(
        id: 'r3',
        userName: 'Sophia L.',
        rating: 4,
        title: 'Great but pricey',
        body:
        'Beautiful venue with incredible design. Cocktails are innovative. Only downside is it gets very crowded on weekends.',
        ambianceRating: 5,
        serviceRating: 4,
        valueRating: 3,
        helpfulCount: 15,
        ownerReply:
        'Thank you Sophia! We recommend our Thursday nights for a more relaxed experience. Hope to see you back soon!',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
    ],
  );

  static const _mockSlots = [
    AvailabilitySlot(id: 'a1', startTime: '17:00', endTime: '19:00', totalCapacity: 50, bookedCount: 12),
    AvailabilitySlot(id: 'a2', startTime: '19:00', endTime: '21:00', totalCapacity: 50, bookedCount: 38),
    AvailabilitySlot(id: 'a3', startTime: '21:00', endTime: '23:00', totalCapacity: 80, bookedCount: 72),
    AvailabilitySlot(id: 'a4', startTime: '23:00', endTime: '01:00', totalCapacity: 80, bookedCount: 65),
    AvailabilitySlot(id: 'a5', startTime: '01:00', endTime: '03:00', totalCapacity: 60, bookedCount: 20),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fabScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _fabController.forward();
    });
  }

  void _onScroll() {
    setState(() => _scrollOffset = _scrollController.offset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    HapticFeedback.mediumImpact();
    setState(() => _isFavorited = !_isFavorited);
    if (_isFavorited) {
      _heartController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    const headerHeight = 380.0;
    final headerCollapse = (_scrollOffset / headerHeight).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ImmersiveHeader(
                  venue: _venue,
                  scrollOffset: _scrollOffset,
                  isFavorited: _isFavorited,
                  onFavorite: _toggleFavorite,
                  heartController: _heartController,
                ),
              ),
              SliverToBoxAdapter(
                child: _QuickInfoBar(venue: _venue),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding, 20, AppSpacing.screenPadding, 0,
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _venue.tags.map((tag) => _TagChip(tag: tag)).toList(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding, 28, AppSpacing.screenPadding, 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('About', style: AppTypography.headlineMedium),
                      const SizedBox(height: 12),
                      Text(
                        _venue.description,
                        style: AppTypography.bodyLarge.copyWith(height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: PhotoGallery(imageUrls: _venue.galleryUrls),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding, 28, AppSpacing.screenPadding, 0,
                  ),
                  child: Text('Packages & Experiences', style: AppTypography.headlineMedium),
                ),
              ),
              SliverToBoxAdapter(
                child: _ServicesList(
                  services: _venue.services,
                  selectedIndex: _selectedServiceIndex,
                  onSelect: (i) => setState(() => _selectedServiceIndex = i),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding, 28, AppSpacing.screenPadding, 0,
                  ),
                  child: AvailabilityGrid(slots: _mockSlots),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding, 28, AppSpacing.screenPadding, 0,
                  ),
                  child: _AmenitiesSection(amenities: _venue.amenities),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding, 28, AppSpacing.screenPadding, 0,
                  ),
                  child: _OpeningHoursSection(hours: _venue.openingHours),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding, 28, AppSpacing.screenPadding, 0,
                  ),
                  child: ReviewSection(
                    reviews: _venue.reviews,
                    averageRating: _venue.rating,
                    totalReviews: _venue.reviewCount,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding, 28, AppSpacing.screenPadding, 0,
                  ),
                  child: _LocationSection(venue: _venue),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),

          // Collapsing app bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: topPadding + 56,
              decoration: BoxDecoration(
                color: AppColors.background
                    .withValues(alpha: headerCollapse > 0.6 ? 0.95 : 0.0),
              ),
              child: // New:
              Container(
                color: AppColors.background.withValues(alpha: 0.95),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          AnimatedPressScale(
                            onTap: () => Navigator.pop(context),
                            child: SurfaceContainer(
                              borderRadius: 14,

                              padding: const EdgeInsets.all(10),
                              child: const Icon(Icons.arrow_back_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (headerCollapse > 0.6)
                            Expanded(
                              child: Text(
                                _venue.name,
                                style: AppTypography.titleLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          else
                            const Spacer(),
                          AnimatedPressScale(
                            onTap: () {},
                            child: SurfaceContainer(
                              borderRadius: 14,

                              padding: const EdgeInsets.all(10),
                              child: const Icon(Icons.share_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),


          // Bottom booking bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBookingBar(
              service: _venue.services[_selectedServiceIndex],
              fabScale: _fabScale,
              onBook: () => _openBookingFlow(context),
            ),
          ),
        ],
      ),
    );
  }

  void _openBookingFlow(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BookingFlowSheet(
              venue: _venue,
              selectedService: _venue.services[_selectedServiceIndex],
              availableSlots: _mockSlots,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        fullscreenDialog: true,
      ),
    );
  }
}

// ============================================
// PRIVATE WIDGETS
// ============================================

class _QuickInfoBar extends StatelessWidget {
  final VenueDetailModel venue;
  const _QuickInfoBar({required this.venue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 20, AppSpacing.screenPadding, 0),
      // FIX: Replaced rigid Row with a Wrap. If the screen is too narrow,
      // the verified badge will seamlessly drop to the next line instead of crashing.
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _InfoPill(
            icon: Icons.star_rounded,
            label: '${venue.rating}',
            sublabel: '(${venue.reviewCount})',
            color: AppColors.accent,
          ),
          _InfoPill(
            icon: Icons.attach_money_rounded,
            label: List.generate(venue.priceTier, (_) => '\$').join(),
            sublabel: '',
            color: AppColors.accent,
          ),
          _InfoPill(
            icon: Icons.people_rounded,
            label: '${venue.maxCapacity}',
            sublabel: 'cap',
            color: AppColors.accent,
          ),
          if (venue.isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded, color: AppColors.accent, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Verified',
                    style: AppTypography.labelSmall.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold
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

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style:
            AppTypography.labelLarge.copyWith(color: color, fontSize: 12),
          ),
          if (sublabel.isNotEmpty) ...[
            const SizedBox(width: 2),
            Text(sublabel,
                style: AppTypography.caption.copyWith(fontSize: 10)),
          ],
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Text(tag, style: AppTypography.caption.copyWith(fontSize: 12)),
    );
  }
}

class _ServicesList extends StatelessWidget {
  final List<VenueServiceModel> services;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _ServicesList({
    required this.services,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding, 16, AppSpacing.screenPadding, 0),
        physics: const BouncingScrollPhysics(),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          final isSelected = selectedIndex == index;

          return AnimatedPressScale(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 200,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius:
                BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accent.withValues(alpha: 0.5)
                      : AppColors.border.withValues(alpha: 0.3),
                  width: isSelected ? 1.5 : 0.5,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                      color:
                      AppColors.accent.withValues(alpha: 0.1),
                      blurRadius: 16)
                ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent.withValues(alpha: 0.2)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _categoryIcon(service.category),
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textTertiary,
                          size: 18,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 12),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    service.name,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    style: AppTypography.caption.copyWith(fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${service.price.toInt()}',
                        style: AppTypography.price.copyWith(
                          fontSize: 18,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ ${service.maxGuests > 1 ? "${service.maxGuests} guests" : "person"}',
                        style:
                        AppTypography.caption.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'entry':
        return Icons.confirmation_number_rounded;
      case 'vip':
        return Icons.diamond_rounded;
      case 'event':
        return Icons.celebration_rounded;
      case 'experience':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.local_activity_rounded;
    }
  }
}

class _AmenitiesSection extends StatelessWidget {
  final List<String> amenities;
  const _AmenitiesSection({required this.amenities});

  IconData _iconFor(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('parking') || lower.contains('valet'))
      return Icons.local_parking_rounded;
    if (lower.contains('coat')) return Icons.checkroom_rounded;
    if (lower.contains('private') || lower.contains('room'))
      return Icons.meeting_room_rounded;
    if (lower.contains('bottle')) return Icons.wine_bar_rounded;
    if (lower.contains('smoking')) return Icons.smoking_rooms_rounded;
    if (lower.contains('wheel') || lower.contains('access'))
      return Icons.accessible_rounded;
    if (lower.contains('kitchen') || lower.contains('food'))
      return Icons.restaurant_rounded;
    if (lower.contains('music') || lower.contains('live'))
      return Icons.music_note_rounded;
    return Icons.check_circle_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amenities', style: AppTypography.headlineMedium),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: amenities.map((a) {
            return Container(
              width: (MediaQuery.of(context).size.width - 52) / 2,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(_iconFor(a), color: AppColors.accent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      a,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _OpeningHoursSection extends StatelessWidget {
  final Map<String, String> hours;
  const _OpeningHoursSection({required this.hours});

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final todayIndex = now.weekday - 1;
    final todayKey = days[todayIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Opening Hours', style: AppTypography.headlineMedium),
            const SizedBox(width: 10),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: hours[todayKey] != 'Closed'
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : const Color(0xFFFF5252).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                hours[todayKey] != 'Closed' ? 'Open' : 'Closed',
                style: AppTypography.labelSmall.copyWith(
                  color: hours[todayKey] != 'Closed'
                      ? AppColors.accent
                      : const Color(0xFFFF5252),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SurfaceContainer(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: days.asMap().entries.map((entry) {
              final isToday = entry.key == todayIndex;
              final day = entry.value;
              final time = hours[day] ?? 'Closed';

              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: isToday
                    ? BoxDecoration(
                  color:
                  AppColors.accent.withValues(alpha: 0.06),
                  border: const Border(
                      left: BorderSide(
                          color: AppColors.accent, width: 3)),
                )
                    : null,
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        style: AppTypography.labelLarge.copyWith(
                          fontSize: 13,
                          color: isToday
                              ? AppColors.accent
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      time,
                      style: AppTypography.bodyMedium.copyWith(
                        color: time == 'Closed'
                            ? AppColors.textTertiary
                            : isToday
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight:
                        isToday ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _LocationSection extends StatelessWidget {
  final VenueDetailModel venue;
  const _LocationSection({required this.venue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location', style: AppTypography.headlineMedium),
        const SizedBox(height: 16),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
            BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              CustomPaint(
                painter: _GridPainter(),
                size: const Size(double.infinity, 180),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                        AppColors.accent.withValues(alpha: 0.4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.location_on_rounded,
                      color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.location_on_outlined,
                color: AppColors.textTertiary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${venue.address}, ${venue.city}',
                style: AppTypography.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnimatedPressScale(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_rounded,
                          color: AppColors.accent, size: 18),
                      SizedBox(width: 8),
                      Text('Directions',
                          style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedPressScale(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_rounded,
                          color: AppColors.accent, size: 18),
                      SizedBox(width: 8),
                      Text('Call',
                          style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.15)
      ..strokeWidth = 0.5;
    for (var i = 0.0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (var i = 0.0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomBookingBar extends StatelessWidget {
  final VenueServiceModel service;
  final Animation<double> fabScale;
  final VoidCallback onBook;

  const _BottomBookingBar({
    required this.service,
    required this.fabScale,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            16,
            AppSpacing.screenPadding,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.85),
            border: Border(
                top: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.3))),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('From',
                      style: AppTypography.caption.copyWith(fontSize: 11)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$${service.price.toInt()}',
                        style: AppTypography.price
                            .copyWith(fontSize: 26),
                      ),
                      Text(
                        ' / ${service.maxGuests > 1 ? "group" : "person"}',
                        style:
                        AppTypography.caption.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              ScaleTransition(
                scale: fabScale,
                child: AnimatedPressScale(
                  onTap: onBook,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent
                              .withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.bolt_rounded,
                            color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Book Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}