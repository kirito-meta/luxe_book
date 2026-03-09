class PromotionModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String badgeText;
  final double discountPercent;

  const PromotionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.badgeText,
    required this.discountPercent,
  });
}