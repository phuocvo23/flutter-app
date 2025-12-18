import 'package:intl/intl.dart';

/// Format giá tiền theo định dạng Việt Nam
/// Ví dụ: 1500000 -> "1.500.000 đ"
String formatVietnamPrice(double price) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return '${formatter.format(price.round())} đ';
}

/// Format giá tiền ngắn gọn
/// Ví dụ: 1500000 -> "1.5M đ", 500000 -> "500K đ"
String formatVietnamPriceShort(double price) {
  if (price >= 1000000) {
    return '${(price / 1000000).toStringAsFixed(1)}M đ';
  } else if (price >= 1000) {
    return '${(price / 1000).toStringAsFixed(0)}K đ';
  }
  return '${price.toStringAsFixed(0)} đ';
}
