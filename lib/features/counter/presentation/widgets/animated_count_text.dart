import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Animated count-up for numbers and revenues (300 ms as specified in DESIGN.md)
class AnimatedRevenueText extends StatelessWidget {
  final int targetValue;
  final TextStyle style;
  final Duration duration;

  const AnimatedRevenueText({
    super.key,
    required this.targetValue,
    required this.style,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<num>(
      tween: Tween<num>(begin: 0, end: targetValue),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          CurrencyFormatter.formatInt(value.round()),
          style: style,
        );
      },
    );
  }
}

