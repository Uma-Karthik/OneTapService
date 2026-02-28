import '../models/user_model.dart';
import '../models/provider_model.dart';
import '../models/service_model.dart';
import '../models/booking_model.dart';

class MockData {
  // Mock Users (Customers)
  static final List<User> mockCustomers = [
    User(
      id: 'cust_001',
      name: 'John Doe',
      email: 'john@example.com',
      phone: '+1234567890',
      address: '123 Main St, City, State 12345',
      role: UserRole.customer,
    ),
    User(
      id: 'cust_002',
      name: 'Jane Smith',
      email: 'jane@example.com',
      phone: '+1234567891',
      address: '456 Oak Ave, City, State 12345',
      role: UserRole.customer,
    ),
    User(
      id: 'cust_003',
      name: 'Mike Johnson',
      email: 'mike@example.com',
      phone: '+1234567892',
      address: '789 Pine Rd, City, State 12345',
      role: UserRole.customer,
    ),
  ];

  // Mock Users (Providers)
  static final List<User> mockProviderUsers = [
    User(
      id: 'prov_user_001',
      name: 'Sarah Williams',
      email: 'sarah@cleanpro.com',
      phone: '+1234567893',
      address: '100 Business Blvd, City, State 12345',
      role: UserRole.provider,
    ),
    User(
      id: 'prov_user_002',
      name: 'Tom Anderson',
      email: 'tom@fixitfast.com',
      phone: '+1234567894',
      address: '200 Service St, City, State 12345',
      role: UserRole.provider,
    ),
    User(
      id: 'prov_user_003',
      name: 'Lisa Brown',
      email: 'lisa@sparkelectric.com',
      phone: '+1234567895',
      address: '300 Tech Ave, City, State 12345',
      role: UserRole.provider,
    ),
    User(
      id: 'prov_user_004',
      name: 'David Miller',
      email: 'david@colorworks.com',
      phone: '+1234567896',
      address: '400 Paint Ln, City, State 12345',
      role: UserRole.provider,
    ),
    User(
      id: 'prov_user_005',
      name: 'Emily Davis',
      email: 'emily@woodcraft.com',
      phone: '+1234567897',
      address: '500 Carpenter Rd, City, State 12345',
      role: UserRole.provider,
    ),
    User(
      id: 'prov_user_006',
      name: 'Robert Wilson',
      email: 'robert@coolairpro.com',
      phone: '+1234567898',
      address: '600 HVAC Way, City, State 12345',
      role: UserRole.provider,
    ),
  ];

  // Mock Providers
  static final List<Provider> mockProviders = [
    Provider(
      id: 'prov_001',
      userId: 'prov_user_001',
      companyName: 'CleanPro Services',
      description:
          'Professional cleaning services with 10+ years of experience. We ensure your home sparkles!',
      serviceIds: ['serv_001'],
      rating: 4.8,
      reviewCount: 247,
      isAvailable: true,
      serviceAreas: ['Downtown', 'Suburbs', 'North District'],
      businessHours: '8 AM - 8 PM',
    ),
    Provider(
      id: 'prov_002',
      userId: 'prov_user_002',
      companyName: 'FixIt Fast Plumbing',
      description:
          'Licensed plumbers available 24/7 for all your plumbing emergencies and installations.',
      serviceIds: ['serv_002'],
      rating: 4.9,
      reviewCount: 189,
      isAvailable: true,
      serviceAreas: ['All Districts'],
      businessHours: '24/7',
    ),
    Provider(
      id: 'prov_003',
      userId: 'prov_user_003',
      companyName: 'Spark Electric Solutions',
      description:
          'Certified electricians providing safe and reliable electrical services for homes and businesses.',
      serviceIds: ['serv_003'],
      rating: 4.7,
      reviewCount: 132,
      isAvailable: true,
      serviceAreas: ['Downtown', 'East Side', 'West Side'],
      businessHours: '7 AM - 9 PM',
    ),
    Provider(
      id: 'prov_004',
      userId: 'prov_user_004',
      companyName: 'ColorWorks Painting',
      description:
          'Transform your space with our expert painting services. Quality workmanship guaranteed!',
      serviceIds: ['serv_004'],
      rating: 4.6,
      reviewCount: 98,
      isAvailable: true,
      serviceAreas: ['Downtown', 'Suburbs'],
      businessHours: '9 AM - 6 PM',
    ),
    Provider(
      id: 'prov_005',
      userId: 'prov_user_005',
      companyName: 'WoodCraft Carpentry',
      description:
          'Expert carpenters for all your furniture assembly and custom woodwork needs.',
      serviceIds: ['serv_005'],
      rating: 4.8,
      reviewCount: 215,
      isAvailable: true,
      serviceAreas: ['All Districts'],
      businessHours: '8 AM - 7 PM',
    ),
    Provider(
      id: 'prov_006',
      userId: 'prov_user_006',
      companyName: 'CoolAir Pro',
      description:
          'Complete AC maintenance and repair services. Keep your home comfortable year-round!',
      serviceIds: ['serv_006'],
      rating: 4.9,
      reviewCount: 178,
      isAvailable: true,
      serviceAreas: ['Downtown', 'North District', 'South District'],
      businessHours: '7 AM - 10 PM',
    ),
  ];

