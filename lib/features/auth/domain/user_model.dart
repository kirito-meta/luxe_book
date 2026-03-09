class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final String? phone;
  final DateTime? dateOfBirth;
  final String loyaltyTier;
  final int loyaltyPoints;
  final double totalSpent;
  final int totalBookings;
  final List<String> preferredCategories;
  final String? locationCity;
  final String? referralCode;
  final bool isVenueOwner;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.username,
    this.avatarUrl,
    this.bio,
    this.phone,
    this.dateOfBirth,
    this.loyaltyTier = 'bronze',
    this.loyaltyPoints = 0,
    this.totalSpent = 0,
    this.totalBookings = 0,
    this.preferredCategories = const [],
    this.locationCity,
    this.referralCode,
    this.isVenueOwner = false,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      loyaltyTier: json['loyalty_tier'] as String? ?? 'bronze',
      loyaltyPoints: json['loyalty_points'] as int? ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0,
      totalBookings: json['total_bookings'] as int? ?? 0,
      preferredCategories: (json['preferred_categories'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
      locationCity: json['location_city'] as String?,
      referralCode: json['referral_code'] as String?,
      isVenueOwner: json['is_venue_owner'] as bool? ?? false,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'display_name': displayName,
        'username': username,
        'avatar_url': avatarUrl,
        'bio': bio,
        'phone': phone,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'preferred_categories': preferredCategories,
        'location_city': locationCity,
      };

  UserModel copyWith({
    String? displayName,
    String? username,
    String? avatarUrl,
    String? bio,
    String? phone,
    DateTime? dateOfBirth,
    String? loyaltyTier,
    int? loyaltyPoints,
    String? locationCity,
    List<String>? preferredCategories,
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      loyaltyTier: loyaltyTier ?? this.loyaltyTier,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      totalSpent: totalSpent,
      totalBookings: totalBookings,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      locationCity: locationCity ?? this.locationCity,
      referralCode: referralCode,
      isVenueOwner: isVenueOwner,
      createdAt: createdAt,
    );
  }

  String get tierEmoji => switch (loyaltyTier) {
        'silver' => '🥈',
        'gold' => '🥇',
        'platinum' => '💎',
        'obsidian' => '🖤',
        _ => '🥉',
      };

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }
}