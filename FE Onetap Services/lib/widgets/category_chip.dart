import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/service_model.dart';
import '../widgets/glass_morphism.dart';
import '../utils/constants.dart';

class CategoryChip extends StatelessWidget {
  final ServiceCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: GlassMorphism(
          borderRadius: BorderRadius.circular(22),
          opacity: isSelected ? 0.2 : 0.08,
          blur: 20,
          borderColor: isSelected
              ? AppColors.primary.withOpacity(0.4)
              : Colors.white.withOpacity(0.1),
          borderWidth: isSelected ? 1.5 : 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category.icon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  category.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.7),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: (index * 40).ms)
            .slideX(begin: 0.2, end: 0, duration: 400.ms, delay: (index * 40).ms),
      ),
    );
  }
}
