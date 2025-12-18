import 'package:csv/csv.dart';
import '../models/product.dart';
import '../models/order.dart';
import 'product_service.dart';
import 'order_service.dart';

// Conditional import for web
import 'csv_service_stub.dart'
    if (dart.library.html) 'csv_service_web.dart'
    as platform;

/// Service để xuất/nhập CSV
class CsvService {
  final ProductService _productService = ProductService();
  final OrderService _orderService = OrderService();

  // ============ PRODUCTS ============

  /// Export products to CSV string
  Future<String> exportProductsToCsv() async {
    final products = await _productService.getAll().first;

    List<List<dynamic>> rows = [
      // Header
      [
        'id',
        'name',
        'description',
        'price',
        'originalPrice',
        'category',
        'imageUrl',
        'rating',
        'reviewCount',
        'stock',
        'isNew',
        'isFeatured',
        'sizes',
        'colors',
      ],
    ];

    for (final product in products) {
      rows.add([
        product.id,
        product.name,
        product.description,
        product.price,
        product.originalPrice ?? '',
        product.category,
        product.imageUrl,
        product.rating,
        product.reviewCount,
        product.stock,
        product.isNew,
        product.isFeatured,
        product.sizes.join('|'),
        product.colors.join('|'),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Download products CSV
  Future<bool> downloadProductsCsv() async {
    try {
      final csvString = await exportProductsToCsv();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'products_$timestamp.csv';

      platform.downloadCsv(csvString, filename);
      return true;
    } catch (e) {
      print('Error exporting CSV: $e');
      return false;
    }
  }

  /// Import products from CSV (web uses file picker internally)
  Future<int> importProductsFromCsv() async {
    try {
      final csvString = await platform.pickAndReadCsvFile();
      if (csvString == null) return 0;

      final rows = const CsvToListConverter().convert(csvString);
      if (rows.isEmpty) return 0;

      // Skip header row
      int imported = 0;
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 14) continue;

        final product = Product(
          id: '', // Will be assigned by Firestore
          name: row[1].toString(),
          description: row[2].toString(),
          price: double.tryParse(row[3].toString()) ?? 0,
          originalPrice:
              row[4].toString().isNotEmpty
                  ? double.tryParse(row[4].toString())
                  : null,
          category: row[5].toString(),
          imageUrl: row[6].toString(),
          rating: double.tryParse(row[7].toString()) ?? 0,
          reviewCount: int.tryParse(row[8].toString()) ?? 0,
          stock: int.tryParse(row[9].toString()) ?? 0,
          isNew: row[10].toString().toLowerCase() == 'true',
          isFeatured: row[11].toString().toLowerCase() == 'true',
          sizes:
              row[12].toString().split('|').where((s) => s.isNotEmpty).toList(),
          colors:
              row[13].toString().split('|').where((s) => s.isNotEmpty).toList(),
        );

        await _productService.add(product);
        imported++;
      }

      return imported;
    } catch (e) {
      print('Error importing CSV: $e');
      return 0;
    }
  }

  // ============ ORDERS ============

  /// Export orders to CSV string
  Future<String> exportOrdersToCsv() async {
    final orders = await _orderService.getAll().first;

    List<List<dynamic>> rows = [
      // Header
      [
        'id',
        'customerId',
        'customerName',
        'customerEmail',
        'customerPhone',
        'totalAmount',
        'status',
        'paymentMethod',
        'shippingAddress',
        'note',
        'createdAt',
        'itemCount',
        'items',
      ],
    ];

    for (final order in orders) {
      final itemsStr = order.items
          .map((item) => '${item.productName}x${item.quantity}')
          .join(';');

      rows.add([
        order.id,
        order.customerId,
        order.customerName,
        order.customerEmail,
        order.customerPhone ?? '',
        order.totalAmount,
        order.status,
        order.paymentMethod ?? '',
        order.shippingAddress ?? '',
        order.note ?? '',
        order.createdAt?.toIso8601String() ?? '',
        order.itemCount,
        itemsStr,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Download orders CSV
  Future<bool> downloadOrdersCsv() async {
    try {
      final csvString = await exportOrdersToCsv();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'orders_$timestamp.csv';

      platform.downloadCsv(csvString, filename);
      return true;
    } catch (e) {
      print('Error exporting orders CSV: $e');
      return false;
    }
  }
}
