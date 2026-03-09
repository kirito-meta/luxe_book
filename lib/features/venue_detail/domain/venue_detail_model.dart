class VenueDetailModel {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final String coverImageUrl;
  final List<String> galleryUrls;
  final String category;
  final double rating;
  final int reviewCount;
  final double priceFrom;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final int priceTier;
  final int maxCapacity;
  final bool isLive;
  final int liveCount;
  final bool isVerified;
  final bool isFeatured;
  final List<String> tags;
  final List<String> amenities;
  final Map<String, String> openingHours;
  final String? phone;
  final String? email;
  final String? website;
  final List<VenueServiceModel> services;
  final List<VenueReviewModel> reviews;

  const VenueDetailModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.coverImageUrl,
    required this.galleryUrls,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.priceFrom,
    required this.address,
    required this.city,
    this.latitude = 0,
    this.longitude = 0,
    this.priceTier = 2,
    this.maxCapacity = 100,
    this.isLive = false,
    this.liveCount = 0,
    this.isVerified = false,
    this.isFeatured = false,
    this.tags = const [],
    this.amenities = const [],
    this.openingHours = const {},
    this.phone,
    this.email,
    this.website,
    this.services = const [],
    this.reviews = const [],
  });
}

class VenueServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final int maxGuests;
  final String category;
  final String? imageUrl;

  const VenueServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    this.maxGuests = 1,
    this.category = 'general',
    this.imageUrl,
  });
}

class VenueReviewModel {
  final String id;
  final String userName;
  final String? avatarUrl;
  final int rating;
  final String? title;
  final String? body;
  final int ambianceRating;
  final int serviceRating;
  final int valueRating;
  final int helpfulCount;
  final String? ownerReply;
  final DateTime createdAt;

  const VenueReviewModel({
    required this.id,
    required this.userName,
    this.avatarUrl,
    required this.rating,
    this.title,
    this.body,
    this.ambianceRating = 0,
    this.serviceRating = 0,
    this.valueRating = 0,
    this.helpfulCount = 0,
    this.ownerReply,
    required this.createdAt,
  });
}

class AvailabilitySlot {
  final String id;
  final String startTime;
  final String endTime;
  final int totalCapacity;
  final int bookedCount;
  final double? priceOverride;

  const AvailabilitySlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.totalCapacity,
    required this.bookedCount,
    this.priceOverride,
  });

  bool get isAvailable => bookedCount < totalCapacity;
  double get fillPercent => totalCapacity > 0 ? bookedCount / totalCapacity : 1.0;
  int get spotsLeft => totalCapacity - bookedCount;
}