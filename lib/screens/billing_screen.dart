import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_styles.dart';
import '../models/cart_item.dart';
import 'home_screen.dart';

/// Màn hình xác nhận đơn hàng (Billing)
class BillingScreen extends StatelessWidget {
  final String customerName;
  final String phone;
  final String address;
  final String paymentMethod;
  final String shippingMethod;
  final double total;

  const BillingScreen({
    super.key,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận đơn hàng'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Success Icon
          const Icon(Icons.check_circle, color: AppColors.success, size: 80),
          const SizedBox(height: 16),
          const Text(
            'Đặt hàng thành công!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mã đơn hàng: #FS${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Order Summary
          _buildSection(
            title: 'Thông tin giao hàng',
            children: [
              _buildInfoRow(Icons.person_outline, customerName),
              _buildInfoRow(Icons.phone_outlined, phone),
              _buildInfoRow(Icons.location_on_outlined, address),
            ],
          ),
          const SizedBox(height: 16),

          _buildSection(
            title: 'Phương thức',
            children: [
              _buildInfoRow(
                Icons.local_shipping_outlined,
                shippingMethod == 'express'
                    ? 'Giao hàng nhanh'
                    : 'Giao hàng tiêu chuẩn',
              ),
              _buildInfoRow(
                Icons.payment_outlined,
                _getPaymentLabel(paymentMethod),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Products
          _buildSection(
            title: 'Sản phẩm (${CartState.itemCount} món)',
            children: CartState.items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.product.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50,
                              height: 50,
                              color: AppColors.surface,
                              child: const Icon(Icons.image, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'x${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatPrice(item.totalPrice),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),

          // Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppStyles.borderRadiusMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  _formatPrice(total),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Buttons
          ElevatedButton(
            onPressed: () {
              // Clear cart and go home
              CartState.clear();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Tiếp tục mua sắm',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              // TODO: Navigate to order tracking
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Theo dõi đơn hàng',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppStyles.borderRadiusMd,
        boxShadow: AppStyles.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  String _getPaymentLabel(String method) {
    switch (method) {
      case 'cod':
        return 'Thanh toán khi nhận hàng (COD)';
      case 'bank':
        return 'Chuyển khoản ngân hàng';
      case 'momo':
        return 'Ví MoMo';
      default:
        return method;
    }
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M đ';
    }
    return '${(price / 1000).toStringAsFixed(0)}K đ';
  }
}
