import 'package:flutter/material.dart';

/// Model danh mục sản phẩm
class Category {
  final String id;
  final String name;
  final IconData icon;
  final String imageUrl;
  final int productCount;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
    this.productCount = 0,
  });

  /// Demo categories cho Fuot Shop
  static List<Category> demoCategories = [
    const Category(
      id: 'helmets',
      name: 'Mũ Bảo Hiểm',
      icon: Icons.sports_motorsports,
      imageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      productCount: 24,
    ),
    const Category(
      id: 'gloves',
      name: 'Găng Tay',
      icon: Icons.back_hand,
      imageUrl:
          'https://images.unsplash.com/photo-1584467541268-b040f83be3fd?w=400',
      productCount: 18,
    ),
    const Category(
      id: 'jackets',
      name: 'Áo Khoác',
      icon: Icons.checkroom,
      imageUrl:
          'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
      productCount: 32,
    ),
    const Category(
      id: 'protection',
      name: 'Giáp Bảo Hộ',
      icon: Icons.shield,
      imageUrl:
          'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400',
      productCount: 15,
    ),
    const Category(
      id: 'boots',
      name: 'Giày Touring',
      icon: Icons.snowshoeing,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
      productCount: 20,
    ),
    const Category(
      id: 'bags',
      name: 'Túi & Balo',
      icon: Icons.backpack,
      imageUrl:
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
      productCount: 28,
    ),
    const Category(
      id: 'pants',
      name: 'Quần Riding',
      icon: Icons.dry_cleaning,
      imageUrl:
          'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=400',
      productCount: 16,
    ),
    const Category(
      id: 'accessories',
      name: 'Phụ Kiện',
      icon: Icons.settings_input_component,
      imageUrl:
          'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=400',
      productCount: 45,
    ),
  ];

  static Category? getById(String id) {
    try {
      return demoCategories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
