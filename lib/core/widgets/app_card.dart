import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final Border? border;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor,
    this.onTap,
    this.border,
    this.borderRadius = 16,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final defaultBorder = Border.all(
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
      width: 1,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? defaultBg,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ?? defaultBorder,
          boxShadow:
              boxShadow ??
              [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withAlpha(50)
                      : const Color(0xFF0F172A).withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        ),
        child: child,
      ),
    );
  }
}
