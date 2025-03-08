import 'package:flutter/material.dart';
import 'services/reward_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:frontend/custom_bottom_nav_bar%5B1%5D.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize reward system
  final rewardService = RewardService();

  // Handle referral links
  FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) {
    final Uri uri = dynamicLink?.link ?? Uri();
    if (uri.path == '/refer' && uri.queryParameters.containsKey('uid')) {
      final referrerId = uri.queryParameters['uid']!;
      rewardService.processReferral(referrerId);
    }
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rewards App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NavigationModule(),
    );
  }
}
