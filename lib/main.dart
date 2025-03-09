import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/auth/signup_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/rewards/reward_dashboard.dart';
import 'services/reward_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rewards App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show loading while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If no user, show login
          if (!snapshot.hasData) {
            return const LoginPage();
          }

          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('user_rewards')
                    .doc(snapshot.data!.uid)
                    .get(),
            builder: (context, docSnapshot) {
              if (docSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // If document doesn't exist, create it
              if (!docSnapshot.hasData || !docSnapshot.data!.exists) {
                // Create the user document
                FirebaseFirestore.instance
                    .collection('user_rewards')
                    .doc(snapshot.data!.uid)
                    .set({
                      'userId': snapshot.data!.uid,
                      'displayName': snapshot.data!.displayName ?? 'User',
                      'points': 0,
                      'level': 1,
                      'dailyGoal': 30,
                      'dailyGoalProgress': 0,
                      'lastLoginBonusDate': DateTime.now().toIso8601String(),
                      'freeAudiobooks': 0,
                      'premiumAudiobooks': 0,
                      'usedInviteCodes': [],
                      'generatedInviteCodes': [],
                      'inviteRewardCount': 0,
                    });
                print(
                  'Created missing document for user: ${snapshot.data!.uid}',
                );
              }

              // Now we can show the reward dashboard
              return const RewardDashboard();
            },
          );
        },
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signUp': (context) => const SignUpPage(),
        '/rewardDashboard': (context) => const RewardDashboard(),
      },
    );
  }
}
