import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_colors.dart';
import '../utils/price_formatter.dart';

/// Màn hình thanh toán MoMo trực tiếp (không qua API)
class MomoPaymentScreen extends StatelessWidget {
  final double amount;
  final String orderId;
  final VoidCallback onPaymentConfirmed;

  const MomoPaymentScreen({
    super.key,
    required this.amount,
    required this.orderId,
    required this.onPaymentConfirmed,
  });

  // Số MoMo nhận tiền
  static const String momoPhone = '0898924277';
  static const String momoName = 'Fuot Shop';

  @override
  Widget build(BuildContext context) {
    // Tạo deep link MoMo
    final momoDeeplink =
        '2|99|$momoPhone|$momoName|${amount.toInt()}|Thanh toan don hang $orderId';

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
                    _formatPrice(amount),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB0006D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // QR Code
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Quét mã QR bằng app MoMo',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  QrImageView(
                    data: momoDeeplink,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      color: Color(0xFFB0006D),
                      eyeShape: QrEyeShape.square,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      color: Color(0xFFB0006D),
                      dataModuleShape: QrDataModuleShape.square,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hoặc',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  // Open MoMo App button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _openMomoApp(context),
                      icon: const Icon(Icons.open_in_new, color: Colors.white),
                      label: const Text(
                        'Mở App MoMo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB0006D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Transfer info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chuyển tiền thủ công',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Số điện thoại:', momoPhone, context),
                  const SizedBox(height: 12),
                  _buildInfoRow('Tên:', momoName, context),
                  const SizedBox(height: 12),
                  _buildInfoRow('Số tiền:', _formatPrice(amount), context),
                  const SizedBox(height: 12),
                  _buildInfoRow('Nội dung:', 'DH$orderId', context),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
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
                  Icon(Icons.info_outline, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Sau khi chuyển tiền xong, nhấn "Đã thanh toán" để xác nhận đơn hàng.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onPaymentConfirmed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB0006D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Đã thanh toán',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Row(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã sao chép: $value'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: const Icon(
                Icons.copy,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    return formatVietnamPrice(price);
  }

  /// Mở app MoMo với thông tin thanh toán
  Future<void> _openMomoApp(BuildContext context) async {
    // MoMo deep link format
    final momoUri = Uri.parse(
      'momo://app?action=payWithApp'
      '&partner=merchant'
      '&appScheme=momopayment'
      '&amount=${amount.toInt()}'
      '&description=DH$orderId',
    );

    // Fallback to MoMo website
    final momoWebUri = Uri.parse('https://me.momo.vn/$momoPhone');

    try {
      if (await canLaunchUrl(momoUri)) {
        await launchUrl(momoUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(momoWebUri)) {
        await launchUrl(momoWebUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Không tìm thấy app MoMo. Vui lòng quét QR hoặc chuyển thủ công.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }
}
