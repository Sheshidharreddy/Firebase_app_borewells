import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../screens/login_screen.dart';
import '../screens/admin_home_screen.dart';
import '../screens/driver_dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is not signed in, show login screen
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        // User is signed in, determine role and navigate accordingly
        return FutureBuilder<UserModel?>(
          future: _authService.getCurrentUserData(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (userSnapshot.hasData && userSnapshot.data != null) {
              final user = userSnapshot.data!;
              
              if (user.isAdmin) {
                return AdminHomeScreen();
              } else {
                return DriverDashboardScreen();
              }
            }

            // If we can't get user data, sign out and show login
            _authService.signOut();
            return const LoginScreen();
          },
        );
      },
    );
  }
}
