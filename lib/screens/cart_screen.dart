import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_styles.dart';
import '../models/cart_item.dart';
import 'checkout_screen.dart';

/// Màn hình giỏ hàng
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final items = CartState.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        automaticallyImplyLeading: false,
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: _clearCart,
              child: const Text(
                'Xóa tất cả',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildCartItem(items[index], index);
                    },
                  ),
                ),
                _buildBottomSummary(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy thêm sản phẩm vào giỏ hàng',
            style: TextStyle(fontSize: 14, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppStyles.borderRadiusLg,
        boxShadow: AppStyles.shadowSm,
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: AppStyles.borderRadiusMd,
            child: Image.network(
              item.product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: AppColors.surface,
                child: const Icon(Icons.image, color: AppColors.textHint),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                if (item.selectedSize != null || item.selectedColor != null)
                  Text(
                    [
                      if (item.selectedSize != null) item.selectedSize,
                      if (item.selectedColor != null) item.selectedColor,
                    ].join(' • '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatPrice(item.product.price),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    // Quantity Controls
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              if (item.quantity > 1) {
                                setState(() {
                                  CartState.updateQuantity(
                                    index,
                                    item.quantity - 1,
                                  );
                                });
                              } else {
                                _removeItem(index);
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.remove, size: 18),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              item.quantity.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                CartState.updateQuantity(
                                  index,
                                  item.quantity + 1,
                                );
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.add, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete Button
          IconButton(
            onPressed: () => _removeItem(index),
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tạm tính',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  _formatPrice(CartState.subtotal),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Shipping
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Phí vận chuyển',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  CartState.shippingFee == 0
                      ? 'Miễn phí'
                      : _formatPrice(CartState.shippingFee),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: CartState.shippingFee == 0
                        ? AppColors.success
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (CartState.shippingFee > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Miễn phí vận chuyển cho đơn từ ${_formatPrice(500000)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  _formatPrice(CartState.total),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: CartState.items.isNotEmpty
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CheckoutScreen(),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Tiến hành thanh toán',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      CartState.removeItem(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa sản phẩm khỏi giỏ hàng'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa giỏ hàng'),
        content: const Text('Bạn có chắc muốn xóa tất cả sản phẩm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                CartState.clear();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M đ';
    }
    return '${(price / 1000).toStringAsFixed(0)}K đ';
  }
}
