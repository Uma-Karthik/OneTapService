import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/booking_model.dart';
import '../../models/provider_model.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/provider_service.dart';
import '../../utils/constants.dart';
import '../../widgets/dashboard_background.dart';
import '../../widgets/hover_widget.dart';
import '../../widgets/glass_morphism.dart';
import '../../widgets/logo_header_bar.dart';
import 'manage_services_screen.dart';
import 'provider_bookings_screen.dart';
import 'provider_profile_screen.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  // 0=Services, 1=Bookings, 2=Profile
  int _selectedIndex = 0;
  Provider? _provider;
  List<Booking> _recentBookings = [];
  int _pendingCount = 0;
  int _todayCount = 0;

  bool _hasNewBooking = false;
  StreamSubscription? _bookingSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkNewBookings();

    // Listen for real-time updates
    _bookingSubscription = BookingService().providerBookingsStream.listen((_) {
      _loadData();
      _checkNewBookings();
    });
  }

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkNewBookings() async {
    final bookings = await BookingService().getProviderBookings();
    final pendingBookings = bookings
        .where((b) => b.status == BookingStatus.pending)
        .toList();

    if (pendingBookings.isNotEmpty) {
      if (mounted) {
        setState(() => _hasNewBooking = true);
        // Hide after 3 seconds
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() => _hasNewBooking = false);
          }
        });
      }
    }
  }

  Future<void> _loadData() async {
    final provider = await ProviderService().getCurrentProvider();
    final bookings = await BookingService().getProviderBookings();

    if (!mounted) return;
    setState(() {
      _provider = provider;
      _recentBookings = bookings.take(3).toList();
      _pendingCount = bookings
          .where((b) => b.status == BookingStatus.pending)
          .length;
      _todayCount = bookings
          .where(
            (b) =>
                b.dateTime.year == DateTime.now().year &&
                b.dateTime.month == DateTime.now().month &&
                b.dateTime.day == DateTime.now().day,
          )
          .length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    Widget currentTab;
    switch (_selectedIndex) {
      case 0:
        currentTab = _buildHomeTab(user);
        break;
      case 1:
        currentTab = const ProviderBookingsScreen();
        break;
      case 2:
      default:
        currentTab = const ProviderProfileScreen();
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          DashboardBackground(child: currentTab),
          // New Booking Notification
          if (_hasNewBooking)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              child:
                  GlassMorphism(
                        borderRadius: BorderRadius.circular(20),
                        opacity: 0.15,
                        blur: 25,
                        showGlow: true,
                        glowColor: AppColors.primary,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_active_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'New Booking Alert!',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'You have received a new service request.',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .slideY(
                        begin: -1,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(),
            ),
        ],
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return GlassMorphism(
      borderRadius: BorderRadius.circular(30),
      opacity: 0.1,
      blur: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.dashboard_rounded, 'Dashboard'),
            _buildNavItem(1, Icons.calendar_today_rounded, 'Bookings'),
            _buildNavItem(2, Icons.person_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return HoverWidget(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 0) _loadData();
      },
      hoverScale: 1.08,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.white.withOpacity(0.6),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(user) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          // Extra bottom padding so FAB + navbar don't overlap content
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 220),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LogoHeaderBar(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Business Dashboard',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        _provider?.companyName ?? user?.name ?? 'Provider',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0),

              const SizedBox(height: 32),

              // Quick-action card → navigate to ManageServicesScreen
              GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageServicesScreen(),
                        ),
                      );
                    },
                    child: GlassMorphism(
                      borderRadius: BorderRadius.circular(20),
                      opacity: 0.12,
                      blur: 20,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.add_circle_outline_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add / Manage Services',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Post services customers can book',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white.withOpacity(0.4),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Stats
              Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Pending',
                          _pendingCount.toString(),
                          Icons.schedule_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Today',
                          _todayCount.toString(),
                          Icons.today_rounded,
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 32),

              Text(
                'Recent Requests',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

              const SizedBox(height: 16),

              if (_recentBookings.isEmpty)
                _buildEmptyState()
              else
                ..._recentBookings.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildBookingCard(entry.value, entry.key),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return GlassMorphism(
      borderRadius: BorderRadius.circular(24),
      opacity: 0.1,
      blur: 30,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.6), size: 24),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, int index) {
    return GlassMorphism(
      borderRadius: BorderRadius.circular(24),
      opacity: 0.08,
      blur: 20,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.customerName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    booking.serviceName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                booking.status.name.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _getStatusColor(booking.status),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: (index * 100).ms);
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.accepted:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
        return Colors.red;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.calendar_today_rounded,
            size: 64,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No recent requests',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add services so customers can book you!',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
