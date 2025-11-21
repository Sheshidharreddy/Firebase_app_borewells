import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/user_home_screen.dart';
import 'screens/user_dashboard_screen.dart';
import 'screens/user_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");
    
    // Configure Firestore for Flutter Web
    if (kIsWeb) {
      // Clear any cached persistence
      try {
        await FirebaseFirestore.instance.clearPersistence();
        print("✅ Firestore persistence cleared");
      } catch (e) {
        print('Firestore clear persistence error (expected on first run): $e');
      }
      
      // Configure Firestore settings for web
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      print("✅ Firestore settings configured for web");
      
      // Test Firestore connectivity
      try {
        await FirebaseFirestore.instance.enableNetwork();
        // Try a simple connectivity test
        await FirebaseFirestore.instance
            .collection('_test')
            .doc('_connection')
            .get()
            .timeout(const Duration(seconds: 5));
        print("✅ Firestore connection test successful");
      } catch (e) {
        print("⚠️ Firestore connection test failed: $e");
        print("📝 Will use fallback test data");
      }
    }
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
    print("📝 Will use test data mode");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServiceMaster',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin': (context) => const AdminHomeScreen(),
        '/user': (context) => const UserDashboardScreen(userId: 'user123', userName: 'John Doe'),
        '/user-old': (context) => const UserHomeScreen(),
        '/org-demo': (context) => const UserSelectionScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
