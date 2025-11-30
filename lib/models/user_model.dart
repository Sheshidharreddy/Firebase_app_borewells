class UserModel {
  final String id;
  final String email;
  final String role;
  final String? name;
  final String adminId;
  final String organizationId; // Organization/Company ID
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    required this.adminId,
    required this.organizationId,
    required this.createdAt,
    this.lastLogin,
  });

  // Convert from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      role: map['role'] ?? 'user', // default to user role
      name: map['name'],
      adminId: map['adminId'] ?? 'admin_default',
      organizationId: map['organizationId'] ?? 'org_default',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt']?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      ),
      lastLogin: map['lastLogin'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastLogin'].millisecondsSinceEpoch)
          : null,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'name': name,
      'adminId': adminId,
      'organizationId': organizationId,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }

  // Copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? role,
    String? name,
    String? adminId,
    String? organizationId,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      name: name ?? this.name,
      adminId: adminId ?? this.adminId,
      organizationId: organizationId ?? this.organizationId,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  // Check if user is admin
  bool get isAdmin {
    final normalized = role.toLowerCase();
    return normalized == 'admin' || normalized == 'super_admin';
  }

  bool get isSuperAdmin => role.toLowerCase() == 'super_admin';

  // Check if user is driver
  bool get isDriver {
    final normalized = role.toLowerCase();
    return normalized == 'driver' || normalized == 'user';
  }
}
