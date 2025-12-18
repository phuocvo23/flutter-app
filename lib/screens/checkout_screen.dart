import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_styles.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';
import '../utils/price_formatter.dart';
import 'billing_screen.dart';
import 'momo_payment_screen.dart';

/// Màn hình Checkout - nhập thông tin giao hàng
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final OrderService _orderService = OrderService();
  final AuthService _authService = AuthService();

  String _selectedPayment = 'cod';
  String _selectedShipping = 'standard';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with user info if logged in
    final user = _authService.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Shipping Info Section
            _buildSectionTitle('Thông tin giao hàng'),
            const SizedBox(height: 12),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập họ tên';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                prefixIcon: Icon(Icons.phone_outlined),
                counterText: '', // Hide counter
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                if (value.length != 10) {
                  return 'Số điện thoại phải có đúng 10 số';
                }
                if (!value.startsWith('0')) {
                  return 'Số điện thoại phải bắt đầu bằng số 0';
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'Số điện thoại chỉ được chứa chữ số';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ giao hàng',
                prefixIcon: Icon(Icons.location_on_outlined),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập địa chỉ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (tùy chọn)',
                prefixIcon: Icon(Icons.note_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Shipping Method
            _buildSectionTitle('Phương thức vận chuyển'),
            const SizedBox(height: 12),

            _buildShippingOption(
              id: 'standard',
              title: 'Giao hàng tiêu chuẩn',
              subtitle: '3-5 ngày làm việc',
              price: CartState.subtotal >= 500000 ? 0 : 30000,
            ),
            const SizedBox(height: 8),
            _buildShippingOption(
              id: 'express',
              title: 'Giao hàng nhanh',
              subtitle: '1-2 ngày làm việc',
              price: 50000,
            ),
            const SizedBox(height: 24),

            // Payment Method
            _buildSectionTitle('Phương thức thanh toán'),
            const SizedBox(height: 12),

            _buildPaymentOption(
              id: 'cod',
              title: 'Thanh toán khi nhận hàng',
              subtitle: 'COD - Tiền mặt',
              icon: Icons.money,
            ),
            const SizedBox(height: 8),
            _buildPaymentOption(
              id: 'bank',
              title: 'Chuyển khoản ngân hàng',
              subtitle: 'BIDV, Vietcombank, Techcombank...',
              icon: Icons.account_balance,
            ),
            const SizedBox(height: 8),
            _buildPaymentOption(
              id: 'momo',
              title: 'Ví MoMo',
              subtitle: 'Thanh toán qua ví điện tử',
              icon: Icons.account_balance_wallet,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),

      // Bottom Bar
      bottomNavigationBar: Container(
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
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng cộng',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _formatPrice(_calculateTotal()),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _proceed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            'Xác nhận đơn hàng',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildShippingOption({
    required String id,
    required String title,
    required String subtitle,
    required double price,
  }) {
    final isSelected = _selectedShipping == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedShipping = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppStyles.borderRadiusMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: id,
              groupValue: _selectedShipping,
              onChanged: (value) => setState(() => _selectedShipping = value!),
              activeColor: AppColors.primary,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price == 0 ? 'Miễn phí' : _formatPrice(price),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: price == 0 ? AppColors.success : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPayment == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppStyles.borderRadiusMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: id,
              groupValue: _selectedPayment,
              onChanged: (value) => setState(() => _selectedPayment = value!),
              activeColor: AppColors.primary,
            ),
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotal() {
    double shippingFee =
        _selectedShipping == 'express'
            ? 50000
            : (CartState.subtotal >= 500000 ? 0 : 30000);
    return CartState.subtotal + shippingFee;
  }

  Future<void> _proceed() async {
    if (!_formKey.currentState!.validate()) return;

    // If MoMo is selected, show MoMo payment screen first
    if (_selectedPayment == 'momo') {
      final tempOrderId = DateTime.now().millisecondsSinceEpoch.toString();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => MomoPaymentScreen(
                amount: _calculateTotal(),
                orderId: tempOrderId,
                onPaymentConfirmed: () {
                  Navigator.pop(context); // Close MoMo screen
                  _createOrder(); // Create order after payment confirmed
                },
              ),
        ),
      );
      return;
    }

    // For other payment methods, create order directly
    await _createOrder();
  }

  Future<void> _createOrder() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;

      // Create order items from cart
      final orderItems =
          CartState.items
              .map(
                (cartItem) => OrderItem(
                  productId: cartItem.product.id,
                  productName: cartItem.product.name,
                  price: cartItem.product.price,
                  quantity: cartItem.quantity,
                  imageUrl: cartItem.product.imageUrl,
                ),
              )
              .toList();

      // Create order
      final order = Order(
        id: '', // Will be set by Firestore
        customerId: user?.uid ?? 'guest',
        customerName: _nameController.text,
        customerEmail: user?.email ?? '',
        customerPhone: _phoneController.text,
        shippingAddress: _addressController.text,
        items: orderItems,
        totalAmount: _calculateTotal(),
        status: _selectedPayment == 'momo' ? 'Paid' : 'Pending',
        paymentMethod: _selectedPayment,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      final orderId = await _orderService.add(order);

      // Calculate total BEFORE clearing cart
      final totalAmount = _calculateTotal();

      // Clear cart after successful order (await to ensure storage is updated)
      await CartState.clear();

      if (mounted) {
        // Use pushAndRemoveUntil to prevent going back to checkout
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder:
                (_) => BillingScreen(
                  orderId: orderId,
                  customerName: _nameController.text,
                  phone: _phoneController.text,
                  address: _addressController.text,
                  paymentMethod: _selectedPayment,
                  shippingMethod: _selectedShipping,
                  total: totalAmount, // Use pre-calculated total
                ),
          ),
          (route) => route.isFirst, // Keep only the first route (HomeScreen)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi đặt hàng: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatPrice(double price) {
    return formatVietnamPrice(price);
  }
}
