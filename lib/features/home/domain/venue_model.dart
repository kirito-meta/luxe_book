class VenueModel {
  final String id;
  final String name;
  final String tagline;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final double priceFrom;
  final String location;
  final bool isLive;
  final int liveCount;
  final List<String> tags;

  const VenueModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.priceFrom,
    required this.location,
    this.isLive = false,
    this.liveCount = 0,
    this.tags = const [],
  });

  factory VenueModel.fromMap(Map<String, dynamic> map) {
    final categoryData = map['categories'];
    String categorySlug;
    if (categoryData is Map<String, dynamic>) {
      categorySlug = categoryData['slug'] as String? ?? '';
    } else {
      categorySlug = map['category_id'] as String? ?? '';
    }

    List<String> parsedTags;
    final rawTags = map['tags'];
    if (rawTags is List) {
      parsedTags = rawTags.cast<String>();
    } else {
      parsedTags = [];
    }

    return VenueModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      tagline: map['tagline'] as String? ?? '',
      imageUrl: map['cover_image_url'] as String? ?? '',
      category: categorySlug,
      rating: (map['avg_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['review_count'] as num?)?.toInt() ?? 0,
      priceFrom: (map['price_from'] as num?)?.toDouble() ?? 0.0,
      location: map['city'] as String? ?? '',
      isLive: map['is_live'] as bool? ?? false,
      liveCount: (map['live_count'] as num?)?.toInt() ?? 0,
      tags: parsedTags,
    );
  }
}