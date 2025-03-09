import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/signup_page.dart';
import 'screens/rewards/reward_dashboard.dart';

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
      home:
          FirebaseAuth.instance.currentUser == null
              ? const SignUpPage()
              : RewardDashboard(),
      routes: {
        '/signUp': (context) => const SignUpPage(),
        '/rewardDashboard': (context) => RewardDashboard(),
      },
    );
  }
}
