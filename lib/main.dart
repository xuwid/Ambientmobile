import 'package:ambient/utils/assets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:ambient/screens/homescreen.dart'; // Your HomeScreen
import 'package:ambient/models/state_models.dart'; // Your state management
import 'package:ambient/screens/Login.dart';
import 'package:ambient/screens/Signup.dart';
import 'package:ambient/screens/splash.dart'; // Your SplashScreen widget
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
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Your App',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 17, 177),
        ),
      ),
      // Always show splash screen first.
      home: const SplashScreenWrapper(),
      routes: {
        '/homeTab': (context) => const HomeScreen(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        // Other routes...
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
    // Always display splash for 2 seconds.
    await Future.delayed(const Duration(seconds: 2));
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is signed in, navigate to HomeScreen.
      Navigator.pushReplacementNamed(context, '/homeTab');
    } else {
      // User is not signed in, navigate to LoginPage.
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen(); // Display your splash screen widget
  }
}
