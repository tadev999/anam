import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ZenButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isGlass;
  final IconData? icon;
  final bool isLoading;

  const ZenButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isSecondary = false,
    this.isGlass = false,
    this.icon,
    this.isLoading = false,
  });

  const ZenButton.glass({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  })  : isSecondary = false,
        isGlass = true;

  @override
  State<ZenButton> createState() => _ZenButtonState();
}

class _ZenButtonState extends State<ZenButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    Widget buttonBody = Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: widget.isGlass
          ? BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1.0,
              ),
            )
          : widget.isSecondary
              ? BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: ZenTheme.sageGreen.withOpacity(0.5),
                    width: 1.5,
                  ),
                )
              : BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ZenTheme.sageGreen,
                      ZenTheme.sageGreen.withBlue(160).withGreen(180),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: ZenTheme.sageGreen.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
      child: widget.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(ZenTheme.creamWhite),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: widget.isGlass
                        ? ZenTheme.creamWhite
                        : (widget.isSecondary ? ZenTheme.sageGreen : ZenTheme.slateDark),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: widget.isGlass
                              ? ZenTheme.creamWhite
                              : (widget.isSecondary ? ZenTheme.sageGreen : ZenTheme.slateDark),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
    );

    if (widget.isGlass) {
      buttonBody = ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: buttonBody,
        ),
      );
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
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
