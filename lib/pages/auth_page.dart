import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/pages/genres_selection_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/main_screen.dart';
import 'package:frontend/pages/intro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  Future<bool> _isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time') ?? true;
    if (isFirstTime) {
      await prefs.setBool('first_time', false);
    }
    return isFirstTime;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isFirstTime(),
      builder: (context, firstTimeSnapshot) {
        if (firstTimeSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If it's the first time, show intro page
        if (firstTimeSnapshot.data == true) {
          return const IntroPage();
        }

        // Otherwise, handle auth state
        return Scaffold(
          body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              // Show loading indicator while checking auth state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // If user is logged in
              if (snapshot.hasData) {
                // Check if user has completed registration
                return FutureBuilder<DocumentSnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection('Users')
                          .doc(snapshot.data!.uid)
                          .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (userSnapshot.hasData && userSnapshot.data!.exists) {
                      // Check if user has selected preferences
                      final userData =
                          userSnapshot.data!.data() as Map<String, dynamic>;
                      final preferences =
                          userData['preferences'] as List<dynamic>?;

                      if (preferences == null || preferences.isEmpty) {
                        // Navigate to preferences selection if not set
                        return Navigator(
                          onGenerateRoute:
                              (settings) => MaterialPageRoute(
                                builder:
                                    (context) => GenresSelectionPage(
                                      uid: snapshot.data!.uid,
                                    ),
                              ),
                        );
                      }

                      // If everything is set up, show main screen
                      return const MainScreen();
                    }

                    // If user document doesn't exist, navigate to registration
                    return LoginPage(
                      onTap:
                          () => Navigator.pushReplacementNamed(
                            context,
                            '/register',
                          ),
                    );
                  },
                );
              }

              // If user is not logged in, show login page
              return LoginPage(
                onTap:
                    () => Navigator.pushReplacementNamed(context, '/register'),
              );
            },
          ),
        );
      },
    );
  }
}
