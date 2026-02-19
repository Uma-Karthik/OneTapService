import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Clean Glassmorphism — BackdropFilter based
class GlassMorphism extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final List<Color>? gradientColors;
  final bool showGlow;
  final Color? glowColor;
  final bool useInnerShadow;

  const GlassMorphism({
    super.key,
    required this.child,
    this.blur = AppColors.glassBlur,
    this.opacity = AppColors.glassOpacity,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = AppColors.glassBorderWidth,
    this.gradientColors,
    this.showGlow = false,
    this.glowColor,
    this.useInnerShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(30);
    return Container(
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: [
          // Soft outer shadow for depth
          BoxShadow(
            color: const Color(0xFF040712).withValues(alpha: 0.34),
            blurRadius: 30,
            spreadRadius: -8,
            offset: const Offset(0, 16),
          ),
          if (showGlow)
            BoxShadow(
              color: (glowColor ?? AppColors.primary).withValues(alpha: 0.22),
              blurRadius: 26,
              spreadRadius: -1,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: br,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    gradientColors ??
                    [
                      const Color(0xFFFFFFFF).withValues(alpha: opacity),
                      const Color(0xFFFFFFFF).withValues(alpha: opacity * 0.24),
                    ],
              ),
              border: Border.all(
                color: borderColor ?? AppColors.glassBorder,
                width: borderWidth,
              ),
            ),
            child: Stack(
              children: [
                // Inner glow / Bevel effect
                if (useInnerShadow)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: br,
                        border: Border.all(
                          color: AppColors.glassHighlight.withValues(
                            alpha: 0.34,
                          ),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                // Top highlighted edge (Glow Edge)
                Positioned(
                  top: 0,
                  left: 30,
                  right: 30,
                  child: Container(
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFFFFF).withValues(alpha: 0.0),
                          const Color(0xFFFFFFFF).withValues(alpha: 0.46),
                          const Color(0xFFFFFFFF).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Liquid Glass Card - GlassMorphism container with padding support
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final List<Color>? gradientColors;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.blur = AppColors.glassBlur,
    this.opacity = AppColors.glassOpacity,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = AppColors.glassBorderWidth,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return GlassMorphism(
      blur: blur,
      opacity: opacity,
      borderRadius: borderRadius ?? BorderRadius.circular(28),
      borderColor: borderColor,
      borderWidth: borderWidth,
      gradientColors: gradientColors,
      child: Padding(padding: padding, child: child),
    );
  }
}
