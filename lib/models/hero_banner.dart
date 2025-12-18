import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho Banner Hero trên trang chủ
class HeroBanner {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String buttonText;
  final String? linkType; // 'category', 'product', 'url'
  final String? linkValue; // categoryId, productId, or URL
  final bool isActive;
  final int order;
  final DateTime createdAt;

  HeroBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.buttonText = 'Xem ngay',
    this.linkType,
    this.linkValue,
    this.isActive = true,
    this.order = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory HeroBanner.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HeroBanner(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      buttonText: data['buttonText'] ?? 'Xem ngay',
      linkType: data['linkType'],
      linkValue: data['linkValue'],
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'buttonText': buttonText,
      'linkType': linkType,
      'linkValue': linkValue,
      'isActive': isActive,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  HeroBanner copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? buttonText,
    String? linkType,
    String? linkValue,
    bool? isActive,
    int? order,
  }) {
    return HeroBanner(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      buttonText: buttonText ?? this.buttonText,
      linkType: linkType ?? this.linkType,
      linkValue: linkValue ?? this.linkValue,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt,
    );
  }
}
