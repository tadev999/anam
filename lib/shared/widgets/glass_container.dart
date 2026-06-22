import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double radius;
  final double opacity;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.radius = 24.0,
    this.opacity = 0.08,
    this.blur = 20.0,
    this.padding,
    this.margin,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(20),
          margin: margin,
          decoration: BoxDecoration(
            color: ZenTheme.creamWhite.withOpacity(opacity),
            borderRadius: BorderRadius.circular(radius),
            border: border ??
                Border.all(
                  color: ZenTheme.creamWhite.withOpacity(0.08),
                  width: 1.0,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}
