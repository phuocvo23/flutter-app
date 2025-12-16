import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_styles.dart';

/// Custom Search Bar - Apple-inspired minimal design
class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onTap;
  final bool readOnly;
  final String hintText;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.onTap,
    this.readOnly = false,
    this.hintText = 'Tìm kiếm sản phẩm...',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppStyles.borderRadiusFull,
        ),
        child: Row(
          children: [
            const SizedBox(width: 18),
            Icon(Icons.search_rounded, color: AppColors.textHint, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                readOnly: readOnly,
                enabled: !readOnly,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: AppColors.textHint, fontSize: 16),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (onFilterTap != null)
              GestureDetector(
                onTap: onFilterTap,
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              )
            else
              const SizedBox(width: 18),
          ],
        ),
      ),
    );
  }
}
