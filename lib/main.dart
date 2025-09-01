import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'splash_screen.dart';
import 'firebase_options.dart';
import 'screens/otp_debug_screen.dart';
import 'services/admin_initialization_service.dart';
import 'services/auth_state_manager.dart';
import 'onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/ngo_dashboard_screen.dart';
import 'screens/ngo_member_approval_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize default admin account
  try {
    await AdminInitializationService.initializeDefaultAdmin();
  } catch (e) {
    print('Warning: Could not initialize admin account: $e');
  }
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connect & Contribute',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        primaryColor: const Color(0xFF7B2CBF),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B2CBF),
          brightness: Brightness.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B2CBF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7B2CBF), width: 2),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/otp-debug': (context) => const OTPDebugScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// AuthWrapper that listens to authentication state and routes appropriately
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('🔄 AuthWrapper - Connection state: ${snapshot.connectionState}');
        print('🔄 AuthWrapper - Has data: ${snapshot.hasData}');
        if (snapshot.hasData) {
          print('🔄 AuthWrapper - User: ${snapshot.data?.email}');
        }

        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // If user is authenticated, determine where to route them
        if (snapshot.hasData) {
          print('✅ AuthWrapper - User authenticated, checking user type');
          return FutureBuilder<Map<String, dynamic>>(
            future: AuthStateManager().getAuthState(),
            builder: (context, authStateSnapshot) {
              print('🔍 AuthWrapper - Auth state result: ${authStateSnapshot.data}');
              
              if (authStateSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              if (authStateSnapshot.hasData) {
                final authState = authStateSnapshot.data!;
                final userType = authState['userType'];
                
                print('🧭 AuthWrapper - Routing based on userType: $userType');

                switch (userType) {
                  case 'admin':
                    print('🚀 AuthWrapper - Routing to AdminDashboardScreen');
                    return const AdminDashboardScreen();
                  case 'user':
                    print('🚀 AuthWrapper - Routing to HomeScreen (user type)');
                    return const HomeScreen();
                  case 'member':
                    print('🚀 AuthWrapper - Routing to HomeScreen (member type)');
                    return const HomeScreen();
                  case 'ngo':
                    print('🚀 AuthWrapper - Routing to NGODashboardScreen');
                    return const NGODashboardScreen();
                  case 'ngo_pending':
                    print('🚀 AuthWrapper - Routing to NGOMemberApprovalScreen');
                    return const NGOMemberApprovalScreen();
                  default:
                    print('⚠️ AuthWrapper - Unknown userType: $userType, routing to onboarding');
                    return const OnboardingScreen();
                }
              }

              // Error or no data - go to onboarding
              print('❌ AuthWrapper - Error getting auth state, routing to onboarding');
              return const OnboardingScreen();
            },
          );
        }

        // User not authenticated - show onboarding
        print('❌ AuthWrapper - User not authenticated, showing onboarding');
        return const OnboardingScreen();
      },
    );
  }
}
