import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/booking_model.dart';
import '../models/service_model.dart';
import '../models/provider_model.dart';
import 'auth_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final String _baseUrl = ApiConfig.baseUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService().token}',
      };

  // ─── Services ──────────────────────────────────────────────────────────────

  Future<List<ServiceModel>> getAllServices({String? query, String? category}) async {
    try {
      final uri = Uri.parse('$_baseUrl/services/all').replace(
        queryParameters: {
          if (query != null) 'query': query,
          if (category != null) 'category': category,
        },
      );

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['services'];
        return data.map((item) => ServiceModel.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      print('DB: Error fetching services: $e');
      return [];
    }
  }

  Future<List<ServiceModel>> getProviderServices(String providerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/services/provider/$providerId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['services'];
        return data.map((item) => ServiceModel.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      print('DB: Error fetching provider services: $e');
      return [];
    }
  }

  Future<bool> createService(Map<String, dynamic> serviceData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/services'),
        headers: _headers,
        body: json.encode(serviceData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('DB: Error creating service: $e');
      return false;
    }
  }

  Future<bool> updateService(String serviceId, Map<String, dynamic> serviceData) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/services/$serviceId'),
        headers: _headers,
        body: json.encode(serviceData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('DB: Error updating service: $e');
      return false;
    }
  }

  Future<bool> deleteService(String serviceId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/services/$serviceId'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('DB: Error deleting service: $e');
      return false;
    }
  }

  // ─── Bookings ──────────────────────────────────────────────────────────────

  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/bookings'),
        headers: _headers,
        body: json.encode(bookingData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('DB: Error creating booking: $e');
      return false;
    }
  }

  Future<List<Booking>> getUserBookings(String userId, String role) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/bookings/user/$userId?role=$role'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['bookings'];
        return data.map((item) => Booking.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      print('DB: Error fetching bookings: $e');
      return [];
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/bookings/$bookingId/status'),
        headers: _headers,
        body: json.encode({'status': status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('DB: Error updating booking status: $e');
      return false;
    }
  }

  // ─── Missing Booking Methods ───────────────────────────────────────────────

  Future<({bool success, String? error, Booking? booking})> insertBooking(
    Booking booking,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/bookings'),
        headers: _headers,
        body: json.encode(booking.toMap()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body)['booking'];
        return (
          success: true,
          error: null,
          booking: Booking.fromMap(data),
        );
      }
      return (success: false, error: 'Failed to create booking', booking: null);
    } catch (e) {
      print('DB: Error inserting booking: $e');
      return (success: false, error: e.toString(), booking: null);
    }
  }

  Future<List<Booking>> getBookingsByCustomer(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/bookings/customer/$customerId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['bookings'];
        return data.map((item) => Booking.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      print('DB: Error fetching customer bookings: $e');
      return [];
    }
  }

  Future<List<Booking>> getBookingsByProvider(String providerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/bookings/provider/$providerId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['bookings'];
        return data.map((item) => Booking.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      print('DB: Error fetching provider bookings: $e');
      return [];
    }
  }

  Future<bool> submitBookingFeedback({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/bookings/$bookingId/feedback'),
        headers: _headers,
        body: json.encode({
          'rating': rating,
          'comment': comment,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('DB: Error submitting feedback: $e');
      return false;
    }
  }

  // ─── Provider Methods ──────────────────────────────────────────────────────

  Future<Provider?> getProviderByUserId(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/providers/user/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['provider'];
        return Provider.fromMap(data);
      }
      return null;
    } catch (e) {
      print('DB: Error fetching provider by user ID: $e');
      return null;
    }
  }

  Future<List<Provider>> getAllProviders() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/providers'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['providers'];
        return data.map((item) => Provider.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      print('DB: Error fetching all providers: $e');
      return [];
    }
  }

  Future<Provider?> getProviderById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/providers/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['provider'];
        return Provider.fromMap(data);
      }
      return null;
    } catch (e) {
      print('DB: Error fetching provider by ID: $e');
      return null;
    }
  }

  Future<bool> updateProvider(Provider provider) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/providers/${provider.id}'),
        headers: _headers,
        body: json.encode(provider.toMap()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('DB: Error updating provider: $e');
      return false;
    }
  }

  // ─── Service Methods ───────────────────────────────────────────────────────

  Future<List<ServiceModel>> getServicesByProvider(String providerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/services/provider/$providerId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['services'];
        return data.map((item) => ServiceModel.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      print('DB: Error fetching services by provider: $e');
      return [];
    }
  }

  Future<bool> insertService(ServiceModel service) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/services'),
        headers: _headers,
        body: json.encode(service.toMap()),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('DB: Error inserting service: $e');
      return false;
    }
  }
}
