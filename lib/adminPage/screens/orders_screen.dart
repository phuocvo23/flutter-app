import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/admin_theme.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../services/csv_service.dart';

/// Orders Management Screen
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _statusFilter = 'All';
  final OrderService _orderService = OrderService();
  final CsvService _csvService = CsvService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Orders',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AdminTheme.textPrimary,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _exportOrdersCsv,
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Export CSV'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          Row(
            children: [
              _buildFilterChip('All'),
              const SizedBox(width: 8),
              _buildFilterChip('Pending'),
              const SizedBox(width: 8),
              _buildFilterChip('Shipping'),
              const SizedBox(width: 8),
              _buildFilterChip('Completed'),
              const SizedBox(width: 8),
              _buildFilterChip('Cancelled'),
            ],
          ),
          const SizedBox(height: 24),

          // Orders Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AdminTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: StreamBuilder<List<Order>>(
                stream:
                    _statusFilter == 'All'
                        ? _orderService.getAll()
                        : _orderService.getByStatus(_statusFilter),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No orders found'));
                  }

                  final orders = snapshot.data!;
                  return SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Order ID')),
                        DataColumn(label: Text('Customer')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Items')),
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows:
                          orders.map((order) => _buildOrderRow(order)).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status) {
    final isSelected = _statusFilter == status;
    return FilterChip(
      label: Text(status),
      selected: isSelected,
      onSelected: (selected) => setState(() => _statusFilter = status),
      selectedColor: AdminTheme.primary.withOpacity(0.2),
      checkmarkColor: AdminTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? AdminTheme.primary : AdminTheme.textSecondary,
      ),
    );
  }

  DataRow _buildOrderRow(Order order) {
    Color statusColor;
    switch (order.status) {
      case 'Completed':
        statusColor = AdminTheme.success;
        break;
      case 'Pending':
        statusColor = AdminTheme.warning;
        break;
      case 'Shipping':
        statusColor = AdminTheme.info;
        break;
      case 'Cancelled':
        statusColor = AdminTheme.error;
        break;
      default:
        statusColor = AdminTheme.textSecondary;
    }

    final dateFormat = DateFormat('MMM dd, yyyy');
    final dateStr =
        order.createdAt != null ? dateFormat.format(order.createdAt!) : 'N/A';

    return DataRow(
      cells: [
        DataCell(
          Text(
            '#${order.id.substring(0, 6).toUpperCase()}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                order.customerName,
                style: const TextStyle(color: AdminTheme.textPrimary),
              ),
              Text(
                order.customerEmail,
                style: const TextStyle(
                  fontSize: 12,
                  color: AdminTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(dateStr)),
        DataCell(Text('${order.itemCount} items')),
        DataCell(
          Text(
            '₫${NumberFormat('#,###').format(order.totalAmount)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              order.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: AdminTheme.info,
                ),
                onPressed: () => _showOrderDetails(order),
                tooltip: 'View',
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AdminTheme.textSecondary,
                ),
                color: AdminTheme.card,
                onSelected: (value) async {
                  await _orderService.updateStatus(order.id, value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order status updated to $value')),
                  );
                },
                itemBuilder:
                    (_) => [
                      const PopupMenuItem(
                        value: 'Pending',
                        child: Text('Set Pending'),
                      ),
                      const PopupMenuItem(
                        value: 'Shipping',
                        child: Text('Set Shipping'),
                      ),
                      const PopupMenuItem(
                        value: 'Completed',
                        child: Text('Set Completed'),
                      ),
                      const PopupMenuItem(
                        value: 'Cancelled',
                        child: Text('Set Cancelled'),
                      ),
                    ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showOrderDetails(Order order) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    final dateStr =
        order.createdAt != null ? dateFormat.format(order.createdAt!) : 'N/A';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AdminTheme.surface,
            title: Text('Order #${order.id.substring(0, 6).toUpperCase()}'),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Customer', order.customerName),
                  _buildDetailRow('Email', order.customerEmail),
                  _buildDetailRow('Phone', order.customerPhone ?? 'N/A'),
                  _buildDetailRow('Date', dateStr),
                  _buildDetailRow('Status', order.status),
                  _buildDetailRow(
                    'Shipping Address',
                    order.shippingAddress ?? 'N/A',
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Order Items',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AdminTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.productName} x${item.quantity}',
                              style: const TextStyle(
                                color: AdminTheme.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            '₫${NumberFormat('#,###').format(item.total)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    'Total Amount',
                    '₫${NumberFormat('#,###').format(order.totalAmount)}',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AdminTheme.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _exportOrdersCsv() async {
    try {
      final success = await _csvService.downloadOrdersCsv();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orders exported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }
}
