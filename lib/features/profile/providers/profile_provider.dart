import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase_service.dart';
import '../../../services/supabase_provider.dart';

class ProfileState {
  final Map<String, dynamic>? data;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? saveSuccess;

  const ProfileState({
    this.data,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.saveSuccess,
  });

  ProfileState copyWith({
    Map<String, dynamic>? data,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? saveSuccess,
  }) {
    return ProfileState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      saveSuccess: saveSuccess,
    );
  }

  String get displayName => data?['display_name'] as String? ?? '';
  String get username => data?['username'] as String? ?? '';
  String get email => Supabase.instance.client.auth.currentUser?.email ?? '';
  String get phone => data?['phone'] as String? ?? '';
  String get avatarUrl => data?['avatar_url'] as String? ?? '';
  String get bio => data?['bio'] as String? ?? '';
  String get loyaltyTier => data?['loyalty_tier'] as String? ?? 'bronze';
  int get loyaltyPoints => (data?['loyalty_points'] as num?)?.toInt() ?? 0;
  int get totalBookings => (data?['total_bookings'] as num?)?.toInt() ?? 0;
  double get totalSpent => (data?['total_spent'] as num?)?.toDouble() ?? 0;
  bool get notificationsEnabled => data?['notifications_enabled'] as bool? ?? true;
  bool get locationEnabled => data?['location_enabled'] as bool? ?? true;
  String get preferredCurrency => data?['preferred_currency'] as String? ?? 'USD';
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final SupabaseService _service;

  ProfileNotifier(this._service) : super(const ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getProfile();
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    state = state.copyWith(isSaving: true, error: null, saveSuccess: null);
    try {
      final success = await _service.updateProfile(updates);
      if (success) {
        final merged = Map<String, dynamic>.from(state.data ?? {})..addAll(updates);
        state = state.copyWith(
          data: merged,
          isSaving: false,
          saveSuccess: 'Profile updated',
        );
        return true;
      } else {
        state = state.copyWith(isSaving: false, error: 'Failed to save');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<String?> uploadAvatar(Uint8List bytes, String fileName) async {
    try {
      final userId = _service.currentUserId;
      if (userId == null) return null;

      final path = 'avatars/$userId/$fileName';
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));

      final publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(path);

      await updateProfile({'avatar_url': publicUrl});
      return publicUrl;
    } catch (e) {
      state = state.copyWith(error: 'Upload failed: $e');
      return null;
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    await updateProfile({'notifications_enabled': enabled});
  }

  Future<void> toggleLocation(bool enabled) async {
    await updateProfile({'location_enabled': enabled});
  }

  void clearMessages() {
    state = state.copyWith(error: null, saveSuccess: null);
  }
}

final profileProvider =
StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return ProfileNotifier(service);
});