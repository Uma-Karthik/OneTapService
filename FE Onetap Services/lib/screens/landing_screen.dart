import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../widgets/glass_morphism.dart';
import '../widgets/hover_widget.dart';
import '../widgets/modern_components.dart';
import 'auth/login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Liquid Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.dashboardGradient,
              ),
            ),
          ),

          // Animated Orbs
          AnimatedBuilder(
            animation: _orbController,
            builder: (context, _) {
              final t = _orbController.value;
              return Stack(
                children: [
                  Positioned(
                    top: -100 + t * 50,
                    left: -50 + t * 30,
                    child: _buildOrb(
                      size: size.width * 0.9,
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  Positioned(
                    bottom: -150 + t * 60,
                    right: -100 + t * 40,
                    child: _buildOrb(
                      size: size.width * 1.1,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              );
            },
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),

                  // Logo
                  Image.asset('assets/images/logo.png', width: 160)
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                      ),

                  const SizedBox(height: 40),

                  // Hero Text
                  Column(
                        children: [
                          Text(
                            'OneTap Services',
                            style: GoogleFonts.inter(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -2,
                              height: 1,
                            ),
                          ),
                          Text(
                            'Simplified.',
                            style: GoogleFonts.inter(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withOpacity(0.5),
                              letterSpacing: -2,
                              height: 1,
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 200.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  Text(
                    'Book trusted professionals for all your home needs with a single tap.',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 800.ms, delay: 400.ms),

                  const Spacer(),

                  // CTA Card
                  GlassMorphism(
                        borderRadius: BorderRadius.circular(32),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              ModernButton(
                                text: 'Get Started',
                                isPrimary: true,
                                width: double.infinity,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              HoverWidget(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Already have an account? Sign In',
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 600.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
