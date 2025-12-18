import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import '../widgets/custom_search_bar.dart';
import 'product_detail_screen.dart';

/// Màn hình danh sách sản phẩm theo category
class ProductListScreen extends StatefulWidget {
  final String categoryName;

  const ProductListScreen({super.key, required this.categoryName});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _sortBy = 'popular';
  final ProductService _productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productService.getByCategory(widget.categoryName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Product> products = snapshot.data ?? [];

          // Sort products
          products = _sortProducts(products);

          return Column(
            children: [
              // Search & Filter
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomSearchBar(
                        hintText: 'Tìm trong ${widget.categoryName}...',
                        onFilterTap: () => _showFilterSheet(),
                      ),
                    ),
                  ],
                ),
              ),

              // Sort Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${products.length} sản phẩm',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    PopupMenuButton<String>(
                      child: Row(
                        children: [
                          Text(
                            _getSortLabel(_sortBy),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      onSelected: (value) {
                        setState(() {
                          _sortBy = value;
                        });
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'popular',
                              child: Text('Phổ biến'),
                            ),
                            const PopupMenuItem(
                              value: 'newest',
                              child: Text('Mới nhất'),
                            ),
                            const PopupMenuItem(
                              value: 'price_low',
                              child: Text('Giá thấp → cao'),
                            ),
                            const PopupMenuItem(
                              value: 'price_high',
                              child: Text('Giá cao → thấp'),
                            ),
                            const PopupMenuItem(
                              value: 'rating',
                              child: Text('Đánh giá cao'),
                            ),
                          ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Products Grid
              Expanded(
                child:
                    products.isEmpty
                        ? const Center(
                          child: Text('Không có sản phẩm trong danh mục này'),
                        )
                        : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return ProductCard(
                              product: product,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ProductDetailScreen(
                                          product: product,
                                        ),
                                  ),
                                );
                              },
                              onAddToCart: () {
                                CartState.addItem(CartItem(product: product));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Đã thêm ${product.name} vào giỏ hàng',
                                    ),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'popular':
        return 'Phổ biến';
      case 'newest':
        return 'Mới nhất';
      case 'price_low':
        return 'Giá thấp → cao';
      case 'price_high':
        return 'Giá cao → thấp';
      case 'rating':
        return 'Đánh giá cao';
      default:
        return 'Sắp xếp';
    }
  }

  List<Product> _sortProducts(List<Product> products) {
    final sorted = List<Product>.from(products);
    switch (_sortBy) {
      case 'newest':
        sorted.sort((a, b) => b.isNew ? 1 : -1);
        break;
      case 'price_low':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        sorted.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    }
    return sorted;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder:
                (context, scrollController) => Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Bộ lọc',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text(
                            'Khoảng giá',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildFilterChip('Dưới 500K'),
                              _buildFilterChip('500K - 1M'),
                              _buildFilterChip('1M - 2M'),
                              _buildFilterChip('Trên 2M'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Đánh giá',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildFilterChip('4+ ⭐'),
                              _buildFilterChip('3+ ⭐'),
                              _buildFilterChip('2+ ⭐'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Áp dụng'),
                        ),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (_) {},
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withOpacity(0.2),
    );
  }
}
