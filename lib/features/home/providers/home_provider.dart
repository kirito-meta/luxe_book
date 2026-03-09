import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/supabase_service.dart';
import '../../../services/supabase_provider.dart';
import '../../home/domain/venue_model.dart';

class HomeState {
  final List<VenueModel> featured;
  final List<VenueModel> trending;
  final List<VenueModel> live;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.featured = const [],
    this.trending = const [],
    this.live = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<VenueModel>? featured,
    List<VenueModel>? trending,
    List<VenueModel>? live,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      featured: featured ?? this.featured,
      trending: trending ?? this.trending,
      live: live ?? this.live,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final SupabaseService _service;

  HomeNotifier(this._service) : super(const HomeState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await Future.wait([
        _service.getFeaturedVenues(limit: 5),
        _service.getTrendingVenues(limit: 10),
        _service.getLiveVenues(),
      ]);

      state = state.copyWith(
        featured: results[0].map((m) => VenueModel.fromMap(m)).toList(),
        trending: results[1].map((m) => VenueModel.fromMap(m)).toList(),
        live: results[2].map((m) => VenueModel.fromMap(m)).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final homeProvider =
StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return HomeNotifier(service);
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'all');