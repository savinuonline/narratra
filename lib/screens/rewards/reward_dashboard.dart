import 'package:flutter/material.dart';
import '../rewards/points_tab.dart';
import '../rewards/referral_tab.dart';
import '../rewards/goals_tab.dart';

class RewardDashboard extends StatelessWidget {
  const RewardDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Rewards'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.star), text: 'Points'),
              Tab(icon: Icon(Icons.share), text: 'Refer'),
              Tab(icon: Icon(Icons.flag), text: 'Goals'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PointsTab(),
            ReferralTab(),
            GoalsTab(),
          ],
        ),
      ),
    );
  }
}