  // Mock Services (updated with providerId)
  static final List<ServiceModel> mockServices = [
    ServiceModel(
      id: 'serv_001',
      name: 'Deep House Cleaning',
      description: 'Professional deep cleaning service for your entire home',
      icon: '🧹',
      price: 299.99,
      rating: 4.8,
      reviews: 1247,
      imageUrl:
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
      features: [
        'All rooms cleaned',
        'Bathroom sanitization',
        'Kitchen deep clean',
        'Window cleaning',
        'Dusting & vacuuming',
      ],
      category: 'Cleaning',
      providerId: 'prov_001',
      durationMinutes: 180,
    ),
    ServiceModel(
      id: 'serv_002',
      name: 'Plumbing Repair',
      description: 'Expert plumbers for all your plumbing needs',
      icon: '🔧',
      price: 199.99,
      rating: 4.9,
      reviews: 892,
      imageUrl:
          'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=800',
      features: [
        'Leak repair',
        'Pipe installation',
        'Drain cleaning',
        'Fixture installation',
        'Emergency service',
      ],
      category: 'Plumbing',
      providerId: 'prov_002',
      durationMinutes: 120,
    ),
    ServiceModel(
      id: 'serv_003',
      name: 'Electrical Installation',
      description: 'Licensed electricians for safe electrical work',
      icon: '⚡',
      price: 249.99,
      rating: 4.7,
      reviews: 654,
      imageUrl:
          'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800',
      features: [
        'Wiring installation',
        'Panel upgrades',
        'Outlet installation',
        'Light fixture setup',
        'Safety inspection',
      ],
      category: 'Electrical',
      providerId: 'prov_003',
      durationMinutes: 90,
    ),
    ServiceModel(
      id: 'serv_004',
      name: 'Interior Painting',
      description: 'Professional painting service for your home',
      icon: '🎨',
      price: 399.99,
      rating: 4.6,
      reviews: 523,
      imageUrl:
          'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=800',
      features: [
        'Wall preparation',
        'Primer application',
        '2 coats of paint',
        'Cleanup included',
        'Color consultation',
      ],
      category: 'Painting',
      providerId: 'prov_004',
      durationMinutes: 240,
    ),
    ServiceModel(
      id: 'serv_005',
      name: 'Furniture Assembly',
      description: 'Expert carpenters for furniture assembly',
      icon: '🪚',
      price: 149.99,
      rating: 4.8,
      reviews: 1123,
      imageUrl:
          'https://images.unsplash.com/photo-1581539250439-c96689b516dd?w=800',
      features: [
        'Furniture assembly',
        'Custom installations',
        'Cabinet installation',
        'Shelf mounting',
        'Tool-free service',
      ],
      category: 'Carpentry',
      providerId: 'prov_005',
      durationMinutes: 60,
    ),
    ServiceModel(
      id: 'serv_006',
      name: 'AC Service & Repair',
      description: 'Complete AC maintenance and repair service',
      icon: '❄️',
      price: 179.99,
      rating: 4.9,
      reviews: 987,
      imageUrl:
          'https://images.unsplash.com/photo-1631542770506-0161f684135a?w=800',
      features: [
        'AC cleaning',
        'Gas refill',
        'Filter replacement',
        'Repair service',
        'Annual maintenance',
      ],
      category: 'AC Repair',
      providerId: 'prov_006',
      durationMinutes: 90,
    ),
  ];

  // Bookings are now stored in SQLite. No mock bookings.
  static final List<Booking> mockBookings = [];

  // Helper method to get all users (kept for compatibility)
  static List<User> getAllUsers() {
    return [...mockCustomers, ...mockProviderUsers];
  }
}
