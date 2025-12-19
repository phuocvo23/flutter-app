import 'package:flutter/material.dart';

/// Responsive utilities for tablet and phone layouts
class ResponsiveUtils {
  /// Breakpoints
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 900;
  static const double desktopMaxWidth = 1200;

  /// Check device type
  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < phoneMaxWidth;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= phoneMaxWidth && width < desktopMaxWidth;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopMaxWidth;
  }

  /// Get product grid column count based on screen width
  static int getProductGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopMaxWidth) return 5;
    if (width >= tabletMaxWidth) return 4;
    if (width >= phoneMaxWidth) return 3;
    return 2;
  }

  /// Get category grid column count
  static int getCategoryGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopMaxWidth) return 6;
    if (width >= tabletMaxWidth) return 5;
    if (width >= phoneMaxWidth) return 4;
    return 3;
  }

  /// Get horizontal padding based on screen size
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopMaxWidth) return 48;
    if (width >= tabletMaxWidth) return 32;
    if (width >= phoneMaxWidth) return 24;
    return 16;
  }

  /// Get child aspect ratio for product cards
  static double getProductCardAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= tabletMaxWidth) return 0.72;
    if (width >= phoneMaxWidth) return 0.68;
    return 0.65;
  }

  /// Get banner height
  static double getBannerHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= tabletMaxWidth) return 250;
    if (width >= phoneMaxWidth) return 200;
    return 180;
  }

  /// Get font scale for tablets
  static double getFontScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= tabletMaxWidth) return 1.15;
    if (width >= phoneMaxWidth) return 1.1;
    return 1.0;
  }
}
