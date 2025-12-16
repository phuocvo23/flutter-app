import 'package:flutter/material.dart';

/// Apple-inspired design styles - minimalist, rounded, smooth
class AppStyles {
  AppStyles._();

  // ============ Border Radius - Maximum roundness ============
  static const double radiusXs = 8.0;
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;
  static const double radiusFull = 999.0;

  static final BorderRadius borderRadiusXs = BorderRadius.circular(radiusXs);
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);
  static final BorderRadius borderRadiusFull = BorderRadius.circular(
    radiusFull,
  );

  // ============ Spacing - Apple-like generous spacing ============
  static const double spacingXxs = 4.0;
  static const double spacingXs = 8.0;
  static const double spacingSm = 12.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ============ Padding Presets ============
  static const EdgeInsets paddingXs = EdgeInsets.all(8);
  static const EdgeInsets paddingSm = EdgeInsets.all(12);
  static const EdgeInsets paddingMd = EdgeInsets.all(16);
  static const EdgeInsets paddingLg = EdgeInsets.all(24);
  static const EdgeInsets paddingXl = EdgeInsets.all(32);

  static const EdgeInsets paddingH = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets paddingV = EdgeInsets.symmetric(vertical: 16);

  // ============ Shadows - Subtle, Apple-like ============
  static List<BoxShadow> get shadowNone => [];

  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  // ============ Animation Durations - Super smooth ============
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 350);
  static const Duration animVerySlow = Duration(milliseconds: 500);

  // ============ Curves - Apple-like smooth curves ============
  static const Curve curveDefault = Curves.easeOutCubic;
  static const Curve curveSmooth = Curves.easeInOutCubic;
  static const Curve curveSpring = Curves.elasticOut;
  static const Curve curveBounce = Curves.bounceOut;

  // ============ Component Dimensions ============
  static const double buttonHeight = 56.0;
  static const double buttonHeightSmall = 44.0;
  static const double inputHeight = 56.0;
  static const double iconButtonSize = 48.0;
  static const double avatarSize = 48.0;
  static const double avatarSizeLg = 80.0;
  static const double bannerHeight = 160.0;
  static const double cardImageHeight = 160.0;
  static const double bottomNavHeight = 80.0;

  // ============ Icon Sizes ============
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // ============ Page Transitions - Smooth fade & slide ============
  static Route<T> fadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: curveSmooth),
          child: child,
        );
      },
      transitionDuration: animNormal,
    );
  }

  static Route<T> slideRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curveSmooth));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: animNormal,
    );
  }
}
