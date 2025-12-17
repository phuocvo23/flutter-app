import 'package:cloud_firestore/cloud_firestore.dart';

/// Model sản phẩm Fuot Shop
class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final bool isNew;
  final bool isFeatured;
  final List<String> sizes;
  final List<String> colors;
  final int stock;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.price,
    this.originalPrice,
    this.rating = 0,
    this.reviewCount = 0,
    this.isNew = false,
    this.isFeatured = false,
    this.sizes = const [],
    this.colors = const [],
    this.stock = 0,
    this.createdAt,
  });

  double get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  /// Tạo Product từ Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      originalPrice: data['originalPrice']?.toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isNew: data['isNew'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      sizes: List<String>.from(data['sizes'] ?? []),
      colors: List<String>.from(data['colors'] ?? []),
      stock: data['stock'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Chuyển Product thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'price': price,
      'originalPrice': originalPrice,
      'rating': rating,
      'reviewCount': reviewCount,
      'isNew': isNew,
      'isFeatured': isFeatured,
      'sizes': sizes,
      'colors': colors,
      'stock': stock,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
