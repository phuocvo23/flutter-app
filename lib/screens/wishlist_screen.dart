import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_styles.dart';
import '../models/product.dart';
import '../services/wishlist_service.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';
import '../utils/price_formatter.dart';
import '../utils/responsive_utils.dart';
import 'product_detail_screen.dart';
import 'login_screen.dart';

/// Màn hình danh sách sản phẩm yêu thích
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    if (!_authService.isSignedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Yêu thích')),
        body: _buildNotLoggedIn(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu thích'),
        actions: [
          StreamBuilder<int>(
            stream: _wishlistService.getCountStream(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              if (count == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: _clearAll,
                child: const Text(
                  'Xóa tất cả',
                  style: TextStyle(color: AppColors.error),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<String>>(
        stream: _wishlistService.getProductIds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final productIds = snapshot.data ?? [];
          if (productIds.isEmpty) {
            return _buildEmpty();
          }

          return _buildWishlistGrid(productIds);
        },
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Vui lòng đăng nhập',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Để xem sản phẩm yêu thích',
            style: TextStyle(color: AppColors.textHint),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có sản phẩm yêu thích',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhấn ♡ để thêm sản phẩm',
            style: TextStyle(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistGrid(List<String> productIds) {
    return StreamBuilder<List<Product>>(
      stream: _productService.getAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allProducts = snapshot.data!;
        final wishlistProducts =
            allProducts.where((p) => productIds.contains(p.id)).toList();

        if (wishlistProducts.isEmpty) {
          return _buildEmpty();
        }

        return GridView.builder(
          padding: EdgeInsets.all(
            ResponsiveUtils.getHorizontalPadding(context),
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveUtils.getProductGridColumns(context),
            childAspectRatio: ResponsiveUtils.getProductCardAspectRatio(
              context,
            ),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: wishlistProducts.length,
          itemBuilder: (context, index) {
            final product = wishlistProducts[index];
            return _buildProductCard(product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppStyles.borderRadiusLg,
          boxShadow: AppStyles.shadowSm,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppColors.surface,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => const Center(
                            child: Icon(Icons.image_outlined, size: 32),
                          ),
                    ),
                  ),
                  // Remove button
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _removeFromWishlist(product),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: AppColors.error,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatPrice(product.price),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeFromWishlist(Product product) {
    _wishlistService.remove(product.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa ${product.name} khỏi yêu thích'),
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () => _wishlistService.add(product.id),
        ),
      ),
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa tất cả'),
            content: const Text(
              'Bạn có chắc muốn xóa tất cả sản phẩm yêu thích?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  _wishlistService.clearAll();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }

  String _formatPrice(double price) {
    return formatVietnamPrice(price);
  }
}
