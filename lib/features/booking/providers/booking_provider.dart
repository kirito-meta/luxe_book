import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/supabase_service.dart';
import '../../../services/supabase_provider.dart';
import '../domain/booking_model.dart';

class BookingListState {
  final List<BookingModel> bookings;
  final bool isLoading;
  final String? error;

  const BookingListState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
  });

  List<BookingModel> get upcoming =>
      bookings.where((b) => b.isUpcoming).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  List<BookingModel> get past =>
      bookings.where((b) => b.isPast).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  BookingListState copyWith({
    List<BookingModel>? bookings,
    bool? isLoading,
    String? error,
  }) {
    return BookingListState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BookingListNotifier extends StateNotifier<BookingListState> {
  final SupabaseService _service;

  BookingListNotifier(this._service) : super(const BookingListState()) {
    loadBookings();
  }

  Future<void> loadBookings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getUserBookings();
      final bookings = data.map((m) => BookingModel.fromMap(m)).toList();
      state = state.copyWith(bookings: bookings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    final success = await _service.cancelBooking(bookingId, reason: reason);
    if (success) {
      await loadBookings();
    }
    return success;
  }
}

final bookingListProvider =
StateNotifierProvider<BookingListNotifier, BookingListState>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return BookingListNotifier(service);
});