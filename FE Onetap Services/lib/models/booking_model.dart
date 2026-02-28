enum BookingStatus { pending, accepted, rejected, completed, cancelled }

class Booking {
  final String id;
  final String customerId;
  final String providerId;
  final String serviceId;
  final String customerName;
  final String providerName;
  final String serviceName;
  final DateTime dateTime;
  final BookingStatus status;
  final double price;
  final String address;
  final String? specialInstructions;
  final int? feedbackRating;
  final String? feedbackComment;
  final DateTime? feedbackSubmittedAt;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.customerId,
    required this.providerId,
    required this.serviceId,
    required this.customerName,
    required this.providerName,
    required this.serviceName,
    required this.dateTime,
    required this.status,
    required this.price,
    required this.address,
    this.specialInstructions,
    this.feedbackRating,
    this.feedbackComment,
    this.feedbackSubmittedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isPending => status == BookingStatus.pending;
  bool get isAccepted => status == BookingStatus.accepted;
  bool get isCompleted => status == BookingStatus.completed;
  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isRejected => status == BookingStatus.rejected;
  bool get hasFeedback => feedbackRating != null;
  bool get canBeCancelled =>
      status == BookingStatus.pending || status == BookingStatus.accepted;

  Map<String, dynamic> toMap() => {
    'providerId': providerId,
    'serviceId': serviceId,
    'dateTime': dateTime.toIso8601String(),
    'price': price,
    'address': address,
    'specialInstructions': specialInstructions,
  };

  Map<String, dynamic> toJson() => toMap();

  factory Booking.fromMap(Map<String, dynamic> map) {
    final customerData = _toMap(map['customerId']);
    final providerData = _toMap(map['providerId']);
    final serviceData = _toMap(map['serviceId']);

    final id = _extractId(map['id'] ?? map['_id']) ?? '';
    final customerId =
        _extractId(map['customer_id'] ?? map['customerId']) ?? '';
    final providerId =
        _extractId(map['provider_id'] ?? map['providerId']) ?? '';
    final serviceId = _extractId(map['service_id'] ?? map['serviceId']) ?? '';
    final feedbackMap = _toMap(map['feedback']);

    return Booking(
      id: id,
      customerId: customerId,
      providerId: providerId,
      serviceId: serviceId,
      customerName: _asString(
        map['customer_name'] ?? map['customerName'] ?? customerData?['name'],
      ),
      providerName: _asString(
        map['provider_name'] ??
            map['providerName'] ??
            providerData?['companyName'],
      ),
      serviceName: _asString(
        map['service_name'] ?? map['serviceName'] ?? serviceData?['name'],
      ),
      dateTime: _toDateTime(map['date_time'] ?? map['dateTime']),
      status: _toStatus(map['status']),
      price: _toDouble(map['price']),
      address: _asString(map['address']),
      specialInstructions: _nullableString(
        map['special_instructions'] ?? map['specialInstructions'],
      ),
      feedbackRating: _toNullableInt(
        map['feedback_rating'] ?? feedbackMap?['rating'],
      ),
      feedbackComment: _nullableString(
        map['feedback_comment'] ?? feedbackMap?['comment'],
      ),
      feedbackSubmittedAt: _toNullableDateTime(
        map['feedback_submitted_at'] ?? feedbackMap?['submittedAt'],
      ),
      createdAt: _toDateTime(map['created_at'] ?? map['createdAt']),
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json) => Booking.fromMap(json);

  static String? _extractId(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      final nested = value['id'] ?? value['_id'];
      return nested?.toString();
    }
    return value.toString();
  }

  static Map<String, dynamic>? _toMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString();
    return text.isEmpty ? fallback : text;
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  static BookingStatus _toStatus(dynamic value) {
    final raw = (value ?? 'pending').toString();
    return BookingStatus.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => BookingStatus.pending,
    );
  }

  static double _toDouble(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String && value.isNotEmpty) return int.tryParse(value);
    return null;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Booking copyWith({
    String? id,
    String? customerId,
    String? providerId,
    String? serviceId,
    String? customerName,
    String? providerName,
    String? serviceName,
    DateTime? dateTime,
    BookingStatus? status,
    double? price,
    String? address,
    String? specialInstructions,
    int? feedbackRating,
    String? feedbackComment,
    DateTime? feedbackSubmittedAt,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      customerName: customerName ?? this.customerName,
      providerName: providerName ?? this.providerName,
      serviceName: serviceName ?? this.serviceName,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      price: price ?? this.price,
      address: address ?? this.address,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      feedbackRating: feedbackRating ?? this.feedbackRating,
      feedbackComment: feedbackComment ?? this.feedbackComment,
      feedbackSubmittedAt: feedbackSubmittedAt ?? this.feedbackSubmittedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
