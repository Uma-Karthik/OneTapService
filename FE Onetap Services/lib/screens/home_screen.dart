import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_morphism.dart';
import '../widgets/category_chip.dart';
import '../widgets/service_card.dart';
import '../models/service_model.dart';
import '../utils/constants.dart';
import 'service_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<ServiceModel> get filteredServices {
    if (selectedCategory == 'All') {
      return AppData.services;
    }
    return AppData.services
        .where((service) => service.category == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
          // Animated Liquid Blobs
          Positioned(
            top: -100,
            right: -50,
            child:
                Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .scale(
                      duration: 5.seconds,
                      begin: const Offset(1, 1),
                      end: const Offset(1.5, 1.5),
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scale(
                      duration: 5.seconds,
                      begin: const Offset(1.5, 1.5),
                      end: const Offset(1, 1),
                      curve: Curves.easeInOut,
                    ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child:
                Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .scale(
                      duration: 7.seconds,
                      begin: const Offset(1.2, 1.2),
                      end: const Offset(0.8, 0.8),
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scale(
                      duration: 7.seconds,
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.2, 1.2),
                      curve: Curves.easeInOut,
                    ),
          ),

          // Main Content
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child:
                      Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Good Morning',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          'Find Services',
                                          style: GoogleFonts.inter(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: -1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.person_outline_rounded,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: -0.1, end: 0),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: GlassMorphism(
                      borderRadius: BorderRadius.circular(24),
                      opacity: 0.1,
                      blur: 30,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search for home services...',
                          hintStyle: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.white.withOpacity(0.7),
                            size: 24,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 20,
                          ),
                        ),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                  ),
                ),

                // Categories
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Text(
                          'Categories',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 65,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: AppData.categories.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              final isSelected = selectedCategory == 'All';
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: CategoryChip(
                                  category: ServiceCategory(
                                    id: 'all',
                                    name: 'All',
                                    icon: '✨',
                                    color: AppColors.primary,
                                  ),
                                  isSelected: isSelected,
                                  onTap: () =>
                                      setState(() => selectedCategory = 'All'),
                                  index: index,
                                ),
                              );
                            }
                            final category = AppData.categories[index - 1];
                            final isSelected =
                                selectedCategory == category.name;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: CategoryChip(
                                category: category,
                                isSelected: isSelected,
                                onTap: () => setState(
                                  () => selectedCategory = category.name,
                                ),
                                index: index,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                ),

                // Services List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final service = filteredServices[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ServiceCard(
                          service: service,
                          index: index,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ServiceDetailScreen(service: service),
                              ),
                            );
                          },
                        ),
                      );
                    }, childCount: filteredServices.length),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
