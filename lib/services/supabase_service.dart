import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient _client;

  SupabaseService._() {
    _client = Supabase.instance.client;
  }

  factory SupabaseService() {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseClient get client => _client;
  String? get currentUserId => _client.auth.currentUser?.id;

  // ==========================================
  // CATEGORIES
  // ==========================================

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // ==========================================
  // VENUES
  // ==========================================

  Future<List<Map<String, dynamic>>> getVenues({
    String? categoryId,
    String? city,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _client
        .from('venues')
        .select('*, categories(name, slug, color_hex)')
        .eq('status', 'active');

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    if (city != null) {
      query = query.eq('city', city);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('name', '%$searchQuery%');
    }

    final response = await query
        .order('review_count', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getVenueById(String venueId) async {
    final response = await _client
        .from('venues')
        .select('*, categories(name, slug, color_hex)')
        .eq('id', venueId)
        .maybeSingle();
    return response;
  }

  Future<List<Map<String, dynamic>>> getFeaturedVenues({int limit = 5}) async {
    final response = await _client
        .from('venues')
        .select('*, categories(name, slug, color_hex)')
        .eq('status', 'active')
        .eq('is_featured', true)
        .order('avg_rating', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getTrendingVenues({int limit = 10}) async {
    final response = await _client
        .from('venues')
        .select('*, categories(name, slug, color_hex)')
        .eq('status', 'active')
        .order('total_bookings', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getLiveVenues() async {
    final response = await _client
        .from('venues')
        .select('*, categories(name, slug, color_hex)')
        .eq('status', 'active')
        .eq('is_live', true)
        .order('live_count', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getNearbyVenues({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
    int limit = 20,
  }) async {
    // Uses a Supabase RPC function for geo queries
    // You must create this function in your Supabase SQL editor (provided below)
    final response = await _client.rpc('get_nearby_venues', params: {
      'user_lat': latitude,
      'user_lng': longitude,
      'radius_km': radiusKm,
      'result_limit': limit,
    });
    return List<Map<String, dynamic>>.from(response);
  }

  // ==========================================
  // VENUE SERVICES
  // ==========================================

  Future<List<Map<String, dynamic>>> getVenueServices(String venueId) async {
    final response = await _client
        .from('venue_services')
        .select()
        .eq('venue_id', venueId)
        .eq('is_active', true)
        .order('sort_order', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // ==========================================
  // AVAILABILITY
  // ==========================================

  Future<List<Map<String, dynamic>>> getAvailability({
    required String venueId,
    required DateTime date,
    String? serviceId,
  }) async {
    var query = _client
        .from('availability_slots')
        .select()
        .eq('venue_id', venueId)
        .eq('date', _formatDate(date))
        .eq('is_blocked', false);

    if (serviceId != null) {
      query = query.eq('service_id', serviceId);
    }

    final response = await query.order('start_time', ascending: true);

    // Filter to only slots where booked_count < total_capacity
    // Done client-side because Supabase PostgREST doesn't support
    // column-to-column comparison in filters directly
    final available = response.where((slot) {
      final booked = (slot['booked_count'] as num?)?.toInt() ?? 0;
      final total = (slot['total_capacity'] as num?)?.toInt() ?? 1;
      return booked < total;
    }).toList();

    return List<Map<String, dynamic>>.from(available);
  }

  Future<bool> incrementSlotBookedCount(String slotId) async {
    try {
      await _client.rpc('increment_slot_booked_count', params: {
        'slot_id': slotId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // BOOKINGS
  // ==========================================

  Future<Map<String, dynamic>?> createBooking({
    required String venueId,
    required String slotId,
    String? serviceId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required int guestCount,
    required double subtotal,
    required double taxAmount,
    required double totalAmount,
    String? specialRequests,
    String? promoCodeId,
  }) async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final response = await _client.from('bookings').insert({
        'user_id': userId,
        'venue_id': venueId,
        'slot_id': slotId,
        if (serviceId != null) 'service_id': serviceId,
        'date': _formatDate(date),
        'start_time': startTime,
        'end_time': endTime,
        'guest_count': guestCount,
        'subtotal': subtotal,
        'tax_amount': taxAmount,
        'total_amount': totalAmount,
        'discount_amount': 0,
        'status': 'confirmed',
        'payment_status': 'unpaid',
        if (specialRequests != null && specialRequests.isNotEmpty)
          'special_requests': specialRequests,
        if (promoCodeId != null) 'promo_code_id': promoCodeId,
      }).select().single();

      // Increment the slot's booked count
      await incrementSlotBookedCount(slotId);

      // Increment venue total_bookings
      await _client.rpc('increment_venue_bookings', params: {
        'target_venue_id': venueId,
      });

      // Award loyalty points
      final pointsEarned = (totalAmount * 0.1).round();
      await _client.rpc('award_loyalty_points', params: {
        'target_user_id': userId,
        'points': pointsEarned,
        'spent_amount': totalAmount,
      });

      // Update the booking with earned points
      await _client.from('bookings').update({
        'loyalty_points_earned': pointsEarned,
      }).eq('id', response['id']);

      // Create a notification
      await createNotification(
        userId: userId,
        type: 'booking_confirmed',
        title: 'Booking Confirmed!',
        body: 'Your reservation has been confirmed. Booking #${response['booking_number']}',
        data: {'booking_id': response['id'], 'venue_id': venueId},
      );

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserBookings({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final userId = currentUserId;
    if (userId == null) return [];

    var query = _client
        .from('bookings')
        .select('*, venues(name, cover_image_url, city, category_id)')
        .eq('user_id', userId);

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getBookingById(String bookingId) async {
    final response = await _client
        .from('bookings')
        .select('*, venues(name, cover_image_url, city, address_line1, phone)')
        .eq('id', bookingId)
        .maybeSingle();
    return response;
  }

  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      await _client.from('bookings').update({
        'status': 'cancelled',
        'cancelled_at': DateTime.now().toIso8601String(),
        if (reason != null) 'cancellation_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId).eq('user_id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateBookingPayment({
    required String bookingId,
    required String paymentIntentId,
    required String paymentStatus,
  }) async {
    try {
      await _client.from('bookings').update({
        'payment_intent_id': paymentIntentId,
        'payment_status': paymentStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // REVIEWS
  // ==========================================

  Future<List<Map<String, dynamic>>> getVenueReviews({
    required String venueId,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client
        .from('reviews')
        .select('*, profiles(display_name, avatar_url)')
        .eq('venue_id', venueId)
        .eq('status', 'published')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> createReview({
    required String bookingId,
    required String venueId,
    required int rating,
    String? title,
    String? body,
    int? ambianceRating,
    int? serviceRating,
    int? valueRating,
    List<String>? imageUrls,
  }) async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final response = await _client.from('reviews').insert({
        'booking_id': bookingId,
        'user_id': userId,
        'venue_id': venueId,
        'rating': rating,
        if (title != null) 'title': title,
        if (body != null) 'body': body,
        if (ambianceRating != null) 'ambiance_rating': ambianceRating,
        if (serviceRating != null) 'service_rating': serviceRating,
        if (valueRating != null) 'value_rating': valueRating,
        if (imageUrls != null) 'image_urls': imageUrls,
      }).select().single();

      // Award review bonus points
      await _client.rpc('award_loyalty_points', params: {
        'target_user_id': userId,
        'points': 50,
        'spent_amount': 0,
      });

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<bool> markReviewHelpful(String reviewId) async {
    try {
      await _client.rpc('increment_review_helpful', params: {
        'target_review_id': reviewId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // FAVORITES
  // ==========================================

  Future<List<String>> getFavoriteVenueIds() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final response = await _client
        .from('favorites')
        .select('venue_id')
        .eq('user_id', userId);

    return response.map<String>((f) => f['venue_id'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getFavoriteVenues() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final response = await _client
        .from('favorites')
        .select('venue_id, created_at, venues(id, name, tagline, cover_image_url, avg_rating, review_count, price_from, city, tags)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<bool> toggleFavorite(String venueId) async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      final existing = await _client
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('venue_id', venueId)
          .maybeSingle();

      if (existing != null) {
        await _client.from('favorites').delete().eq('id', existing['id']);
        return false; // Unfavorited
      } else {
        await _client.from('favorites').insert({
          'user_id': userId,
          'venue_id': venueId,
        });
        return true; // Favorited
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> isFavorited(String venueId) async {
    final userId = currentUserId;
    if (userId == null) return false;

    final existing = await _client
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('venue_id', venueId)
        .maybeSingle();

    return existing != null;
  }

  // ==========================================
  // PROFILES
  // ==========================================

  Future<Map<String, dynamic>?> getProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;

    return await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      await _client.from('profiles').update(updates).eq('id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getProfileById(String userId) async {
    return await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  // ==========================================
  // PROMOTIONS & PROMO CODES
  // ==========================================

  Future<List<Map<String, dynamic>>> getActivePromotions({
    String? venueId,
    String? targetTier,
  }) async {
    var query = _client
        .from('promotions')
        .select('*, venues(name, cover_image_url)')
        .eq('is_active', true)
        .gte('valid_until', DateTime.now().toIso8601String());

    if (venueId != null) {
      query = query.eq('venue_id', venueId);
    }

    final response = await query.order('discount_value', ascending: false);

    // Filter by tier client-side if needed
    if (targetTier != null) {
      return List<Map<String, dynamic>>.from(
        response.where((p) => p['target_tier'] == null || p['target_tier'] == targetTier),
      );
    }

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> validatePromoCode(String code) async {
    final promo = await _client
        .from('promo_codes')
        .select('*, promotions(*)')
        .eq('code', code.toUpperCase())
        .eq('is_active', true)
        .maybeSingle();

    if (promo == null) return null;

    final usageLimit = promo['usage_limit'] as int?;
    final usageCount = (promo['usage_count'] as num?)?.toInt() ?? 0;

    if (usageLimit != null && usageCount >= usageLimit) {
      return null; // Code exhausted
    }

    final promotion = promo['promotions'] as Map<String, dynamic>?;
    if (promotion == null) return null;

    final validUntil = promotion['valid_until'] as String?;
    if (validUntil != null && DateTime.parse(validUntil).isBefore(DateTime.now())) {
      return null; // Expired
    }

    return promo;
  }

  Future<bool> redeemPromoCode(String codeId) async {
    try {
      await _client.rpc('redeem_promo_code', params: {
        'target_code_id': codeId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // NOTIFICATIONS
  // ==========================================

  Future<List<Map<String, dynamic>>> getNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    final userId = currentUserId;
    if (userId == null) return [];

    final response = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<int> getUnreadNotificationCount() async {
    final userId = currentUserId;
    if (userId == null) return 0;

    final response = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);

    return response.length;
  }

  Future<bool> markNotificationRead(String notificationId) async {
    try {
      await _client.from('notifications').update({
        'is_read': true,
      }).eq('id', notificationId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllNotificationsRead() async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      await _client.from('notifications').update({
        'is_read': true,
      }).eq('user_id', userId).eq('is_read', false);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createNotification({
    required String userId,
    required String type,
    required String title,
    String? body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'type': type,
        'title': title,
        if (body != null) 'body': body,
        if (data != null) 'data': data,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // SOCIAL: FOLLOWS
  // ==========================================

  Future<bool> followUser(String targetUserId) async {
    final userId = currentUserId;
    if (userId == null || userId == targetUserId) return false;

    try {
      await _client.from('follows').insert({
        'follower_id': userId,
        'following_id': targetUserId,
      });
      return true;
    } catch (e) {
      return false; // Already following or error
    }
  }

  Future<bool> unfollowUser(String targetUserId) async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      await _client
          .from('follows')
          .delete()
          .eq('follower_id', userId)
          .eq('following_id', targetUserId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isFollowing(String targetUserId) async {
    final userId = currentUserId;
    if (userId == null) return false;

    final result = await _client
        .from('follows')
        .select('id')
        .eq('follower_id', userId)
        .eq('following_id', targetUserId)
        .maybeSingle();

    return result != null;
  }

  Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    final response = await _client
        .from('follows')
        .select('follower_id, profiles!follows_follower_id_fkey(display_name, avatar_url, username)')
        .eq('following_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getFollowing(String userId) async {
    final response = await _client
        .from('follows')
        .select('following_id, profiles!follows_following_id_fkey(display_name, avatar_url, username)')
        .eq('follower_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  // ==========================================
  // PAYMENTS
  // ==========================================

  Future<Map<String, dynamic>?> createPaymentRecord({
    required String bookingId,
    required double amount,
    required String stripePaymentIntentId,
    String currency = 'USD',
    String status = 'pending',
  }) async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final response = await _client.from('payments').insert({
        'booking_id': bookingId,
        'user_id': userId,
        'stripe_payment_intent_id': stripePaymentIntentId,
        'amount': amount,
        'currency': currency,
        'status': status,
      }).select().single();
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updatePaymentStatus({
    required String paymentId,
    required String status,
    double? refundAmount,
  }) async {
    try {
      await _client.from('payments').update({
        'status': status,
        if (refundAmount != null) 'refund_amount': refundAmount,
      }).eq('id', paymentId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserPayments({int limit = 50}) async {
    final userId = currentUserId;
    if (userId == null) return [];

    final response = await _client
        .from('payments')
        .select('*, bookings(booking_number, venue_id, venues(name))')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  // ==========================================
  // REALTIME SUBSCRIPTIONS
  // ==========================================

  RealtimeChannel subscribeToVenueLiveStatus(
    String venueId,
    void Function(Map<String, dynamic> payload) onUpdate,
  ) {
    return _client
        .channel('venue_live_$venueId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'venues',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: venueId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();
  }

  RealtimeChannel subscribeToUserNotifications(
    String userId,
    void Function(Map<String, dynamic> payload) onInsert,
  ) {
    return _client
        .channel('user_notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) => onInsert(payload.newRecord),
        )
        .subscribe();
  }

  RealtimeChannel subscribeToBookingUpdates(
    String bookingId,
    void Function(Map<String, dynamic> payload) onUpdate,
  ) {
    return _client
        .channel('booking_$bookingId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: bookingId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();
  }

  void unsubscribe(RealtimeChannel channel) {
    _client.removeChannel(channel);
  }

  // ==========================================
  // HELPERS
  // ==========================================

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}