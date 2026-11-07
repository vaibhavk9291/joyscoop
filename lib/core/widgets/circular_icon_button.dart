import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_shadows.dart';

/// Circular icon button (44x44 white circle, soft shadow, 20px outline icon)
/// Tap target is padded to at least 48x48.
class CircularIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final Color? iconColor;

  const CircularIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.tooltip,
    this.iconColor,
  });

  @override
  State<CircularIconButton> createState() => _CircularIconButtonState();
}

class _CircularIconButtonState extends State<CircularIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
      HapticFeedback.lightImpact();
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget button = Center(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: AppDimensions.circleButtonSize,
          height: AppDimensions.circleButtonSize,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: AppShadows.circularButtonShadow,
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: 20,
              color: widget.iconColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );

    // Ensure 48x48 tap target
    button = ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: AppDimensions.minTapTargetSize,
        minHeight: AppDimensions.minTapTargetSize,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: button,
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

