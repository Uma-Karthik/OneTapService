import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/provider_model.dart';
import '../models/service_model.dart';
import '../services/provider_service.dart';
import '../utils/constants.dart';
import '../utils/currency.dart';
import '../widgets/dashboard_background.dart';
import '../widgets/glass_morphism.dart';
import '../widgets/modern_components.dart';
import 'customer/book_service_screen.dart';
import 'customer/provider_detail_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;
  final Provider? provider;

  const ServiceDetailScreen({super.key, required this.service, this.provider});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isFavorite = false;
  Provider? _provider;
  bool _isLoadingProvider = false;

  @override
  void initState() {
    super.initState();
    _provider = widget.provider;
    if (_provider == null && widget.service.providerId.isNotEmpty) {
      _loadProvider();
    }
  }

  Future<void> _loadProvider() async {
    setState(() => _isLoadingProvider = true);
    final provider = await ProviderService().getProviderById(
      widget.service.providerId,
    );
    if (!mounted) return;
    setState(() {
      _provider = provider;
      _isLoadingProvider = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canBook =
        _provider != null &&
        _provider!.isAvailable &&
        widget.service.isAvailable;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: DashboardBackground(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: () => setState(() => _isFavorite = !_isFavorite),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _isFavorite ? Colors.red : Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Center(
                      child:
                          Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 36,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                widget.service.icon,
                                style: const TextStyle(fontSize: 94),
                              ),
                            ),
                          ).animate().scale(
                            duration: 700.ms,
                            curve: Curves.easeOutBack,
                          ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                              widget.service.name,
                              style: GoogleFonts.inter(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1.3,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideX(begin: -0.1, end: 0),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber.shade400,
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.service.rating.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '(${widget.service.reviews} reviews)',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                        const SizedBox(height: 24),
                        _buildProviderCard(),
                        const SizedBox(height: 24),
                        Text(
                          'Service Description',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                        const SizedBox(height: 10),
                        Text(
                          widget.service.description,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.6,
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: 250.ms),
                        const SizedBox(height: 24),
                        Text(
                          'Recent Reviews',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
                        const SizedBox(height: 12),
                        ..._buildReviewCards(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GlassMorphism(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                opacity: 0.15,
                blur: 40,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.65),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.inr(widget.service.price),
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: ModernButton(
                            text: canBook ? 'Book Now' : 'Unavailable',
                            isPrimary: true,
                            onPressed: canBook
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookServiceScreen(
                                          provider: _provider!,
                                          service: widget.service,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard() {
    if (_isLoadingProvider) {
      return const Center(child: CircularProgressIndicator());
    }

    final provider = _provider;
    if (provider == null) {
      return GlassMorphism(
        borderRadius: BorderRadius.circular(16),
        opacity: 0.08,
        blur: 20,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Provider details are unavailable for this service.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return GlassMorphism(
      borderRadius: BorderRadius.circular(16),
      opacity: 0.1,
      blur: 20,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.companyName,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              provider.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.78),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  provider.isAvailable ? Icons.check_circle : Icons.cancel,
                  color: provider.isAvailable
                      ? AppColors.success
                      : AppColors.error,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  provider.isAvailable ? 'Available' : 'Currently Busy',
                  style: GoogleFonts.inter(
                    color: provider.isAvailable
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProviderDetailScreen(provider: provider),
                      ),
                    );
                  },
                  child: const Text('View Provider'),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 150.ms);
  }

  List<Widget> _buildReviewCards() {
    if (widget.service.reviews <= 0) {
      return [
        GlassMorphism(
          borderRadius: BorderRadius.circular(14),
          opacity: 0.08,
          blur: 20,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              'No public reviews yet. Be the first to book and rate this service.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ),
      ];
    }

    final count = min(widget.service.reviews, 3);
    return List.generate(count, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassMorphism(
          borderRadius: BorderRadius.circular(14),
          opacity: 0.08,
          blur: 20,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (star) => Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: star < widget.service.rating.round()
                            ? Colors.amber
                            : Colors.white24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Customer ${index + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Great service quality and clear communication from the provider.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
