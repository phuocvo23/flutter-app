import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_styles.dart';
import '../models/product.dart';
import '../services/wishlist_service.dart';
import '../utils/price_formatter.dart';
import 'dynamic_island_notification.dart';

/// Product Card - Apple-inspired minimal design with wishlist
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final WishlistService _wishlistService = WishlistService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppStyles.animFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: AppStyles.curveSmooth),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  void _toggleWishlist() async {
    if (!_wishlistService.isLoggedIn) {
      dynamicIsland.showError(context, 'Vui lòng đăng nhập');
      return;
    }
    final added = await _wishlistService.toggle(widget.product.id);
    if (mounted) {
      if (added) {
        dynamicIsland.showAddedToWishlist(context);
      } else {
        dynamicIsland.showRemovedFromWishlist(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppStyles.borderRadiusLg,
            boxShadow: AppStyles.shadowSm,
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageHeight = constraints.maxHeight * 0.6;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: AppColors.surface,
                          child: Image.network(
                            widget.product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 32,
                                    color: AppColors.textHint,
                                  ),
                                ),
                          ),
                        ),
                        // Badge
                        if (widget.product.isNew || widget.product.hasDiscount)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    widget.product.isNew
                                        ? AppColors.info
                                        : AppColors.error,
                                borderRadius: AppStyles.borderRadiusFull,
                              ),
                              child: Text(
                                widget.product.isNew
                                    ? 'NEW'
                                    : '-${widget.product.discountPercent}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        // Wishlist button
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: StreamBuilder<bool>(
                            stream: _wishlistService.isInWishlistStream(
                              widget.product.id,
                            ),
                            builder: (context, snapshot) {
                              final isInWishlist = snapshot.data ?? false;
                              return GestureDetector(
                                onTap: _toggleWishlist,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isInWishlist
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        isInWishlist
                                            ? AppColors.error
                                            : AppColors.textSecondary,
                                    size: 16,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Name - max 2 lines
                          Text(
                            widget.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const Spacer(),
                          // Rating + Price row
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 10,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                widget.product.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatPrice(widget.product.price),
                                style: const TextStyle(
                                  fontSize: 13,
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
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return formatVietnamPrice(price);
  }
}
