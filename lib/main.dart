import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/helpers/theme.dart';
import 'package:frontend/pages/settings_page.dart';
import 'package:frontend/pages/settings_page.dart';
import 'package:frontend/settingsBackend/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/settingsBackend/theme_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';
//import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/pages/bookinfo.dart';
import 'package:frontend/pages/subscription.dart';
import 'package:frontend/screens/rewards/reward_dashboard.dart';
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
import 'package:frontend/pages/privacy_policy_page.dart';
import 'package:frontend/pages/terms_of_service_page.dart';
import 'package:frontend/pages/library_page.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

class FeaturePage extends StatelessWidget {
  final String title;
  final IconData icon;

  const FeaturePage({required this.title, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: const Color.fromARGB(255, 40, 37, 223)),
            const SizedBox(height: 20),
            Text(
              "$title Page",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "This feature will be available soon!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow self-signed certificates in development mode
  HttpOverrides.global = MyHttpOverrides();

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

// Custom HttpOverrides to allow self-signed certificates
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Update system UI overlay style based on theme
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
              systemNavigationBarColor:
                  themeProvider.isDarkMode
                      ? const Color(0xFF121212)
                      : Colors.white,
              systemNavigationBarIconBrightness:
                  themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
              systemNavigationBarDividerColor: Colors.transparent,
            ),
          );

          return MaterialApp(
            title: 'narratra.',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
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
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF402e7a),
                brightness: Brightness.dark,
                primary: const Color(0xFF402e7a),
                secondary: const Color(0xFF4c3bcf),
                background: const Color(0xFF3dc2ec),
              ),
              scaffoldBackgroundColor: const Color.fromARGB(255, 18, 18, 18),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color.fromARGB(220, 17, 116, 246),
                foregroundColor: Color.fromARGB(255, 255, 255, 255),
                elevation: 4,
              ),
            ),
            home: const SplashScreen(),
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

                          if (snapshot.connectionState ==
                              ConnectionState.done) {
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
                    onTap:
                        () => Navigator.pushReplacementNamed(
                          context,
                          '/register',
                        ),
                  ),
              '/register':
                  (context) => RegisterPage(
                    onTap:
                        () => Navigator.pushReplacementNamed(context, '/login'),
                  ),
              '/settingsPage': (context) => const SettingsPage(),
              '/preferences': (context) {
                final args =
                    ModalRoute.of(context)!.settings.arguments
                        as Map<String, dynamic>;
                return GenresSelectionPage(uid: args['uid']);
              },
              '/subscription-page': (context) => const SubscriptionPage(),
              '/genre-selection': (context) {
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
              '/profile': (context) => const ProfilePage(),
              '/library': (context) {
                final args =
                    ModalRoute.of(context)!.settings.arguments
                        as Map<String, dynamic>?;
                return const LibraryPage();
              },
              '/favorites':
                  (context) => const FeaturePage(
                    title: "Favorites",
                    icon: Icons.favorite_border,
                  ),
              '/downloads':
                  (context) => const FeaturePage(
                    title: "Downloads",
                    icon: Icons.download,
                  ),
              '/rewards': (context) => const RewardDashboard(),
              '/language':
                  (context) => const FeaturePage(
                    title: "Language Selection",
                    icon: Icons.language,
                  ),
              '/subscription':
                  (context) => const FeaturePage(
                    title: "Subscription",
                    icon: Icons.subscriptions,
                  ),
              '/history':
                  (context) =>
                      const FeaturePage(title: "History", icon: Icons.history),
              '/privacy-policy': (context) => const PrivacyPolicyPage(),
              '/terms': (context) => const TermsOfServicePage(),
              '/rate-app':
                  (context) => const FeaturePage(
                    title: "Rate Narratra",
                    icon: Icons.rate_review,
                  ),
              '/edit-profile':
                  (context) => const FeaturePage(
                    title: "Edit Profile",
                    icon: Icons.edit,
                  ),
            },
          );
        },
      ),
    );
  }
}
