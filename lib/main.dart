// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/pages/bookinfo.dart';
import 'firebase_options.dart';
import 'pages/genres_selection_page.dart';
import 'pages/main_screen.dart';
import 'package:frontend/pages/auth_page.dart';
import 'package:frontend/pages/intro_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/register_page.dart';
import 'package:frontend/pages/splash_screen.dart';
import 'package:frontend/pages/media_player.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/widgets/custom_bottom_nav_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'narratra.',
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
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(220, 17, 116, 246),
          foregroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 4,
        ),
      ),
      home: const SplashScreen(), // Show splash screen immediately
      onGenerateRoute: (settings) {
        // Handle Firebase initialization and navigation after splash screen
        if (settings.name == '/auth') {
          return MaterialPageRoute(
            builder:
                (context) => FutureBuilder(
                  future: Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Scaffold(
                        body: Center(
                          child: Text('Error initializing Firebase'),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      return const AuthPage();
                    }

                    return const SplashScreen();
                  },
                ),
          );
        }
        return null;
      },
      routes: {
        '/intro': (context) => const IntroPage(),
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
        '/media': (context) => MediaPlayerPage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
