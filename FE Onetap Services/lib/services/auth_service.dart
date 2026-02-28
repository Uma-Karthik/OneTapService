import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'booking_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Map<String, dynamic> _parseBody(String body) {
    if (body.isEmpty) {
      return {};
    }

    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }
    } catch (_) {
      // Fallback for non-JSON responses (e.g. text/html from proxies or misconfigured APIs)
    }

    return {'error': body};
  }

  // ─── Initialize ────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    final userData = prefs.getString('user_data');

    print('AUTH: initialize called');
    print('AUTH: Token exists: ${_token != null}');
    print('AUTH: UserData exists: ${userData != null}');

    if (_token != null && userData != null) {
      try {
        _currentUser = User.fromMap(json.decode(userData));
        print('AUTH: User restored from storage: ${_currentUser?.id}');
        BookingService().initializeSocket();
      } catch (e) {
        print('AUTH: Error restoring session: $e');
        await logout();
      }
    }
  }

  // ─── Login ─────────────────────────────────────────────────────────────────
  Future<({bool success, String? error, User? user})> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim().toLowerCase(),
          'password': password,
          'role': role.name,
        }),
      );

      final data = _parseBody(response.body);
      print('AUTH: Login response status: ${response.statusCode}');
      print('AUTH: Response body: ${response.body}');
      print('AUTH: Parsed data: $data');

      if (response.statusCode == 200) {
        _token = data['token'];
        print('AUTH: Token set: ${_token?.substring(0, 10)}...');
        
        try {
          _currentUser = User.fromMap(data['user']);
          print('AUTH: User created: id=${_currentUser?.id}, name=${_currentUser?.name}');
        } catch (e) {
          print('AUTH: Error creating user from response: $e');
          print('AUTH: User data from response: ${data['user']}');
          rethrow;
        }
        
        BookingService().initializeSocket();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        await prefs.setString('user_data', json.encode(_currentUser!.toMap()));
        
        print('AUTH: User data stored in prefs');

        return (success: true, error: null as String?, user: _currentUser);
      } else {
        return (
          success: false,
          error: data['error'] as String? ?? 'Login failed',
          user: null as User?,
        );
      }
    } catch (e) {
      return (
        success: false,
        error: 'Connection error: $e',
        user: null as User?,
      );
    }
  }

  // ─── Signup ────────────────────────────────────────────────────────────────
  Future<({bool success, String? error, User? user})> signup({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
    required UserRole role,
    String? companyName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'phone': phone.trim(),
          'address': address.trim(),
          'password': password,
          'role': role.name,
          'companyName': companyName,
        }),
      );

      final data = _parseBody(response.body);
      print('AUTH: Signup response status: ${response.statusCode}');
      print('AUTH: Response body: ${response.body}');

      if (response.statusCode == 201) {
        _token = data['token'];
        print('AUTH: Signup token set: ${_token?.substring(0, 10)}...');
        
        try {
          _currentUser = User.fromMap(data['user']);
          print('AUTH: Signup user created: id=${_currentUser?.id}, name=${_currentUser?.name}, role=${_currentUser?.role}');
        } catch (e) {
          print('AUTH: Error creating user from signup response: $e');
          print('AUTH: User data from signup response: ${data['user']}');
          rethrow;
        }
        
        BookingService().initializeSocket();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        await prefs.setString('user_data', json.encode(_currentUser!.toMap()));

        return (success: true, error: null as String?, user: _currentUser);
      } else {
        return (
          success: false,
          error: data['error'] as String? ?? 'Signup failed',
          user: null as User?,
        );
      }
    } catch (e) {
      return (
        success: false,
        error: 'Connection error: $e',
        user: null as User?,
      );
    }
  }

  // ─── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');
  }

  // ─── Update Profile ────────────────────────────────────────────────────────
  Future<bool> updateProfile(User updatedUser) async {
    // This will be implemented in DatabaseService or here if preferred
    return false;
  }
}
