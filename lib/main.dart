// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/pages/bookinfo.dart';
import 'firebase_options.dart';
import 'pages/genres_selection_page.dart';
import 'models/user_model.dart';
import 'pages/main_screen.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/pages/auth_page.dart';
import 'package:frontend/pages/search_page.dart';
import 'package:frontend/pages/intro_page.dart';
import 'package:frontend/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Create a dummy user (replace with real user info later)
  UserModel get dummyUser => UserModel(
    uid: 'GEhVv1eBKM4VugcxFlVN',
    displayName: 'Test User',
    selectedGenres: ['Personal Growth', 'Fiction'],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Narratra.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF402e7a),
          brightness: Brightness.light,
          primary: const Color(0xFF402e7a),
          secondary: const Color(0xFF4c3bcf),
          background: const Color(0xFF3dc2ec),
        ),
        scaffoldBackgroundColor: const Color(0xffc7d9dd),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff3dc2ec),
          foregroundColor: Color(0xff3dc2ec),
          elevation: 4,
        ),
      ),
      initialRoute: '/intro',
      routes: {
        '/intro': (context) => const IntroPage(),
        '/loginpage': (context) => const LoginPage(),
        '/preferences':
            (context) => const GenresSelectionPage(uid: 'GEhVv1eBKM4VugcxFlVN'),
        '/main': (context) => const MainScreen(),
        '/bookinfo': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return BookInfoPage(bookId: args['bookId']);
        },
      },
      home: SearchPage(),
      //AuthPage()
    );
  }
}
