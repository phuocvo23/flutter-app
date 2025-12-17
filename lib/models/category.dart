import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model danh mục sản phẩm
class Category {
  final String id;
  final String name;
  final String iconName;
  final String imageUrl;
  final int productCount;

  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.imageUrl,
    this.productCount = 0,
  });

  /// Lấy IconData từ iconName
  IconData get icon {
    switch (iconName) {
      case 'sports_motorsports':
        return Icons.sports_motorsports;
      case 'back_hand':
        return Icons.back_hand;
      case 'checkroom':
        return Icons.checkroom;
      case 'shield':
        return Icons.shield;
      case 'snowshoeing':
        return Icons.snowshoeing;
      case 'backpack':
        return Icons.backpack;
      case 'dry_cleaning':
        return Icons.dry_cleaning;
      case 'settings_input_component':
        return Icons.settings_input_component;
      default:
        return Icons.category;
    }
  }

  /// Tạo Category từ Firestore document
  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      iconName: data['iconName'] ?? 'category',
      imageUrl: data['imageUrl'] ?? '',
      productCount: data['productCount'] ?? 0,
    );
  }

  /// Chuyển Category thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'iconName': iconName,
      'imageUrl': imageUrl,
      'productCount': productCount,
    };
  }
}
