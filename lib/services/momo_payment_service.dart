import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// MoMo Payment Service - Tích hợp API thanh toán MoMo
///
/// Yêu cầu: Tài khoản MoMo Business với PartnerCode, AccessKey, SecretKey
/// Đăng ký tại: https://developers.momo.vn/v3/vi/docs/payment/onboarding/merchant-profile
class MomoPaymentService {
  // ⚠️ THAY THẾ CÁC GIÁ TRỊ NÀY BẰNG THÔNG TIN TÀI KHOẢN MOMO BUSINESS CỦA BẠN
  static const String partnerCode = 'MOMO_PARTNER_CODE'; // Mã đối tác MoMo
  static const String accessKey = 'MOMO_ACCESS_KEY'; // Access Key
  static const String secretKey = 'MOMO_SECRET_KEY'; // Secret Key

  // URL scheme để nhận callback từ MoMo
  static const String redirectUrl = 'fuotshop://momo-return';
  static const String ipnUrl =
      'https://your-server.com/momo/ipn'; // Webhook URL

  // API endpoints
  static const String _testEndpoint =
      'https://test-payment.momo.vn/v2/gateway/api/create';
  static const String _productionEndpoint =
      'https://payment.momo.vn/v2/gateway/api/create';
  static const String _testStatusEndpoint =
      'https://test-payment.momo.vn/v2/gateway/api/query';
  static const String _productionStatusEndpoint =
      'https://payment.momo.vn/v2/gateway/api/query';

  // Chế độ test (true) hoặc production (false)
  static const bool isTestMode = true;

  String get _endpoint => isTestMode ? _testEndpoint : _productionEndpoint;
  String get _statusEndpoint =>
      isTestMode ? _testStatusEndpoint : _productionStatusEndpoint;

  /// Tạo yêu cầu thanh toán MoMo
  ///
  /// [orderId] - Mã đơn hàng duy nhất
  /// [orderInfo] - Thông tin đơn hàng
  /// [amount] - Số tiền (VNĐ)
  ///
  /// Returns: URL thanh toán hoặc null nếu lỗi
  Future<MomoPaymentResponse> createPayment({
    required String orderId,
    required String orderInfo,
    required int amount,
  }) async {
    final requestId = '${orderId}_${DateTime.now().millisecondsSinceEpoch}';
    final extraData = base64Encode(utf8.encode(''));

    // Tạo raw signature
    final rawSignature =
        'accessKey=$accessKey'
        '&amount=$amount'
        '&extraData=$extraData'
        '&ipnUrl=$ipnUrl'
        '&orderId=$orderId'
        '&orderInfo=$orderInfo'
        '&partnerCode=$partnerCode'
        '&redirectUrl=$redirectUrl'
        '&requestId=$requestId'
        '&requestType=captureWallet';

    // Tạo HMAC SHA256 signature
    final signature = _generateSignature(rawSignature);

    // Request body
    final requestBody = {
      'partnerCode': partnerCode,
      'partnerName': 'Fuot Shop',
      'storeId': 'FuotShopStore',
      'requestId': requestId,
      'amount': amount,
      'orderId': orderId,
      'orderInfo': orderInfo,
      'redirectUrl': redirectUrl,
      'ipnUrl': ipnUrl,
      'lang': 'vi',
      'extraData': extraData,
      'requestType': 'captureWallet',
      'signature': signature,
    };

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MomoPaymentResponse.fromJson(data, requestId);
      } else {
        return MomoPaymentResponse(
          resultCode: -1,
          message: 'HTTP Error: ${response.statusCode}',
          requestId: requestId,
        );
      }
    } catch (e) {
      return MomoPaymentResponse(
        resultCode: -1,
        message: 'Network Error: $e',
        requestId: requestId,
      );
    }
  }

  /// Mở trang thanh toán MoMo
  Future<bool> openPaymentPage(String payUrl) async {
    final uri = Uri.parse(payUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  /// Kiểm tra trạng thái giao dịch
  Future<MomoStatusResponse> checkStatus({
    required String orderId,
    required String requestId,
  }) async {
    final rawSignature =
        'accessKey=$accessKey'
        '&orderId=$orderId'
        '&partnerCode=$partnerCode'
        '&requestId=$requestId';

    final signature = _generateSignature(rawSignature);

    final requestBody = {
      'partnerCode': partnerCode,
      'requestId': requestId,
      'orderId': orderId,
      'signature': signature,
      'lang': 'vi',
    };

    try {
      final response = await http.post(
        Uri.parse(_statusEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MomoStatusResponse.fromJson(data);
      } else {
        return MomoStatusResponse(
          resultCode: -1,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return MomoStatusResponse(resultCode: -1, message: 'Network Error: $e');
    }
  }

  /// Tạo HMAC SHA256 signature
  String _generateSignature(String rawData) {
    final key = utf8.encode(secretKey);
    final bytes = utf8.encode(rawData);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }
}

/// Response từ API tạo thanh toán
class MomoPaymentResponse {
  final int resultCode;
  final String message;
  final String? payUrl;
  final String? deeplink;
  final String? qrCodeUrl;
  final String requestId;

  MomoPaymentResponse({
    required this.resultCode,
    required this.message,
    this.payUrl,
    this.deeplink,
    this.qrCodeUrl,
    required this.requestId,
  });

  factory MomoPaymentResponse.fromJson(
    Map<String, dynamic> json,
    String requestId,
  ) {
    return MomoPaymentResponse(
      resultCode: json['resultCode'] ?? -1,
      message: json['message'] ?? 'Unknown error',
      payUrl: json['payUrl'],
      deeplink: json['deeplink'],
      qrCodeUrl: json['qrCodeUrl'],
      requestId: requestId,
    );
  }

  bool get isSuccess => resultCode == 0;
}

/// Response từ API kiểm tra trạng thái
class MomoStatusResponse {
  final int resultCode;
  final String message;
  final int? amount;
  final String? transId;

  MomoStatusResponse({
    required this.resultCode,
    required this.message,
    this.amount,
    this.transId,
  });

  factory MomoStatusResponse.fromJson(Map<String, dynamic> json) {
    return MomoStatusResponse(
      resultCode: json['resultCode'] ?? -1,
      message: json['message'] ?? 'Unknown error',
      amount: json['amount'],
      transId: json['transId']?.toString(),
    );
  }

  bool get isSuccess => resultCode == 0;
  bool get isPending => resultCode == 1000;
  bool get isFailed => resultCode != 0 && resultCode != 1000;
}
