import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:ambient/screens/homescreen.dart'; // Your HomeScreen
import 'package:ambient/models/state_models.dart'; // Your state management
import 'package:ambient/screens/Login.dart';
import 'package:ambient/screens/Signup.dart';
import 'package:ambient/screens/splash.dart'; // Import your SplashScreen
import 'firebase_options.dart'; // Import your Firebase options
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase initialization
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Optionally set persistence to avoid IndexedDB issues
      await FirebaseAuth.instance.setPersistence(Persistence.NONE);
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => HomeState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 17, 177),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (userSnapshot.hasError) {
            print('Auth state error: ${userSnapshot.error}');
            return const Center(
              child: Text('An error occurred.'),
            );
          }
          if (userSnapshot.hasData) {
            return const HomeScreen(); // Navigate to the HomeScreen if logged in
          }
          return const SplashScreenWrapper(); // Show the splash screen first, then login
        },
      ),
      routes: {
        '/homeTab': (context) => const HomeScreen(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(), // Add signup page if needed
        // Other routes
      },
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    print("Navigating to the next screen...");
    await Future.delayed(const Duration(seconds: 2)); // Simulate loading time
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in.
      print("User is signed in. Navigating to HomeScreen.");
      Navigator.pushReplacementNamed(
          context, '/homeTab'); // Navigate to home if authenticated
    } else {
      // User is not signed in.
      print("User is not signed in. Navigating to LoginPage.");
      Navigator.pushReplacementNamed(
          context, '/login'); // Navigate to login if not authenticated
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen(); // Display your splash screen
  }
}
