// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:frontend/pages/bookinfo.dart';
import 'package:frontend/pages/login_or_register_page.dart';
import 'firebase_options.dart';
import 'pages/genres_selection_page.dart';
import 'pages/main_screen.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/pages/auth_page.dart';
import 'package:frontend/pages/search_page.dart';
import 'package:frontend/pages/intro_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/register_page.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase App Check
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: kDebugMode
  //       ? AndroidProvider.debug
  //       : AndroidProvider.playIntegrity,
  //);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/auth': (context) => const AuthPage(),
        '/login':
            (context) => LoginPage(
          onTap: () => Navigator.pushReplacementNamed(context, '/register'),
        ),
        '/register':
            (context) => RegisterPage(
          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
        '/preferences': (context) {
          final args =
          ModalRoute.of(context)!.settings.arguments
          as Map<String, dynamic>;
          return GenresSelectionPage(uid: args['uid']);
        },
        '/main': (context) => const MainScreen(),
        '/bookinfo': (context) {
          final args =
          ModalRoute.of(context)!.settings.arguments
          as Map<String, dynamic>;
          return BookInfoPage(bookId: args['bookId']);
        },
      },
    );
  }
}
