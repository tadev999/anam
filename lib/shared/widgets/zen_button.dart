import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class ZenButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isGlass;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double borderRadius;

  const ZenButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isSecondary = false,
    this.isGlass = false,
    this.icon,
    this.isLoading = false,
    this.height = 52,
    this.borderRadius = 16,
  });

  const ZenButton.glass({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height = 52,
    this.borderRadius = 16,
  })  : isSecondary = false,
        isGlass = true;

  @override
  State<ZenButton> createState() => _ZenButtonState();
}

class _ZenButtonState extends State<ZenButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    Color contentColor;
    if (widget.isGlass) {
      contentColor = AppColors.textPrimary;
    } else if (widget.isSecondary) {
      contentColor = AppColors.primary;
    } else {
      contentColor = Colors.white;
    }

    Widget buttonBody = Container(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: widget.isGlass
          ? BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : widget.isSecondary
              ? BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.4,
                  ),
                )
              : BoxDecoration(
                  gradient: isDisabled
                      ? null
                      : const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: isDisabled ? AppColors.surfaceElevated : null,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: isDisabled
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
      child: widget.isLoading
          ? Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(contentColor),
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: contentColor,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: contentColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
    );

    if (widget.isGlass) {
      buttonBody = ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: buttonBody,
        ),
      );
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: buttonBody,
      ),
    );
  }
}
