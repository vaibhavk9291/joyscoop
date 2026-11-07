import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_shadows.dart';

enum AppTab { today, history }

/// Floating pill bottom navigation strictly per DESIGN.md
class FloatingBottomNav extends StatelessWidget {
  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;

  const FloatingBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 16,
      ),
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.borderNav,
        boxShadow: AppShadows.floatingNavShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Today Tab
          _NavItem(
            icon: Icons.storefront_rounded,
            outlineIcon: Icons.storefront_outlined,
            isActive: currentTab == AppTab.today,
            label: 'Today',
            onTap: () => onTabSelected(AppTab.today),
          ),

          // History Tab
          _NavItem(
            icon: Icons.history_rounded,
            outlineIcon: Icons.history_outlined,
            isActive: currentTab == AppTab.history,
            label: 'History',
            onTap: () => onTabSelected(AppTab.history),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData outlineIcon;
  final bool isActive;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.outlineIcon,
    required this.isActive,
    required this.label,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
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

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          width: AppDimensions.navItemSize,
          height: AppDimensions.navItemSize,
          decoration: BoxDecoration(
            color: widget.isActive ? AppColors.primaryTint : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              widget.isActive ? widget.icon : widget.outlineIcon,
              size: 24,
              color: widget.isActive
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

