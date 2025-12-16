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
  });

  double get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  /// Demo data cho Fuot Shop
  static List<Product> demoProducts = [
    const Product(
      id: '1',
      name: 'Mũ Bảo Hiểm Royal M139',
      description:
          'Mũ bảo hiểm fullface cao cấp, kính chống UV, thông gió tốt. Phù hợp cho các chuyến đi phượt dài ngày.',
      imageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      category: 'helmets',
      price: 1250000,
      originalPrice: 1500000,
      rating: 4.8,
      reviewCount: 256,
      isNew: false,
      isFeatured: true,
      sizes: ['M', 'L', 'XL'],
      colors: ['Đen', 'Trắng', 'Đỏ'],
      stock: 50,
    ),
    const Product(
      id: '2',
      name: 'Găng Tay Dainese Carbon',
      description:
          'Găng tay da cao cấp với vỏ carbon bảo vệ, lót gel chống rung, cảm ứng điện thoại.',
      imageUrl:
          'https://images.unsplash.com/photo-1584467541268-b040f83be3fd?w=400',
      category: 'gloves',
      price: 890000,
      rating: 4.6,
      reviewCount: 128,
      isNew: true,
      isFeatured: true,
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Đen', 'Đen-Đỏ'],
      stock: 35,
    ),
    const Product(
      id: '3',
      name: 'Áo Giáp Alpinestars',
      description:
          'Áo giáp bảo hộ toàn thân, đạt chuẩn CE Level 2, thoáng khí, phù hợp thời tiết nóng.',
      imageUrl:
          'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400',
      category: 'protection',
      price: 2450000,
      originalPrice: 2800000,
      rating: 4.9,
      reviewCount: 89,
      isNew: false,
      isFeatured: true,
      sizes: ['S', 'M', 'L', 'XL', 'XXL'],
      colors: ['Đen'],
      stock: 20,
    ),
    const Product(
      id: '4',
      name: 'Balo Givi 35L',
      description:
          'Balo chống nước 35 lít, có khung cứng, phản quang, túi đựng laptop 15 inch.',
      imageUrl:
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
      category: 'bags',
      price: 1650000,
      rating: 4.7,
      reviewCount: 156,
      isNew: true,
      isFeatured: false,
      sizes: ['35L'],
      colors: ['Đen', 'Xám'],
      stock: 40,
    ),
    const Product(
      id: '5',
      name: 'Giày Touring TCX',
      description:
          'Giày touring chống nước, đế chống trượt, có đệm bảo vệ mắt cá chân.',
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
      category: 'boots',
      price: 1890000,
      originalPrice: 2200000,
      rating: 4.5,
      reviewCount: 92,
      isNew: false,
      isFeatured: true,
      sizes: ['39', '40', '41', '42', '43', '44'],
      colors: ['Đen', 'Nâu'],
      stock: 25,
    ),
    const Product(
      id: '6',
      name: 'Kính Riding Goggles',
      description:
          'Kính bảo hộ chống bụi, chống UV400, lens đổi màu thông minh.',
      imageUrl:
          'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=400',
      category: 'accessories',
      price: 450000,
      rating: 4.4,
      reviewCount: 203,
      isNew: true,
      isFeatured: false,
      colors: ['Đen', 'Bạc'],
      stock: 100,
    ),
    const Product(
      id: '7',
      name: 'Jacket Touring Duhan',
      description:
          'Áo khoác touring 4 mùa, có lớp lót tháo rời, tích hợp giáp CE vai và khuỷu tay.',
      imageUrl:
          'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
      category: 'jackets',
      price: 1850000,
      originalPrice: 2100000,
      rating: 4.6,
      reviewCount: 178,
      isNew: false,
      isFeatured: true,
      sizes: ['M', 'L', 'XL', 'XXL'],
      colors: ['Đen', 'Xám', 'Xanh Navy'],
      stock: 30,
    ),
    const Product(
      id: '8',
      name: 'Quần Riding Komine',
      description: 'Quần bảo hộ vải jean có giáp đầu gối, chống nước nhẹ.',
      imageUrl:
          'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=400',
      category: 'pants',
      price: 980000,
      rating: 4.3,
      reviewCount: 87,
      isNew: true,
      isFeatured: false,
      sizes: ['30', '32', '34', '36', '38'],
      colors: ['Xanh đậm', 'Đen'],
      stock: 45,
    ),
  ];

  static List<Product> get featuredProducts =>
      demoProducts.where((p) => p.isFeatured).toList();

  static List<Product> get newArrivals =>
      demoProducts.where((p) => p.isNew).toList();

  static List<Product> getByCategory(String categoryId) =>
      demoProducts.where((p) => p.category == categoryId).toList();
}
