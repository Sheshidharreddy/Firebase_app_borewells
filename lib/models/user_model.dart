class UserModel {
  final String id;
  final String email;
  final String role;
  final String? name;
  final String organizationId; // Organization/Company ID
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    required this.organizationId,
    required this.createdAt,
    this.lastLogin,
  });

  // Convert from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      role: map['role'] ?? 'driver', // default to driver role
      name: map['name'],
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
    String? organizationId,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      name: name ?? this.name,
      organizationId: organizationId ?? this.organizationId,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  // Check if user is admin
  bool get isAdmin => role.toLowerCase() == 'admin';

  // Check if user is driver
  bool get isDriver => role.toLowerCase() == 'driver';
}
