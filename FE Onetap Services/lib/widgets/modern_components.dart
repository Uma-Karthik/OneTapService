import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import 'glass_morphism.dart';
import 'hover_widget.dart';

/// Clean iOS-style App Logo
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 1.5,
      height: size * 1.5,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF0F0F0)],
        ),
        borderRadius: BorderRadius.circular(size * 0.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.home_repair_service_rounded,
          size: size,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Modern Button — iOS Pill Style with Glass Effect
class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isOutlined;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isOutlined = false,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return HoverWidget(
      onTap: isLoading ? null : onPressed,
      hoverScale: 1.03,
      child: GlassMorphism(
        borderRadius: BorderRadius.circular(24),
        blur: AppColors.glassBlur,
        opacity: isPrimary ? 0.12 : 0.07,
        showGlow: isPrimary,
        glowColor: AppColors.primary,
        borderColor: isPrimary
            ? AppColors.glassHighlight.withValues(alpha: 0.42)
            : AppColors.glassBorder.withValues(alpha: 0.8),
        child: Container(
          width: width,
          height: 58,
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: Colors.white),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Modern Text Field — iOS Glass Style
class ModernTextField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const ModernTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return GlassMorphism(
      borderRadius: BorderRadius.circular(20),
      blur: AppColors.glassBlur,
      opacity: 0.07,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.4),
            fontSize: 16,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.white.withOpacity(0.6), size: 22)
              : null,
          errorStyle: GoogleFonts.inter(color: Colors.red.shade300),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          filled: false,
        ),
      ),
    );
  }
}

/// Modern Card — surface container with rounded corners and shadow
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ModernCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding is EdgeInsets
        ? padding as EdgeInsets
        : const EdgeInsets.all(16);
    return LiquidGlassCard(
      padding: resolvedPadding,
      borderRadius: BorderRadius.circular(24),
      child: child,
    );
  }
}

/// Modern Chip — selectable filter/tag chip
class ModernChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const ModernChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.26)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.glassHighlight.withValues(alpha: 0.7)
                : AppColors.glassBorder.withValues(alpha: 0.75),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Top Nav Bar Logo — glassmorphism pill with OneTap icon, centered in the app bar area
class NavBarLogo extends StatelessWidget {
  const NavBarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassMorphism(
      borderRadius: BorderRadius.circular(20),
      opacity: 0.12,
      blur: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon mark — recreating the OneTap logo icon
            _OneTapIconMark(size: 28),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OneTap',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
                Text(
                  'SERVICES',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painted OneTap icon mark (house + 1 + tools)
class _OneTapIconMark extends StatelessWidget {
  final double size;
  const _OneTapIconMark({this.size = 32});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _OneTapIconPainter());
  }
}

class _OneTapIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // House outline
    final housePaint = Paint()
      ..color =
          const Color(0xFF7ECEC4) // teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final housePath = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..lineTo(w * 0.92, h * 0.42)
      ..lineTo(w * 0.82, h * 0.42)
      ..lineTo(w * 0.82, h * 0.88)
      ..lineTo(w * 0.18, h * 0.88)
      ..lineTo(w * 0.18, h * 0.42)
      ..lineTo(w * 0.08, h * 0.42)
      ..close();
    canvas.drawPath(housePath, housePaint);

    // "1" in center
    final textPainter = TextPainter(
      text: TextSpan(
        text: '1',
        style: TextStyle(
          color: const Color(0xFFE8A87C), // peach
          fontSize: h * 0.38,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(w * 0.5 - textPainter.width / 2, h * 0.44),
    );

    // Wrench (top-left diagonal)
    final wrenchPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.18, h * 0.18),
      Offset(w * 0.42, h * 0.38),
      wrenchPaint,
    );

    // Water drop (bottom center)
    final dropPaint = Paint()
      ..color = const Color(0xFF7ECEC4)
      ..style = PaintingStyle.fill;
    final dropPath = Path()
      ..moveTo(w * 0.5, h * 0.72)
      ..quadraticBezierTo(w * 0.42, h * 0.82, w * 0.5, h * 0.92)
      ..quadraticBezierTo(w * 0.58, h * 0.82, w * 0.5, h * 0.72);
    canvas.drawPath(dropPath, dropPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
