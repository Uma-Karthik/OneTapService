import 'package:flutter/material.dart';
import '../utils/service_icons.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final double price;
  final double rating;
  final int reviews;
  final String imageUrl;
  final List<String> features;
  final String category;
  final String providerId;
  final String providerName;
  final bool isAvailable;
  final int durationMinutes;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
    required this.features,
    required this.category,
    required this.providerId,
    this.providerName = '',
    this.isAvailable = true,
    this.durationMinutes = 60,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'category': category,
    'price': price,
    'duration': '$durationMinutes min',
    'icon': icon,
    'imageUrl': imageUrl,
    'rating': rating,
    'reviewCount': reviews,
    'isAvailable': isAvailable,
    'features': features,
  };

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    final providerData = _toMap(map['providerId']);
    final id = _extractId(map['id'] ?? map['_id']) ?? '';
    final providerId =
        _extractId(map['provider_id'] ?? map['providerId']) ?? '';

    return ServiceModel(
      id: id,
      name: (map['name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      icon: _resolveIcon(map['icon'], map['category']),
      price: _toDouble(map['price']),
      rating: _toDouble(map['rating']),
      reviews: _toInt(map['reviews'] ?? map['reviewCount']),
      imageUrl: (map['image_url'] ?? map['imageUrl'] ?? '').toString(),
      features: List<String>.from(map['features'] ?? []),
      category: (map['category'] ?? '').toString(),
      providerId: providerId,
      providerName: (map['providerName'] ?? providerData?['companyName'] ?? '')
          .toString(),
      isAvailable: _toBool(
        map['isAvailable'] ?? providerData?['isAvailable'],
        fallback: true,
      ),
      durationMinutes: _parseDurationMinutes(
        map['duration_minutes'] ?? map['durationMinutes'] ?? map['duration'],
      ),
    );
  }

  static Map<String, dynamic>? _toMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
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

  static int _parseDurationMinutes(dynamic value, {int fallback = 60}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final match = RegExp(r'\d+').firstMatch(value);
      if (match != null) return int.tryParse(match.group(0)!) ?? fallback;
    }
    return fallback;
  }

  static String _resolveIcon(dynamic rawIcon, dynamic rawCategory) {
    return ServiceIcons.normalize(
      rawIcon?.toString(),
      category: rawCategory?.toString(),
    );
  }
}

class ServiceCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}
