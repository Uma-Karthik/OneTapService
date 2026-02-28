import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/provider_model.dart';
import '../landing_screen.dart';
import '../../services/auth_service.dart';
import '../../services/provider_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_morphism.dart';
import '../../widgets/logo_header_bar.dart';
import '../../widgets/loading_overlay.dart';
import 'manage_services_screen.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  Provider? _provider;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = AuthService().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;

      final provider = await ProviderService().getCurrentProvider();
      if (provider != null && mounted) {
        setState(() => _provider = provider);
        _companyNameController.text = provider.companyName;
        _descriptionController.text = provider.description;
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = AuthService().currentUser;
    if (user != null && _provider != null) {
      // Update user info
      final updatedUser = user.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      final userSuccess = await AuthService().updateProfile(updatedUser);

      // Update provider info
      final updatedProvider = _provider!.copyWith(
        companyName: _companyNameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      final providerSuccess = await ProviderService().updateProvider(
        updatedProvider,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (userSuccess && providerSuccess) {
          setState(() {
            _isEditing = false;
            _provider = updatedProvider;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleAvailability() async {
    if (_provider != null) {
      final updatedProvider = _provider!.copyWith(
        isAvailable: !_provider!.isAvailable,
      );

      final success = await ProviderService().updateProvider(updatedProvider);

      if (success && mounted) {
        setState(() => _provider = updatedProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedProvider.isAvailable
                  ? 'You are now available'
                  : 'You are now unavailable',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LogoHeaderBar(),
                    const SizedBox(height: 20),
                    // Header
                    Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Profile',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                if (!_isEditing)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: AppColors.primary,
                                    ),
                                    onPressed: () =>
                                        setState(() => _isEditing = true),
                                  ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    await AuthService().logout();
                                    if (mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LandingScreen(),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.textPrimary.withOpacity(
                                        0.1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.logout_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.2, end: 0),

                    const SizedBox(height: 32),

                    // Business Logo
                    Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                  AppColors.accent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.business,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .scale(
                          duration: 600.ms,
                          delay: 200.ms,
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.0, 1.0),
                        ),

                    const SizedBox(height: 32),

                    // Availability Toggle
                    if (_provider != null)
                      GlassMorphism(
                            borderRadius: BorderRadius.circular(16),
                            opacity: 0.1,
                            blur: 20,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Availability Status',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _provider!.isAvailable
                                            ? 'Accepting new bookings'
                                            : 'Not accepting bookings',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: _provider!.isAvailable,
                                    onChanged: (_) => _toggleAvailability(),
                                    activeColor: AppColors.success,
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 400.ms)
                          .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 24),

                    // Personal Info
                    Text(
                      'Personal Information',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 500.ms),

                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Full Name',
                      hint: 'Enter your name',
                      icon: Icons.person_outline,
                      controller: _nameController,
                      validator: (value) => Validators.required(value, 'Name'),
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

                    const SizedBox(height: 20),

                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ).animate().fadeIn(duration: 600.ms, delay: 700.ms),

                    const SizedBox(height: 20),

                    CustomTextField(
                      label: 'Phone',
                      hint: 'Enter your phone number',
                      icon: Icons.phone_outlined,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone,
                    ).animate().fadeIn(duration: 600.ms, delay: 800.ms),

                    const SizedBox(height: 32),

                    // Business Info
                    Text(
                      'Business Information',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 900.ms),

                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Company Name',
                      hint: 'Enter company name',
                      icon: Icons.business,
                      controller: _companyNameController,
                      validator: (value) =>
                          Validators.required(value, 'Company name'),
                    ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),

                    const SizedBox(height: 20),

                    CustomTextField(
                      label: 'Description',
                      hint: 'Describe your business',
                      icon: Icons.description,
                      controller: _descriptionController,
                      maxLines: 3,
                      validator: (value) =>
                          Validators.required(value, 'Description'),
                    ).animate().fadeIn(duration: 600.ms, delay: 1100.ms),

                    const SizedBox(height: 32),

                    // Business Stats
                    if (_provider != null)
                      GlassMorphism(
                            borderRadius: BorderRadius.circular(16),
                            opacity: 0.1,
                            blur: 20,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Business Statistics',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildStatRow(
                                    'Rating',
                                    '${_provider!.rating.toStringAsFixed(1)} ⭐',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStatRow(
                                    'Total Reviews',
                                    '${_provider!.reviewCount}',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStatRow(
                                    'Services Offered',
                                    '${_provider!.serviceIds.length}',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStatRow(
                                    'Service Areas',
                                    '${_provider!.serviceAreas.length}',
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 1200.ms)
                          .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 32),

                    // Manage Services Section
                    Text(
                      'Service Management',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 1300.ms),

                    const SizedBox(height: 16),

                    GlassMorphism(
                      borderRadius: BorderRadius.circular(16),
                      opacity: 0.1,
                      blur: 20,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Manage Your Services',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Add, edit, or delete services',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ManageServicesScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    'Add Service',
                                    Icons.add_circle_outline,
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AddEditServiceScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(
                                    'View All',
                                    Icons.visibility_outlined,
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ManageServicesScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 1400.ms)
                    .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 32),

                    // Save/Cancel Buttons
                    if (_isEditing) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _loadData();
                                setState(() => _isEditing = false);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.3,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Save Changes',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) const LoadingOverlay(message: 'Updating profile...'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        foregroundColor: AppColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
