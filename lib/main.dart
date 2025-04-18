import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:wc_salary/firebase_options.dart';
import 'package:wc_salary/providers/auth_provider.dart';
import 'package:wc_salary/providers/toilet_session_provider.dart';
import 'package:wc_salary/screens/home_screen.dart';
import 'package:wc_salary/screens/welcome_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

// Wrapper widget to check auth state and decide initial route
class AuthCheckWrapper extends StatelessWidget {
  const AuthCheckWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final toiletProvider = Provider.of<ToiletSessionProvider>(context, listen: false);

    // If auth state is still loading, show a splash screen
    if (authProvider.isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Check if user is authenticated and has a salary set
    if (authProvider.isAuthenticated) {
      // We're logged in, let's make sure we have data loaded
      // This is already done in the initialize method, but we ensure it happens here too
      toiletProvider.initialize();

      // Go directly to home screen if user is authenticated
      return const HomeScreen();
    }

    // Not authenticated, go to welcome screen
    return const WelcomeScreen();
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ToiletSessionProvider()),
      ],
      child: MaterialApp(
        title: 'Toilet Earner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Dark wooden theme based on the image
          scaffoldBackgroundColor: const Color(0xFF2A140E), // Dark brown background
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFFFF7D2A), // Orange primary
            secondary: const Color(0xFFFFAA33), // Amber secondary
            tertiary: const Color(0xFFFF5722), // Deeper orange
            background: const Color(0xFF2A140E), // Dark brown
            surface: const Color(0xFF3D2314), // Slightly lighter brown
            error: Colors.red.shade700,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onBackground: Colors.white,
            onSurface: Colors.white,
            brightness: Brightness.dark,
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'RubikDirt',
            ),
            headlineMedium: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'RubikDirt',
            ),
            titleLarge: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'RubikDirt',
            ),
            bodyLarge: TextStyle(fontFamily: 'RubikDirt'),
            bodyMedium: TextStyle(fontFamily: 'RubikDirt'),
          ),
          cardTheme: CardTheme(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF8D6E63), width: 3),
            ),
            color: const Color(0xFF3D2314), // Wood-like brown
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF3D2314),
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 8,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7D2A), // Orange
              foregroundColor: Colors.white,
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF8D6E63), width: 2),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'RubikDirt',
              ),
            ),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFFFF7D2A), // Orange
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Color(0xFFFF7D2A),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF3D2314),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8D6E63), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8D6E63), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF7D2A), width: 2),
            ),
            labelStyle: const TextStyle(color: Colors.white70),
            hintStyle: const TextStyle(color: Colors.white30),
          ),
          dialogTheme: DialogTheme(
            backgroundColor: const Color(0xFF3D2314),
            elevation: 16,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF8D6E63), width: 3),
            ),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: const Color(0xFF3D2314),
            contentTextStyle: const TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFF8D6E63), width: 1),
            ),
          ),
        ),
        home: const AuthCheckWrapper(),
      ),
    );
  }
}
