class Provider {
  final String id;
  final String userId;
  final String companyName;
  final String description;
  final List<String> serviceIds;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final String? businessImage;
  final List<String> serviceAreas;
  final String businessHours;

  Provider({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.description,
    required this.serviceIds,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    this.businessImage,
    this.serviceAreas = const [],
    this.businessHours = '9 AM - 6 PM',
  });

  Map<String, dynamic> toJson() => toMap();
  factory Provider.fromJson(Map<String, dynamic> json) =>
      Provider.fromMap(json);

  Map<String, dynamic> toMap() => {
    'companyName': companyName,
    'description': description,
    'serviceIds': serviceIds,
    'rating': rating,
    'reviewCount': reviewCount,
    'isAvailable': isAvailable,
    'businessImage': businessImage,
    'serviceAreas': serviceAreas,
    'businessHours': businessHours,
  };

  factory Provider.fromMap(Map<String, dynamic> map) {
    final id = _extractId(map['id'] ?? map['_id']) ?? '';
    final userId = _extractId(map['user_id'] ?? map['userId']) ?? '';

    return Provider(
      id: id,
      userId: userId,
      companyName: _asString(map['company_name'] ?? map['companyName']),
      description: _asString(map['description']),
      serviceIds: _toIdList(map['service_ids'] ?? map['serviceIds']),
      rating: _toDouble(map['rating']),
      reviewCount: _toInt(map['review_count'] ?? map['reviewCount']),
      isAvailable: _toBool(map['is_available'] ?? map['isAvailable']),
      businessImage: _nullableString(
        map['business_image'] ?? map['businessImage'],
      ),
      serviceAreas: _toStringList(map['service_areas'] ?? map['serviceAreas']),
      businessHours: _asString(
        map['business_hours'] ?? map['businessHours'],
        fallback: '9 AM - 6 PM',
      ),
    );
  }

  static List<String> _toStringList(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map((item) => item?.toString() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static List<String> _toIdList(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map(_extractId)
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static String? _extractId(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      final nested = value['id'] ?? value['_id'];
      return nested?.toString();
    }
    return value.toString();
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

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static double _toDouble(dynamic value, {double fallback = 0.0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static bool _toBool(dynamic value, {bool fallback = true}) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return fallback;
  }

  Provider copyWith({
    String? id,
    String? userId,
    String? companyName,
    String? description,
    List<String>? serviceIds,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    String? businessImage,
    List<String>? serviceAreas,
    String? businessHours,
  }) {
    return Provider(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      description: description ?? this.description,
      serviceIds: serviceIds ?? this.serviceIds,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      businessImage: businessImage ?? this.businessImage,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      businessHours: businessHours ?? this.businessHours,
    );
  }
}
