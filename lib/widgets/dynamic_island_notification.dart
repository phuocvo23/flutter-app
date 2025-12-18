import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Dynamic Island style notification overlay
class DynamicIslandNotification extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color? backgroundColor;
  final Duration duration;
  final VoidCallback? onDismiss;

  const DynamicIslandNotification({
    super.key,
    required this.message,
    this.icon,
    this.backgroundColor,
    this.duration = const Duration(seconds: 5),
    this.onDismiss,
  });

  @override
  State<DynamicIslandNotification> createState() =>
      _DynamicIslandNotificationState();
}

class _DynamicIslandNotificationState extends State<DynamicIslandNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _widthAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _widthAnimation = Tween<double>(begin: 50, end: 300).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Start expand animation
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _controller.forward();

        // Auto dismiss after duration
        _dismissTimer = Timer(widget.duration, _dismiss);
      }
    });
  }

  void _dismiss() {
    if (!mounted) return;
    _dismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 10,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _dismiss,
          onVerticalDragUpdate: (details) {
            // Swipe up to dismiss
            if (details.delta.dy < -5) {
              _dismiss();
            }
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final width = _widthAnimation.value;
              final showText = width > 120;

              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value.clamp(0.0, 1.0),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      height: 48,
                      width: width,
                      decoration: BoxDecoration(
                        color:
                            widget.backgroundColor ?? const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Center(
                          child:
                              showText
                                  ? _buildExpandedContent()
                                  : _buildCollapsedContent(),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return Icon(
      widget.icon ?? Icons.check_circle,
      color: Colors.white,
      size: 22,
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon ?? Icons.check_circle,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              widget.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Global notification service
class DynamicIslandService {
  static final DynamicIslandService _instance =
      DynamicIslandService._internal();
  factory DynamicIslandService() => _instance;
  DynamicIslandService._internal();

  OverlayEntry? _currentOverlay;

  /// Show notification
  void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 5),
  }) {
    // Remove existing notification
    _currentOverlay?.remove();
    _currentOverlay = null;

    final overlay = Overlay.of(context);

    _currentOverlay = OverlayEntry(
      builder:
          (context) => DynamicIslandNotification(
            message: message,
            icon: icon,
            backgroundColor: backgroundColor,
            duration: duration,
            onDismiss: () {
              _currentOverlay?.remove();
              _currentOverlay = null;
            },
          ),
    );

    overlay.insert(_currentOverlay!);
  }

  /// Show success notification
  void showSuccess(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: AppColors.success,
    );
  }

  /// Show error notification
  void showError(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.error,
      backgroundColor: AppColors.error,
    );
  }

  /// Show cart notification
  void showAddedToCart(BuildContext context, String productName) {
    show(
      context,
      message: 'Đã thêm $productName',
      icon: Icons.shopping_cart,
      backgroundColor: AppColors.primary,
    );
  }

  /// Show wishlist notification
  void showAddedToWishlist(BuildContext context) {
    show(
      context,
      message: 'Đã thêm vào yêu thích',
      icon: Icons.favorite,
      backgroundColor: AppColors.error,
    );
  }

  /// Show removed from wishlist
  void showRemovedFromWishlist(BuildContext context) {
    show(
      context,
      message: 'Đã xóa khỏi yêu thích',
      icon: Icons.favorite_border,
      backgroundColor: AppColors.textSecondary,
    );
  }

  /// Dismiss current notification
  void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

// Global instance for easy access
final dynamicIsland = DynamicIslandService();
