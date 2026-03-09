class BookingModel {
  final String id;
  final String bookingNumber;
  final String venueId;
  final String venueName;
  final String venueImageUrl;
  final String venueCity;
  final String serviceName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int guestCount;
  final double totalAmount;
  final String currency;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final int loyaltyPointsEarned;
  final String? specialRequests;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.bookingNumber,
    required this.venueId,
    required this.venueName,
    required this.venueImageUrl,
    required this.venueCity,
    required this.serviceName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.guestCount,
    required this.totalAmount,
    this.currency = 'USD',
    required this.status,
    required this.paymentStatus,
    this.loyaltyPointsEarned = 0,
    this.specialRequests,
    required this.createdAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    final venue = map['venues'] as Map<String, dynamic>? ?? {};
    return BookingModel(
      id: map['id'] as String,
      bookingNumber: map['booking_number'] as String? ?? '',
      venueId: map['venue_id'] as String,
      venueName: venue['name'] as String? ?? 'Unknown Venue',
      venueImageUrl: venue['cover_image_url'] as String? ?? '',
      venueCity: venue['city'] as String? ?? '',
      serviceName: map['service_name'] as String? ?? 'General',
      date: DateTime.parse(map['date'] as String),
      startTime: map['start_time'] as String? ?? '',
      endTime: map['end_time'] as String? ?? '',
      guestCount: (map['guest_count'] as num?)?.toInt() ?? 1,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0,
      currency: map['currency'] as String? ?? 'USD',
      status: BookingStatus.fromString(map['status'] as String? ?? 'pending'),
      paymentStatus: PaymentStatus.fromString(map['payment_status'] as String? ?? 'unpaid'),
      loyaltyPointsEarned: (map['loyalty_points_earned'] as num?)?.toInt() ?? 0,
      specialRequests: map['special_requests'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  bool get isUpcoming =>
      date.isAfter(DateTime.now().subtract(const Duration(hours: 2))) &&
          status != BookingStatus.cancelled &&
          status != BookingStatus.completed;

  bool get isPast =>
      date.isBefore(DateTime.now()) ||
          status == BookingStatus.completed ||
          status == BookingStatus.cancelled;

  bool get canCancel =>
      status == BookingStatus.confirmed &&
          date.difference(DateTime.now()).inHours > 24;

  bool get canReview =>
      status == BookingStatus.completed;
}

enum BookingStatus {
  pending,
  confirmed,
  checkedIn,
  completed,
  cancelled,
  noShow,
  refunded;

  static BookingStatus fromString(String s) {
    switch (s) {
      case 'pending': return BookingStatus.pending;
      case 'confirmed': return BookingStatus.confirmed;
      case 'checked_in': return BookingStatus.checkedIn;
      case 'completed': return BookingStatus.completed;
      case 'cancelled': return BookingStatus.cancelled;
      case 'no_show': return BookingStatus.noShow;
      case 'refunded': return BookingStatus.refunded;
      default: return BookingStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case BookingStatus.pending: return 'Pending';
      case BookingStatus.confirmed: return 'Confirmed';
      case BookingStatus.checkedIn: return 'Checked In';
      case BookingStatus.completed: return 'Completed';
      case BookingStatus.cancelled: return 'Cancelled';
      case BookingStatus.noShow: return 'No Show';
      case BookingStatus.refunded: return 'Refunded';
    }
  }
}

enum PaymentStatus {
  unpaid,
  authorized,
  paid,
  partiallyRefunded,
  refunded,
  failed;

  static PaymentStatus fromString(String s) {
    switch (s) {
      case 'unpaid': return PaymentStatus.unpaid;
      case 'authorized': return PaymentStatus.authorized;
      case 'paid': return PaymentStatus.paid;
      case 'partially_refunded': return PaymentStatus.partiallyRefunded;
      case 'refunded': return PaymentStatus.refunded;
      case 'failed': return PaymentStatus.failed;
      default: return PaymentStatus.unpaid;
    }
  }
}