import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'glass_morphism.dart';

class LogoHeaderBar extends StatelessWidget {
  const LogoHeaderBar({super.key, this.logoWidth = 104});

  final double logoWidth;

  @override
  Widget build(BuildContext context) {
    return GlassMorphism(
      borderRadius: BorderRadius.circular(24),
      opacity: 0.12,
      blur: 40,
      child: SizedBox(
        height: 64,
        child: Center(
          child: Image.asset('assets/images/logo.png', width: logoWidth)
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(
                duration: 500.ms,
                begin: const Offset(0.96, 0.96),
                end: const Offset(1, 1),
              ),
        ),
      ),
    );
  }
}
