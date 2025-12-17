import 'package:cloud_firestore/cloud_firestore.dart';

/// Seeder để thêm data ban đầu vào Firestore
/// Chỉ chạy 1 lần khi khởi tạo database
class FirestoreSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed tất cả data
  Future<void> seedAll() async {
    await seedCategories();
    await seedProducts();
    print('✅ Seeding completed!');
  }

  /// Seed categories
  Future<void> seedCategories() async {
    final categories = [
      {
        'name': 'Mũ Bảo Hiểm',
        'iconName': 'sports_motorsports',
        'imageUrl':
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
        'productCount': 24,
      },
      {
        'name': 'Găng Tay',
        'iconName': 'back_hand',
        'imageUrl':
            'https://images.unsplash.com/photo-1584467541268-b040f83be3fd?w=400',
        'productCount': 18,
      },
      {
        'name': 'Áo Khoác',
        'iconName': 'checkroom',
        'imageUrl':
            'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
        'productCount': 32,
      },
      {
        'name': 'Giáp Bảo Hộ',
        'iconName': 'shield',
        'imageUrl':
            'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400',
        'productCount': 15,
      },
      {
        'name': 'Giày Touring',
        'iconName': 'snowshoeing',
        'imageUrl':
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
        'productCount': 20,
      },
      {
        'name': 'Túi & Balo',
        'iconName': 'backpack',
        'imageUrl':
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
        'productCount': 28,
      },
      {
        'name': 'Quần Riding',
        'iconName': 'dry_cleaning',
        'imageUrl':
            'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=400',
        'productCount': 16,
      },
      {
        'name': 'Phụ Kiện',
        'iconName': 'settings_input_component',
        'imageUrl':
            'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=400',
        'productCount': 45,
      },
    ];

    final batch = _firestore.batch();
    final categoryIds = [
      'helmets',
      'gloves',
      'jackets',
      'protection',
      'boots',
      'bags',
      'pants',
      'accessories',
    ];

    for (int i = 0; i < categories.length; i++) {
      final docRef = _firestore.collection('categories').doc(categoryIds[i]);
      batch.set(docRef, categories[i]);
    }

    await batch.commit();
    print('✅ Categories seeded!');
  }

  /// Seed products
  Future<void> seedProducts() async {
    final products = [
      {
        'name': 'Mũ Bảo Hiểm Royal M139',
        'description':
            'Mũ bảo hiểm fullface cao cấp, kính chống UV, thông gió tốt. Phù hợp cho các chuyến đi phượt dài ngày.',
        'imageUrl':
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
        'category': 'helmets',
        'price': 1250000,
        'originalPrice': 1500000,
        'rating': 4.8,
        'reviewCount': 256,
        'isNew': false,
        'isFeatured': true,
        'sizes': ['M', 'L', 'XL'],
        'colors': ['Đen', 'Trắng', 'Đỏ'],
        'stock': 50,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Găng Tay Dainese Carbon',
        'description':
            'Găng tay da cao cấp với vỏ carbon bảo vệ, lót gel chống rung, cảm ứng điện thoại.',
        'imageUrl':
            'https://images.unsplash.com/photo-1584467541268-b040f83be3fd?w=400',
        'category': 'gloves',
        'price': 890000,
        'originalPrice': null,
        'rating': 4.6,
        'reviewCount': 128,
        'isNew': true,
        'isFeatured': true,
        'sizes': ['S', 'M', 'L', 'XL'],
        'colors': ['Đen', 'Đen-Đỏ'],
        'stock': 35,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Áo Giáp Alpinestars',
        'description':
            'Áo giáp bảo hộ toàn thân, đạt chuẩn CE Level 2, thoáng khí, phù hợp thời tiết nóng.',
        'imageUrl':
            'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400',
        'category': 'protection',
        'price': 2450000,
        'originalPrice': 2800000,
        'rating': 4.9,
        'reviewCount': 89,
        'isNew': false,
        'isFeatured': true,
        'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
        'colors': ['Đen'],
        'stock': 20,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Balo Givi 35L',
        'description':
            'Balo chống nước 35 lít, có khung cứng, phản quang, túi đựng laptop 15 inch.',
        'imageUrl':
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
        'category': 'bags',
        'price': 1650000,
        'originalPrice': null,
        'rating': 4.7,
        'reviewCount': 156,
        'isNew': true,
        'isFeatured': false,
        'sizes': ['35L'],
        'colors': ['Đen', 'Xám'],
        'stock': 40,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Giày Touring TCX',
        'description':
            'Giày touring chống nước, đế chống trượt, có đệm bảo vệ mắt cá chân.',
        'imageUrl':
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
        'category': 'boots',
        'price': 1890000,
        'originalPrice': 2200000,
        'rating': 4.5,
        'reviewCount': 92,
        'isNew': false,
        'isFeatured': true,
        'sizes': ['39', '40', '41', '42', '43', '44'],
        'colors': ['Đen', 'Nâu'],
        'stock': 25,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Kính Riding Goggles',
        'description':
            'Kính bảo hộ chống bụi, chống UV400, lens đổi màu thông minh.',
        'imageUrl':
            'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=400',
        'category': 'accessories',
        'price': 450000,
        'originalPrice': null,
        'rating': 4.4,
        'reviewCount': 203,
        'isNew': true,
        'isFeatured': false,
        'sizes': [],
        'colors': ['Đen', 'Bạc'],
        'stock': 100,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Jacket Touring Duhan',
        'description':
            'Áo khoác touring 4 mùa, có lớp lót tháo rời, tích hợp giáp CE vai và khuỷu tay.',
        'imageUrl':
            'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
        'category': 'jackets',
        'price': 1850000,
        'originalPrice': 2100000,
        'rating': 4.6,
        'reviewCount': 178,
        'isNew': false,
        'isFeatured': true,
        'sizes': ['M', 'L', 'XL', 'XXL'],
        'colors': ['Đen', 'Xám', 'Xanh Navy'],
        'stock': 30,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Quần Riding Komine',
        'description': 'Quần bảo hộ vải jean có giáp đầu gối, chống nước nhẹ.',
        'imageUrl':
            'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=400',
        'category': 'pants',
        'price': 980000,
        'originalPrice': null,
        'rating': 4.3,
        'reviewCount': 87,
        'isNew': true,
        'isFeatured': false,
        'sizes': ['30', '32', '34', '36', '38'],
        'colors': ['Xanh đậm', 'Đen'],
        'stock': 45,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    final batch = _firestore.batch();

    for (int i = 0; i < products.length; i++) {
      final docRef = _firestore.collection('products').doc('product_${i + 1}');
      batch.set(docRef, products[i]);
    }

    await batch.commit();
    print('✅ Products seeded!');
  }

  /// Kiểm tra xem đã seed chưa
  Future<bool> isSeeded() async {
    final productsSnapshot =
        await _firestore.collection('products').limit(1).get();
    return productsSnapshot.docs.isNotEmpty;
  }
}
