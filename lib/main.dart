import 'package:flutter/material.dart';
import 'package:frontend/pages/intro_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'services/reward_service.dart';
import 'screens/rewards/reward_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize reward system
  initRewards();

  runApp(MyApp());
}

void initRewards() {
  final rewardService = RewardService();

  // Setup daily goal reset at midnight
  rewardService.setupDailyGoalReset();

  FirebaseDynamicLinks.instance.onLink
      .listen((PendingDynamicLinkData? linkData) {
        if (linkData?.link != null) {
          final Uri uri = linkData!.link;
          if (uri.path == '/refer' && uri.queryParameters.containsKey('uid')) {
            final referrerId = uri.queryParameters['uid']!;
            rewardService.processReferral(referrerId);
          }
        }
      })
      .onError((error) {
        // Handle errors
        print('Dynamic Link Error: $error');
      });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rewards App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RewardDashboard(),
    );
  }
}
