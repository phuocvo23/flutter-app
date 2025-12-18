import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/admin_theme.dart';
import '../../models/app_user.dart';
import '../../services/user_service.dart';

/// Users Management Screen
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();
  final UserService _userService = UserService();

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
              child: StreamBuilder<List<AppUser>>(
                stream: _userService.getAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No users found'));
                  }

                  final users =
                      snapshot.data!
                          .where(
                            (u) =>
                                u.name.toLowerCase().contains(
                                  _searchController.text.toLowerCase(),
                                ) ||
                                u.email.toLowerCase().contains(
                                  _searchController.text.toLowerCase(),
                                ),
                          )
                          .toList();

                  return SingleChildScrollView(
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
                      rows: users.map((user) => _buildUserRow(user)).toList(),
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

  DataRow _buildUserRow(AppUser user) {
    Color statusColor;
    switch (user.status) {
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

    final dateFormat = DateFormat('MMM dd, yyyy');
    final joinedStr =
        user.createdAt != null ? dateFormat.format(user.createdAt!) : 'N/A';

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AdminTheme.primary.withOpacity(0.1),
                child: Text(
                  user.name.isNotEmpty ? user.name[0] : '?',
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
                    user.name,
                    style: const TextStyle(
                      color: AdminTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    user.email,
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
        DataCell(Text(user.phone ?? 'N/A')),
        DataCell(Text('${user.totalOrders}')),
        DataCell(
          Text(
            '₫${NumberFormat('#,###').format(user.totalSpent)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(Text(joinedStr)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.status,
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
                onSelected: (value) async {
                  await _userService.updateStatus(user.id, value);
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

  void _showUserDetails(AppUser user) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    final joinedStr =
        user.createdAt != null ? dateFormat.format(user.createdAt!) : 'N/A';
    final lastLoginStr =
        user.lastLoginAt != null ? dateFormat.format(user.lastLoginAt!) : 'N/A';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AdminTheme.surface,
            title: Text(user.name),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Email', user.email),
                  _buildDetailRow('Phone', user.phone ?? 'N/A'),
                  _buildDetailRow('Address', user.address ?? 'N/A'),
                  _buildDetailRow('Total Orders', '${user.totalOrders}'),
                  _buildDetailRow(
                    'Total Spent',
                    '₫${NumberFormat('#,###').format(user.totalSpent)}',
                  ),
                  _buildDetailRow('Joined', joinedStr),
                  _buildDetailRow('Last Login', lastLoginStr),
                  _buildDetailRow('Status', user.status),
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
}
