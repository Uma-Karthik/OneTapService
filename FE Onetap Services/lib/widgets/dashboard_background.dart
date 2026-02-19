import 'package:flutter/material.dart';
import '../utils/constants.dart';

class DashboardBackground extends StatelessWidget {
  final Widget child;

  const DashboardBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.dashboardGradient),
          ),
        ),
        // Subtle atmospheric glows for a premium, futuristic feel.
        Positioned(
          top: -160,
          right: -120,
          child: _orb(
            size: 360,
            colorA: AppColors.secondary.withValues(alpha: 0.22),
            colorB: Colors.transparent,
          ),
        ),
        Positioned(
          bottom: -170,
          left: -140,
          child: _orb(
            size: 390,
            colorA: AppColors.accent.withValues(alpha: 0.18),
            colorB: Colors.transparent,
          ),
        ),
        Positioned(
          top: 120,
          left: 40,
          child: _orb(
            size: 180,
            colorA: Colors.white.withValues(alpha: 0.08),
            colorB: Colors.transparent,
          ),
        ),
        child,
      ],
    );
  }

  Widget _orb({
    required double size,
    required Color colorA,
    required Color colorB,
  }) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [colorA, colorB]),
        ),
      ),
    );
  }
}
