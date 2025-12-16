import 'package:flutter/material.dart';
import '../config/admin_theme.dart';

/// Users Management Screen
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();

  // Demo users data
  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@email.com',
      'phone': '+1 234 567 890',
      'orders': 12,
      'spent': 1250.00,
      'joined': 'Oct 15, 2024',
      'status': 'Active',
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'email': 'jane@email.com',
      'phone': '+1 234 567 891',
      'orders': 8,
      'spent': 890.50,
      'joined': 'Nov 02, 2024',
      'status': 'Active',
    },
    {
      'id': '3',
      'name': 'Mike Johnson',
      'email': 'mike@email.com',
      'phone': '+1 234 567 892',
      'orders': 5,
      'spent': 450.00,
      'joined': 'Nov 20, 2024',
      'status': 'Active',
    },
    {
      'id': '4',
      'name': 'Sarah Wilson',
      'email': 'sarah@email.com',
      'phone': '+1 234 567 893',
      'orders': 15,
      'spent': 2100.00,
      'joined': 'Sep 10, 2024',
      'status': 'Active',
    },
    {
      'id': '5',
      'name': 'Tom Brown',
      'email': 'tom@email.com',
      'phone': '+1 234 567 894',
      'orders': 3,
      'spent': 180.00,
      'joined': 'Dec 01, 2024',
      'status': 'Inactive',
    },
    {
      'id': '6',
      'name': 'Emily Davis',
      'email': 'emily@email.com',
      'phone': '+1 234 567 895',
      'orders': 0,
      'spent': 0.00,
      'joined': 'Dec 10, 2024',
      'status': 'Pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Users',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AdminTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // Search
          SizedBox(
            width: 300,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(height: 24),

          // Users Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AdminTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('User')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Orders')),
                    DataColumn(label: Text('Total Spent')),
                    DataColumn(label: Text('Joined')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows:
                      _users
                          .where(
                            (u) =>
                                u['name'].toLowerCase().contains(
                                  _searchController.text.toLowerCase(),
                                ) ||
                                u['email'].toLowerCase().contains(
                                  _searchController.text.toLowerCase(),
                                ),
                          )
                          .map((user) => _buildUserRow(user))
                          .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildUserRow(Map<String, dynamic> user) {
    Color statusColor;
    switch (user['status']) {
      case 'Active':
        statusColor = AdminTheme.success;
        break;
      case 'Inactive':
        statusColor = AdminTheme.textSecondary;
        break;
      case 'Pending':
        statusColor = AdminTheme.warning;
        break;
      default:
        statusColor = AdminTheme.textSecondary;
    }

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AdminTheme.primary.withOpacity(0.1),
                child: Text(
                  user['name'][0],
                  style: const TextStyle(
                    color: AdminTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user['name'],
                    style: const TextStyle(
                      color: AdminTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    user['email'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AdminTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(Text(user['phone'])),
        DataCell(Text('${user['orders']}')),
        DataCell(
          Text(
            '\$${user['spent'].toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(Text(user['joined'])),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user['status'],
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
                onPressed: () => _showUserDetails(user),
                tooltip: 'View',
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AdminTheme.textSecondary,
                ),
                color: AdminTheme.card,
                onSelected: (value) {
                  setState(() => user['status'] = value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User status updated to $value')),
                  );
                },
                itemBuilder:
                    (_) => [
                      const PopupMenuItem(
                        value: 'Active',
                        child: Text('Set Active'),
                      ),
                      const PopupMenuItem(
                        value: 'Inactive',
                        child: Text('Set Inactive'),
                      ),
                    ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AdminTheme.surface,
            title: Text(user['name']),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Email', user['email']),
                  _buildDetailRow('Phone', user['phone']),
                  _buildDetailRow('Total Orders', '${user['orders']}'),
                  _buildDetailRow(
                    'Total Spent',
                    '\$${user['spent'].toStringAsFixed(2)}',
                  ),
                  _buildDetailRow('Joined', user['joined']),
                  _buildDetailRow('Status', user['status']),
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
