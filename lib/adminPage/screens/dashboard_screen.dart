import 'package:flutter/material.dart';
import '../config/admin_theme.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/stat_card.dart';
import 'products_screen.dart';
import 'categories_screen.dart';
import 'orders_screen.dart';
import 'users_screen.dart';

/// Dashboard Screen - Main admin page
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AdminSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) => setState(() => _selectedIndex = index),
          ),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 1:
        return const ProductsScreen();
      case 2:
        return const CategoriesScreen();
      case 3:
        return const OrdersScreen();
      case 4:
        return const UsersScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AdminTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Welcome back! Here\'s your store overview.',
            style: TextStyle(color: AdminTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          // Stats Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount =
                  constraints.maxWidth > 1200
                      ? 4
                      : (constraints.maxWidth > 800 ? 2 : 1);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.6,
                children: const [
                  StatCard(
                    icon: Icons.attach_money,
                    title: 'Total Revenue',
                    value: '\$45,231',
                    change: '+12.5%',
                    isPositive: true,
                    color: AdminTheme.success,
                  ),
                  StatCard(
                    icon: Icons.shopping_cart,
                    title: 'Total Orders',
                    value: '1,234',
                    change: '+8.2%',
                    isPositive: true,
                    color: AdminTheme.info,
                  ),
                  StatCard(
                    icon: Icons.inventory_2,
                    title: 'Products',
                    value: '156',
                    change: '+3',
                    isPositive: true,
                    color: AdminTheme.warning,
                  ),
                  StatCard(
                    icon: Icons.people,
                    title: 'Customers',
                    value: '2,451',
                    change: '+5.1%',
                    isPositive: true,
                    color: AdminTheme.primary,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Recent Orders
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AdminTheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AdminTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selectedIndex = 3),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildOrdersTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
      },
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(
            color: AdminTheme.card,
            borderRadius: BorderRadius.circular(8),
          ),
          children: const [
            _TableCell(text: 'Order ID', isHeader: true),
            _TableCell(text: 'Customer', isHeader: true),
            _TableCell(text: 'Date', isHeader: true),
            _TableCell(text: 'Amount', isHeader: true),
            _TableCell(text: 'Status', isHeader: true),
          ],
        ),
        // Data rows
        _buildOrderRow(
          '#1234',
          'John Doe',
          'Dec 15, 2024',
          '\$150.00',
          'Completed',
        ),
        _buildOrderRow(
          '#1233',
          'Jane Smith',
          'Dec 14, 2024',
          '\$89.50',
          'Pending',
        ),
        _buildOrderRow(
          '#1232',
          'Mike Johnson',
          'Dec 14, 2024',
          '\$234.00',
          'Shipping',
        ),
        _buildOrderRow(
          '#1231',
          'Sarah Wilson',
          'Dec 13, 2024',
          '\$67.00',
          'Completed',
        ),
        _buildOrderRow(
          '#1230',
          'Tom Brown',
          'Dec 13, 2024',
          '\$412.00',
          'Completed',
        ),
      ],
    );
  }

  TableRow _buildOrderRow(
    String id,
    String customer,
    String date,
    String amount,
    String status,
  ) {
    Color statusColor;
    switch (status) {
      case 'Completed':
        statusColor = AdminTheme.success;
        break;
      case 'Pending':
        statusColor = AdminTheme.warning;
        break;
      case 'Shipping':
        statusColor = AdminTheme.info;
        break;
      default:
        statusColor = AdminTheme.textSecondary;
    }

    return TableRow(
      children: [
        _TableCell(text: id),
        _TableCell(text: customer),
        _TableCell(text: date),
        _TableCell(text: amount),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;

  const _TableCell({required this.text, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          color: isHeader ? AdminTheme.textPrimary : AdminTheme.textSecondary,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
