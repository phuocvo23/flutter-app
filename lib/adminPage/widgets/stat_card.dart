import 'package:flutter/material.dart';
import '../config/admin_theme.dart';

/// Stat Card for Dashboard
class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? change;
  final bool isPositive;
  final Color? color;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.change,
    this.isPositive = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AdminTheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const Spacer(),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isPositive ? AdminTheme.success : AdminTheme.error)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color:
                            isPositive ? AdminTheme.success : AdminTheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        change!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isPositive
                                  ? AdminTheme.success
                                  : AdminTheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AdminTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AdminTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
