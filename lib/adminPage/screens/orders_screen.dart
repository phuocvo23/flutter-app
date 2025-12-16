import 'package:flutter/material.dart';
import '../config/admin_theme.dart';

/// Orders Management Screen
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _statusFilter = 'All';

  // Demo orders data
  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#1234',
      'customer': 'John Doe',
      'email': 'john@email.com',
      'date': 'Dec 15, 2024',
      'amount': 150.00,
      'status': 'Completed',
      'items': 3,
    },
    {
      'id': '#1233',
      'customer': 'Jane Smith',
      'email': 'jane@email.com',
      'date': 'Dec 14, 2024',
      'amount': 89.50,
      'status': 'Pending',
      'items': 2,
    },
    {
      'id': '#1232',
      'customer': 'Mike Johnson',
      'email': 'mike@email.com',
      'date': 'Dec 14, 2024',
      'amount': 234.00,
      'status': 'Shipping',
      'items': 4,
    },
    {
      'id': '#1231',
      'customer': 'Sarah Wilson',
      'email': 'sarah@email.com',
      'date': 'Dec 13, 2024',
      'amount': 67.00,
      'status': 'Completed',
      'items': 1,
    },
    {
      'id': '#1230',
      'customer': 'Tom Brown',
      'email': 'tom@email.com',
      'date': 'Dec 13, 2024',
      'amount': 412.00,
      'status': 'Completed',
      'items': 5,
    },
    {
      'id': '#1229',
      'customer': 'Emily Davis',
      'email': 'emily@email.com',
      'date': 'Dec 12, 2024',
      'amount': 178.00,
      'status': 'Cancelled',
      'items': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredOrders =
        _statusFilter == 'All'
            ? _orders
            : _orders.where((o) => o['status'] == _statusFilter).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Orders',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AdminTheme.textPrimary,
            ),
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
              child: SingleChildScrollView(
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
                      filteredOrders
                          .map((order) => _buildOrderRow(order))
                          .toList(),
                ),
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

  DataRow _buildOrderRow(Map<String, dynamic> order) {
    Color statusColor;
    switch (order['status']) {
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

    return DataRow(
      cells: [
        DataCell(
          Text(
            order['id'],
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                order['customer'],
                style: const TextStyle(color: AdminTheme.textPrimary),
              ),
              Text(
                order['email'],
                style: const TextStyle(
                  fontSize: 12,
                  color: AdminTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(order['date'])),
        DataCell(Text('${order['items']} items')),
        DataCell(
          Text(
            '\$${order['amount'].toStringAsFixed(2)}',
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
              order['status'],
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
                onSelected: (value) {
                  setState(() => order['status'] = value);
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

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AdminTheme.surface,
            title: Text('Order ${order['id']}'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Customer', order['customer']),
                  _buildDetailRow('Email', order['email']),
                  _buildDetailRow('Date', order['date']),
                  _buildDetailRow('Items', '${order['items']} items'),
                  _buildDetailRow(
                    'Amount',
                    '\$${order['amount'].toStringAsFixed(2)}',
                  ),
                  _buildDetailRow('Status', order['status']),
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
