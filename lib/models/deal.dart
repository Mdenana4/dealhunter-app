import 'package:flutter/material.dart';

class Deal {
  final String id;
  final String title;
  final String site;
  final String siteDisplay;
  final String category;
  final double currentPrice;
  final double originalPrice;
  final int discount;
  final String discountDisplay;
  final String? imageUrl;
  final String productUrl;
  final double? rating;
  final int? reviewCount;
  final String? asin;
  final String currency;
  final String? verificationStatus;
  final double? verificationConfidence;
  final DateTime? timestamp;
  bool isSaved;

  Deal({
    required this.id,
    required this.title,
    required this.site,
    required this.siteDisplay,
    required this.category,
    required this.currentPrice,
    required this.originalPrice,
    required this.discount,
    required this.discountDisplay,
    this.imageUrl,
    required this.productUrl,
    this.rating,
    this.reviewCount,
    this.asin,
    required this.currency,
    this.verificationStatus,
    this.verificationConfidence,
    this.timestamp,
    this.isSaved = false,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown Deal',
      site: json['site']?.toString() ?? 'unknown',
      siteDisplay: json['site_display']?.toString() ?? 'Unknown Store',
      category: json['category']?.toString() ?? 'general',
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toInt() ?? 0,
      discountDisplay: json['discount_display']?.toString() ?? '${json['discount']}% OFF',
      imageUrl: json['image_url']?.toString(),
      productUrl: json['product_url']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['review_count'] as num?)?.toInt(),
      asin: json['asin']?.toString(),
      currency: json['currency']?.toString() ?? 'EGP',
      verificationStatus: json['verification_status']?.toString(),
      verificationConfidence: (json['verification_confidence'] as num?)?.toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
      isSaved: json['is_saved'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'site': site,
      'site_display': siteDisplay,
      'category': category,
      'current_price': currentPrice,
      'original_price': originalPrice,
      'discount': discount,
      'discount_display': discountDisplay,
      'image_url': imageUrl,
      'product_url': productUrl,
      'rating': rating,
      'review_count': reviewCount,
      'asin': asin,
      'currency': currency,
      'verification_status': verificationStatus,
      'verification_confidence': verificationConfidence,
      'timestamp': timestamp?.toIso8601String(),
      'is_saved': isSaved,
    };
  }

  String get savings => (originalPrice - currentPrice).toStringAsFixed(0);

  double get savingsValue => originalPrice - currentPrice;

  Color get statusColor {
    switch (verificationStatus?.toUpperCase()) {
      case 'GENUINE':
        return const Color(0xFF10B981);
      case 'VERIFIED':
        return const Color(0xFF3B82F6);
      case 'SUSPICIOUS':
        return const Color(0xFFF59E0B);
      case 'FAKE':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  String get statusText {
    switch (verificationStatus?.toUpperCase()) {
      case 'GENUINE':
        return 'Verified Genuine';
      case 'VERIFIED':
        return 'Verified';
      case 'SUSPICIOUS':
        return 'Check Details';
      case 'FAKE':
        return 'Potential Fake';
      default:
        return 'Unverified';
    }
  }

  Deal copyWith({bool? isSaved}) {
    return Deal(
      id: id,
      title: title,
      site: site,
      siteDisplay: siteDisplay,
      category: category,
      currentPrice: currentPrice,
      originalPrice: originalPrice,
      discount: discount,
      discountDisplay: discountDisplay,
      imageUrl: imageUrl,
      productUrl: productUrl,
      rating: rating,
      reviewCount: reviewCount,
      asin: asin,
      currency: currency,
      verificationStatus: verificationStatus,
      verificationConfidence: verificationConfidence,
      timestamp: timestamp,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Deal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
