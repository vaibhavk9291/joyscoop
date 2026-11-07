import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shimmer skeleton in blush tones (#FFE3EA / #FFF1F4), strictly as specified in DESIGN.md
class BlushShimmer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const BlushShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<BlushShimmer> createState() => _BlushShimmerState();
}

class _BlushShimmerState extends State<BlushShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
              colors: const [
                AppColors.bgTop,
                AppColors.bgMid,
                AppColors.bgTop,
              ],
            ),
          ),
        );
      },
    );
  }
}

