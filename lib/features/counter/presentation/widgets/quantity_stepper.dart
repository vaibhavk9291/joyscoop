import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Quantity stepper: row of [ - ] count [ + ]
/// Minus: 36px white circle with soft shadow and dark icon (disabled/surfaceMuted at 0)
/// Plus: 36px pink gradient circle with white icon
/// Count: 16 / 700 with AnimatedSwitcher slide & fade (180 ms)
/// Tap target: at least 48x48
/// Motion: scale to 0.92 over 120 ms with light haptic
class QuantityStepper extends StatelessWidget {
  final int count;
  final bool isMasked;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantityStepper({
    super.key,
    required this.count,
    this.isMasked = false,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final bool canDecrement = count > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Minus Button
        _StepperCircleButton(
          icon: Icons.remove_rounded,
          isEnabled: canDecrement,
          isGradient: false,
          onTap: canDecrement ? onDecrement : null,
        ),

        // Count with AnimatedSwitcher (slide + fade 180ms)
        Container(
          constraints: const BoxConstraints(minWidth: 36),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.25),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Text(
              isMasked ? '••' : '$count',
              key: ValueKey<String>(isMasked ? 'masked' : '$count'),
              style: AppTextStyles.stepperNumber,
            ),
          ),
        ),

        // Plus Button
        _StepperCircleButton(
          icon: Icons.add_rounded,
          isEnabled: true,
          isGradient: true,
          onTap: onIncrement,
        ),
      ],
    );
  }
}

class _StepperCircleButton extends StatefulWidget {
  final IconData icon;
  final bool isEnabled;
  final bool isGradient;
  final VoidCallback? onTap;

  const _StepperCircleButton({
    required this.icon,
    required this.isEnabled,
    required this.isGradient,
    this.onTap,
  });

  @override
  State<_StepperCircleButton> createState() => _StepperCircleButtonState();
}

class _StepperCircleButtonState extends State<_StepperCircleButton>
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
    if (widget.isEnabled && widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isEnabled && widget.onTap != null) {
      _controller.reverse();
      HapticFeedback.lightImpact();
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    if (widget.isEnabled && widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = !widget.isEnabled
        ? AppColors.textSecondary.withValues(alpha: 0.4)
        : widget.isGradient
            ? Colors.white
            : AppColors.textPrimary;

    Widget visualCircle = Container(
      width: AppDimensions.stepperButtonSize,
      height: AppDimensions.stepperButtonSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: !widget.isEnabled
            ? AppColors.surfaceMuted
            : widget.isGradient
                ? null
                : AppColors.surface,
        gradient: widget.isEnabled && widget.isGradient
            ? AppGradients.plusButtonGradient
            : null,
        boxShadow: widget.isEnabled
            ? (widget.isGradient
                ? AppShadows.primaryButtonGlow
                : AppShadows.stepperMinusShadow)
            : null,
      ),
      child: Center(
        child: Icon(
          widget.icon,
          size: 18,
          color: iconColor,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: SizedBox(
        width: AppDimensions.minTapTargetSize,
        height: AppDimensions.minTapTargetSize,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: Center(child: visualCircle),
        ),
      ),
    );
  }
}

