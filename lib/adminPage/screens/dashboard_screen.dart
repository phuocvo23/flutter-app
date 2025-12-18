import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/admin_theme.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/stat_card.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';
import '../../services/user_service.dart';
import 'products_screen.dart';
import 'categories_screen.dart';
import 'orders_screen.dart';
import 'users_screen.dart';
import 'banners_screen.dart';

/// Dashboard Screen - Main admin page
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();
  final UserService _userService = UserService();

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
      case 5:
        return const BannersScreen();
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
                children: [
                  // Total Revenue
                  FutureBuilder<double>(
                    future: _orderService.getTotalRevenue(),
                    builder: (context, snapshot) {
                      final revenue = snapshot.data ?? 0;
                      return StatCard(
                        icon: Icons.attach_money,
                        title: 'Total Revenue',
                        value: '₫${NumberFormat.compact().format(revenue)}',
                        change: '+12.5%',
                        isPositive: true,
                        color: AdminTheme.success,
                      );
                    },
                  ),
                  // Total Orders
                  FutureBuilder<int>(
                    future: _orderService.getOrderCount(),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return StatCard(
                        icon: Icons.shopping_cart,
                        title: 'Total Orders',
                        value: '$count',
                        change: '+8.2%',
                        isPositive: true,
                        color: AdminTheme.info,
                      );
                    },
                  ),
                  // Products count
                  StreamBuilder(
                    stream: _productService.getAll(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return StatCard(
                        icon: Icons.inventory_2,
                        title: 'Products',
                        value: '$count',
                        change: '+3',
                        isPositive: true,
                        color: AdminTheme.warning,
                      );
                    },
                  ),
                  // Customers count
                  FutureBuilder<int>(
                    future: _userService.getUserCount(),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return StatCard(
                        icon: Icons.people,
                        title: 'Customers',
                        value: '$count',
                        change: '+5.1%',
                        isPositive: true,
                        color: AdminTheme.primary,
                      );
                    },
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
                _buildRecentOrdersTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersTable() {
    return StreamBuilder<List<Order>>(
      stream: _orderService.getRecent(limit: 5),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No recent orders'),
            ),
          );
        }

        final orders = snapshot.data!;
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
            ...orders.map((order) => _buildOrderRow(order)),
          ],
        );
      },
    );
  }

  TableRow _buildOrderRow(Order order) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final dateStr =
        order.createdAt != null ? dateFormat.format(order.createdAt!) : 'N/A';

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

    return TableRow(
      children: [
        _TableCell(text: '#${order.id.substring(0, 6).toUpperCase()}'),
        _TableCell(text: order.customerName),
        _TableCell(text: dateStr),
        _TableCell(
          text: '₫${NumberFormat.compact().format(order.totalAmount)}',
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              order.status,
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
