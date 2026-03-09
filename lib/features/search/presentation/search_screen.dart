import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_press_scale.dart';
import '../../../core/widgets/surface_container.dart';
import '../../../services/supabase_provider.dart';
import '../../home/domain/venue_model.dart';

const _searchFallbackImages = [
  'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&q=80',
  'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600&q=80',
  'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=600&q=80',
  'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
  'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?w=600&q=80',
];

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  List<VenueModel> _results = [];
  List<String> _recentSearches = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  // Filters
  double _minPrice = 0;
  double _maxPrice = 500;
  double _minRating = 0;
  String? _selectedCategory;
  String _sortBy = 'rating';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    Future.microtask(() => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveSearch(String query) async {
    if (query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 8) {
      _recentSearches = _recentSearches.sublist(0, 8);
    }
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    setState(() => _recentSearches = []);
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);

    try {
      final service = ref.read(supabaseServiceProvider);
      final data = await service.getVenues(
        searchQuery: query,
        categoryId: _selectedCategory,
        limit: 30,
      );

      List<VenueModel> results =
      data.map<VenueModel>((m) => VenueModel.fromMap(m)).toList();

      // Client-side filters
      results = results.where((VenueModel v) {
        if (v.priceFrom < _minPrice || v.priceFrom > _maxPrice) return false;
        if (v.rating < _minRating) return false;
        return true;
      }).toList();

      // Sort
      switch (_sortBy) {
        case 'rating':
          results.sort((VenueModel a, VenueModel b) =>
              b.rating.compareTo(a.rating));
        case 'price_low':
          results.sort((VenueModel a, VenueModel b) =>
              a.priceFrom.compareTo(b.priceFrom));
        case 'price_high':
          results.sort((VenueModel a, VenueModel b) =>
              b.priceFrom.compareTo(a.priceFrom));
        case 'popular':
          results.sort((VenueModel a, VenueModel b) =>
              b.reviewCount.compareTo(a.reviewCount));
      }

      await _saveSearch(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
          _hasSearched = true;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Search header ────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              topPadding + 12,
              AppSpacing.screenPadding,
              12,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                AnimatedPressScale(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.arrow_back,
                        color: AppColors.textPrimary, size: 22),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius:
                      BorderRadius.circular(AppSpacing.inputRadius),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: AppColors.textTertiary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            onChanged: _onSearchChanged,
                            onSubmitted: (q) {
                              if (q.trim().isNotEmpty) {
                                _performSearch(q.trim());
                              }
                            },
                            style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Search venues, experiences...',
                              hintStyle: AppTypography.bodyMedium
                                  .copyWith(
                                  color: AppColors.textTertiary),
                              border: InputBorder.none,
                              contentPadding:
                              const EdgeInsets.symmetric(
                                  vertical: 14),
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          AnimatedPressScale(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _results = [];
                                _hasSearched = false;
                              });
                            },
                            child: const Icon(Icons.close,
                                color: AppColors.textTertiary,
                                size: 18),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedPressScale(
                  onTap: () => _showFilterSheet(context),
                  child: SurfaceContainer(
                    borderRadius: AppSpacing.inputRadius,
                    padding: const EdgeInsets.all(11),
                    child: const Icon(Icons.tune,
                        color: AppColors.textSecondary, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // ── Active filters ───────────────────
          if (_minRating > 0 ||
              _selectedCategory != null ||
              _minPrice > 0 ||
              _maxPrice < 500)
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 10, AppSpacing.screenPadding, 10,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    if (_selectedCategory != null)
                      _FilterChip(
                        label: _selectedCategory!,
                        onRemove: () => setState(
                                () => _selectedCategory = null),
                      ),
                    if (_minRating > 0)
                      _FilterChip(
                        label: '${_minRating.toStringAsFixed(1)}+ ★',
                        onRemove: () =>
                            setState(() => _minRating = 0),
                      ),
                    if (_minPrice > 0 || _maxPrice < 500)
                      _FilterChip(
                        label:
                        '\$${_minPrice.toInt()}–\$${_maxPrice.toInt()}',
                        onRemove: () => setState(() {
                          _minPrice = 0;
                          _maxPrice = 500;
                        }),
                      ),
                  ],
                ),
              ),
            ),

          // ── Content ──────────────────────────
          Expanded(
            child: _isSearching
                ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            )
                : _hasSearched
                ? _results.isEmpty
                ? _buildEmptyResults()
                : _buildResults()
                : _buildRecentSearches(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Row(
              children: [
                Text('Recent', style: AppTypography.headlineMedium),
                const Spacer(),
                AnimatedPressScale(
                  onTap: _clearRecentSearches,
                  child: Text(
                    'Clear all',
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(_recentSearches.length, (i) {
              return AnimatedPressScale(
                onTap: () {
                  _searchController.text = _recentSearches[i];
                  _performSearch(_recentSearches[i]);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.history,
                            color: AppColors.textTertiary, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(_recentSearches[i],
                              style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textPrimary)),
                        ),
                        const Icon(Icons.north_west,
                            color: AppColors.textTertiary, size: 14),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ] else ...[
            const SizedBox(height: 80),
            Center(
              child: Column(
                children: [
                  Icon(Icons.search,
                      color: AppColors.textMuted, size: 48),
                  const SizedBox(height: 16),
                  Text('Search for venues',
                      style: AppTypography.headlineMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Find restaurants, nightlife, spas, and more',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
          ],

          // Popular categories
          const SizedBox(height: 36),
          Text('POPULAR CATEGORIES', style: AppTypography.overline),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Rooftop Bars',
              'Fine Dining',
              'Spa & Wellness',
              'Live Music',
              'Private Events',
              'Date Night',
            ].map((label) {
              return AnimatedPressScale(
                onTap: () {
                  _searchController.text = label;
                  _performSearch(label);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.border, width: 0.5),
                  ),
                  child: Text(
                    label,
                    style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textPrimary),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 0,
          ),
          child: Row(
            children: [
              Text(
                '${_results.length} result${_results.length != 1 ? 's' : ''}',
                style: AppTypography.labelMedium,
              ),
              const Spacer(),
              AnimatedPressScale(
                onTap: () => _showSortSheet(context),
                child: Row(
                  children: [
                    Text(
                      'Sort: ${_sortLabel}',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.accent),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.unfold_more,
                        color: AppColors.accent, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            physics: const BouncingScrollPhysics(),
            itemCount: _results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final venue = _results[index];
              final img = venue.imageUrl.isNotEmpty
                  ? venue.imageUrl
                  : _searchFallbackImages[
              index % _searchFallbackImages.length];
              return _SearchResultCard(
                venue: venue,
                imageUrl: img,
                onTap: () => context.push('/venue/${venue.id}'),
              );
            },
          ),
        ),
      ],
    );
  }

  String get _sortLabel {
    switch (_sortBy) {
      case 'rating': return 'Rating';
      case 'price_low': return 'Price ↑';
      case 'price_high': return 'Price ↓';
      case 'popular': return 'Popular';
      default: return 'Rating';
    }
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.search_off,
                  color: AppColors.textTertiary, size: 28),
            ),
            const SizedBox(height: 20),
            Text('No results found',
                style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    final options = [
      ('rating', 'Highest Rated'),
      ('price_low', 'Price: Low to High'),
      ('price_high', 'Price: High to Low'),
      ('popular', 'Most Popular'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          24,
          AppSpacing.screenPadding,
          MediaQuery.of(ctx).padding.bottom + 24,
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
            Text('Sort By', style: AppTypography.headlineLarge),
            const SizedBox(height: 16),
            ...options.map((o) {
              final isSelected = _sortBy == o.$1;
              return AnimatedPressScale(
                onTap: () {
                  setState(() => _sortBy = o.$1);
                  Navigator.pop(ctx);
                  if (_hasSearched) {
                    _performSearch(_searchController.text.trim());
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        o.$2,
                        style: AppTypography.titleMedium.copyWith(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(Icons.check,
                            color: AppColors.accent, size: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    double tempMinPrice = _minPrice;
    double tempMaxPrice = _maxPrice;
    double tempMinRating = _minRating;
    String? tempCategory = _selectedCategory;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              24,
              AppSpacing.screenPadding,
              MediaQuery.of(ctx).padding.bottom + 24,
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
                Row(
                  children: [
                    Text('Filters',
                        style: AppTypography.headlineLarge),
                    const Spacer(),
                    AnimatedPressScale(
                      onTap: () {
                        setSheetState(() {
                          tempMinPrice = 0;
                          tempMaxPrice = 500;
                          tempMinRating = 0;
                          tempCategory = null;
                        });
                      },
                      child: Text(
                        'Reset',
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Price range
                Text('PRICE RANGE',
                    style: AppTypography.overline),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '\$${tempMinPrice.toInt()}',
                      style: AppTypography.labelLarge,
                    ),
                    const Spacer(),
                    Text(
                      '\$${tempMaxPrice.toInt()}',
                      style: AppTypography.labelLarge,
                    ),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(tempMinPrice, tempMaxPrice),
                  min: 0,
                  max: 500,
                  divisions: 50,
                  activeColor: AppColors.accent,
                  inactiveColor: AppColors.border,
                  onChanged: (v) {
                    setSheetState(() {
                      tempMinPrice = v.start;
                      tempMaxPrice = v.end;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Rating
                Text('MINIMUM RATING',
                    style: AppTypography.overline),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (final r in [0.0, 3.0, 3.5, 4.0, 4.5]) ...[
                      Expanded(
                        child: AnimatedPressScale(
                          onTap: () =>
                              setSheetState(() => tempMinRating = r),
                          child: AnimatedContainer(
                            duration:
                            const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            decoration: BoxDecoration(
                              color: tempMinRating == r
                                  ? AppColors.accent
                                  .withValues(alpha: 0.15)
                                  : AppColors.surfaceElevated,
                              borderRadius:
                              BorderRadius.circular(10),
                              border: Border.all(
                                color: tempMinRating == r
                                    ? AppColors.accent
                                    .withValues(alpha: 0.3)
                                    : AppColors.border,
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                r == 0 ? 'Any' : '${r.toStringAsFixed(1)}+',
                                style:
                                AppTypography.labelMedium.copyWith(
                                  color: tempMinRating == r
                                      ? AppColors.accent
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (r != 4.5) const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // Category
                Text('CATEGORY', style: AppTypography.overline),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'nightclub',
                    'restaurant',
                    'spa',
                    'event',
                    'hotel'
                  ].map((cat) {
                    final labels = {
                      'nightclub': 'Nightlife',
                      'restaurant': 'Dining',
                      'spa': 'Wellness',
                      'event': 'Events',
                      'hotel': 'Stays',
                    };
                    final isSelected = tempCategory == cat;
                    return AnimatedPressScale(
                      onTap: () {
                        setSheetState(() {
                          tempCategory =
                          isSelected ? null : cat;
                        });
                      },
                      child: AnimatedContainer(
                        duration:
                        const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              .withValues(alpha: 0.15)
                              : AppColors.surfaceElevated,
                          borderRadius:
                          BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                .withValues(alpha: 0.3)
                                : AppColors.border,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          labels[cat] ?? cat,
                          style:
                          AppTypography.labelMedium.copyWith(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Apply button
                AnimatedPressScale(
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _minPrice = tempMinPrice;
                      _maxPrice = tempMaxPrice;
                      _minRating = tempMinRating;
                      _selectedCategory = tempCategory;
                    });
                    if (_searchController.text.trim().isNotEmpty) {
                      _performSearch(
                          _searchController.text.trim());
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.buttonPrimary,
                      borderRadius: BorderRadius.circular(
                          AppSpacing.buttonRadius),
                    ),
                    child: Center(
                      child: Text(
                        'Apply Filters',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.buttonPrimaryText,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Search Result Card
// ─────────────────────────────────────────────────

class _SearchResultCard extends StatelessWidget {
  final VenueModel venue;
  final String imageUrl;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.venue,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPressScale(
      onTap: onTap,
      child: SurfaceContainer(
        borderRadius: AppSpacing.cardRadius,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16)),
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.surfaceElevated,
                    child: const Icon(Icons.image,
                        color: AppColors.textMuted, size: 24),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name,
                      style: AppTypography.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: AppColors.accent, size: 13),
                        const SizedBox(width: 3),
                        Text(
                          '${venue.rating}',
                          style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textPrimary),
                        ),
                        Text(
                          ' (${venue.reviewCount})',
                          style: AppTypography.caption
                              .copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: AppColors.textTertiary, size: 13),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            venue.location,
                            style: AppTypography.caption
                                .copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'From \$${venue.priceFrom.toInt()}',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.accent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (venue.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: venue.tags.take(3).map((t) {
                          return Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius:
                              BorderRadius.circular(6),
                            ),
                            child: Text(
                              t,
                              style: AppTypography.overline
                                  .copyWith(
                                  fontSize: 8,
                                  color:
                                  AppColors.textSecondary),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.accent, fontSize: 11),
          ),
          const SizedBox(width: 6),
          AnimatedPressScale(
            onTap: onRemove,
            child: Icon(Icons.close,
                color: AppColors.accent, size: 14),
          ),
        ],
      ),
    );
  }
}