import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/role_service.dart';
import '../screens/login_screen.dart';
import '../screens/admin_home_screen.dart';
import '../screens/user_home_screen.dart';

class AuthWrapper extends StatefulWidget {
  AuthWrapper({super.key});
  
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  final RoleService _roleService = RoleService();
  
  // Test mode flag
  static const bool _useTestMode = true;

  @override
  Widget build(BuildContext context) {
    if (_useTestMode) {
      // In test mode, check if we have a current test user through role service
      return FutureBuilder<String>(
        future: _roleService.getUserRole(),
        builder: (context, roleSnapshot) {
          if (roleSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Check if we have role data (means user is logged in)
          if (roleSnapshot.hasData) {
            final role = roleSnapshot.data!;
            
            if (role == 'admin') {
              return const AdminHomeScreen();
            } else {
              return const UserHomeScreen();
            }
          }

          // No role data means not logged in
          return const LoginScreen();
        },
      );
    }
    
    // Firebase mode (when not using test mode)
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        return FutureBuilder<String>(
          future: _roleService.getUserRole(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (roleSnapshot.hasData) {
              final role = roleSnapshot.data!;
              
              if (role == 'admin') {
                return const AdminHomeScreen();
              } else {
                return const UserHomeScreen();
              }
            }

            _authService.signOut();
            return const LoginScreen();
          },
        );
      },
    );
  }
}
