import '../models/user_model.dart';

class TestAuthService {
  // Mock users for testing
  final Map<String, Map<String, String>> _testUsers = {
    'admin@servicemaster.com': {
      'password': '123456',
      'role': 'admin',
      'name': 'Admin User',
      'organization': 'org_test',
    },
    'driver@servicemaster.com': {
      'password': '123456', 
      'role': 'user',
      'name': 'Driver User',
      'organization': 'org_test',
      'adminId': 'test_admin',
    },
    'mechanic@servicemaster.com': {
      'password': '123456',
      'role': 'user',
      'name': 'Mechanic User',
      'organization': 'org_test',
      'adminId': 'test_admin',
    },
  };

  // Mock sign in for testing
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final user = _testUsers[email.toLowerCase()];
    if (user != null && user['password'] == password) {
      return UserModel(
        id: 'test_${email.hashCode}',
        email: email,
        role: user['role']!,
        createdAt: DateTime.now(),
      );
    }
    
    throw Exception('Invalid email or password');
  }

  // Mock sign out
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
