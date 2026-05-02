import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCardWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurStrength;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;

  const GlassCardWidget({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blurStrength = 12,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.onTap,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow:
            shadows ??
            [
              BoxShadow(
                color: Colors.black.withAlpha(64),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              splashColor: const Color(0x1A6C63FF),
              highlightColor: const Color(0x0D6C63FF),
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                padding: padding ?? const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: backgroundColor ?? const Color(0x0DFFFFFF),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: borderColor ?? const Color(0x26FFFFFF),
                    width: borderWidth,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
