// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/genres_selection_page.dart';
import 'pages/home_screen.dart';
import 'models/user_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Dummy user for testing
  UserModel get dummyUser => UserModel(
    uid: 'dummyUID',
    displayName: 'Test User',
    selectedGenres: ['Literary Fiction', 'Romance'],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audiobook App',
      debugShowCheckedModeBanner: false,
      // Enable Material 3 and set up a custom color scheme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF402e7a),        // Primary color from palette
          onPrimary: Colors.white,
          secondary: Color(0xFF4b70f5),      // Secondary color
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          background: Color(0xFF3dc2ec),       // Accent/Background color
          onBackground: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: const Color(0xFF3dc2ec),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF402e7a),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      initialRoute: '/preferences',
      routes: {
        '/preferences': (context) => const GenresSelectionPage(),
        '/home': (context) => HomeScreen(user: dummyUser),
      },
    );
  }
}
