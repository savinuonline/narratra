import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/firebase_options.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:frontend/screens/rewards/reward_dashboard.dart';
import 'package:frontend/services/reward_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseDynamicLinks.instance.getInitialLink();

  RewardService rewardService = RewardService();
  await rewardService.initializeTestUserData();

  runApp(const MyApp());
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
