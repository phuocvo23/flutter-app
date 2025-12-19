import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_colors.dart';
import '../utils/price_formatter.dart';
import '../services/momo_payment_service.dart';

/// Màn hình thanh toán MoMo qua API
class MomoPaymentScreen extends StatefulWidget {
  final double amount;
  final String orderId;
  final VoidCallback onPaymentConfirmed;

  const MomoPaymentScreen({
    super.key,
    required this.amount,
    required this.orderId,
    required this.onPaymentConfirmed,
  });

  @override
  State<MomoPaymentScreen> createState() => _MomoPaymentScreenState();
}

class _MomoPaymentScreenState extends State<MomoPaymentScreen>
    with WidgetsBindingObserver {
  final MomoPaymentService _momoService = MomoPaymentService();

  bool _isLoading = false;
  bool _isCheckingStatus = false;
  String? _errorMessage;
  String? _requestId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Kiểm tra trạng thái thanh toán khi user quay lại app
    if (state == AppLifecycleState.resumed && _requestId != null) {
      _checkPaymentStatus();
    }
  }

  /// Tạo thanh toán MoMo
  Future<void> _createPayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _momoService.createPayment(
      orderId: widget.orderId,
      orderInfo: 'Thanh toán đơn hàng #${widget.orderId}',
      amount: widget.amount.toInt(),
    );

    setState(() {
      _isLoading = false;
      _requestId = response.requestId;
    });

    if (response.isSuccess && response.payUrl != null) {
      // Mở trang thanh toán MoMo
      await _momoService.openPaymentPage(response.payUrl!);
    } else {
      setState(() {
        _errorMessage = response.message;
      });
    }
  }

  /// Kiểm tra trạng thái thanh toán
  Future<void> _checkPaymentStatus() async {
    if (_requestId == null) return;

    setState(() => _isCheckingStatus = true);

    final status = await _momoService.checkStatus(
      orderId: widget.orderId,
      requestId: _requestId!,
    );

    setState(() => _isCheckingStatus = false);

    if (status.isSuccess) {
      // Thanh toán thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanh toán thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onPaymentConfirmed();
      }
    } else if (status.isPending) {
      // Đang xử lý
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giao dịch đang được xử lý...'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      // Thất bại
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thanh toán thất bại: ${status.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thanh toán MoMo'),
        backgroundColor: const Color(0xFFB0006D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // MoMo logo/header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB0006D), Color(0xFFd82d8b)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Thanh toán qua MoMo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Amount
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Số tiền cần thanh toán',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatVietnamPrice(widget.amount),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB0006D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mã đơn: ${widget.orderId}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Error message
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Hướng dẫn thanh toán',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStep('1', 'Nhấn "Thanh toán ngay" để mở ứng dụng MoMo'),
                  _buildStep('2', 'Xác nhận thanh toán trong app MoMo'),
                  _buildStep(
                    '3',
                    'Quay lại ứng dụng, hệ thống sẽ tự động xác nhận',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Config notice
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cần cấu hình MoMo Business (PartnerCode, AccessKey, SecretKey) trong momo_payment_service.dart',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Payment button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB0006D),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Thanh toán ngay',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 12),

            // Check status button
            if (_requestId != null)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _isCheckingStatus ? null : _checkPaymentStatus,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFB0006D)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isCheckingStatus
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text(
                            'Kiểm tra trạng thái thanh toán',
                            style: TextStyle(color: Color(0xFFB0006D)),
                          ),
                ),
              ),
            const SizedBox(height: 12),

            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Hủy thanh toán',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.blue.shade800)),
          ),
        ],
      ),
    );
  }
}
