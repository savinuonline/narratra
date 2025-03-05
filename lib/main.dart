// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/genres_selection_page.dart';
import 'pages/home_screen.dart';
import 'models/user_model.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before runApp()
  await Firebase.initializeApp(
    // Pass the default options if you're using the FlutterFire CLI
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // For now, we create a dummy user. Later, update this with real user info.
  UserModel get dummyUser => UserModel(
    uid: 'dummyUID',
    displayName: 'Test User',
    selectedGenres: ['Literary Fiction', 'Romance'],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audiobook App',
      // Start with the preferences (genres) page
      initialRoute: '/preferences',
      routes: {
        // Load your genres selection page first
        '/preferences': (context) => const GenresSelectionPage(),
        // When navigating to '/home', pass the dummy user to the HomeScreen
        '/home': (context) => HomeScreen(user: dummyUser),
      },
    );
  }
}
