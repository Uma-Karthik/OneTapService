enum UserRole { customer, provider }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final UserRole role;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    this.profileImage,
  });

  // JSON serialization (used internally / for session caching)
  Map<String, dynamic> toJson() => toMap();

  factory User.fromJson(Map<String, dynamic> json) => User.fromMap(json);

  // Supabase row uses snake_case column names
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'role': role.name,
    'profile_image': profileImage,
  };

  factory User.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String? ?? map['_id'] as String?;
    if (id == null || id.isEmpty) {
      print('USER_MODEL: Invalid user data - id is null or empty');
      print('USER_MODEL: Received map keys: ${map.keys.toList()}');
      print('USER_MODEL: Full map: $map');
      throw Exception('User ID is required. Received: $map');
    }
    
    return User(
      id: id,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.customer,
      ),
      profileImage: (map['profile_image'] ?? map['profileImage']) as String?,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    UserRole? role,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
