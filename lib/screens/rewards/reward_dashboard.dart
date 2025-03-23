import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../rewards/points_tab.dart';
import '../rewards/goals_tab.dart';

class RewardDashboard extends StatefulWidget {
  const RewardDashboard({Key? key}) : super(key: key);

  @override
  _RewardDashboardState createState() => _RewardDashboardState();
}

class _RewardDashboardState extends State<RewardDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _user;
  DocumentSnapshot? _userDoc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('user_rewards')
          .doc(_user!.uid);
      final userDoc = await docRef.get();
      if (!userDoc.exists) {
        await docRef.set({
          'userId': _user!.uid,
          'displayName': _user!.displayName ?? 'User',
          'points': 0,
          'level': 1,
          'dailyGoal': 30,
          'dailyGoalProgress': 0,
          'lastLoginBonusDate':
              DateTime.now()
                  .subtract(const Duration(days: 1))
                  .toIso8601String(),
          'freeAudiobooks': 0,
          'premiumAudiobooks': 0,
          'usedInviteCodes': [],
          'generatedInviteCodes': [],
          'inviteRewardCount': 0,
        });
        // Get the newly created document
        final newDoc = await docRef.get();
        setState(() {
          _userDoc = newDoc;
        });
      } else {
        setState(() {
          _userDoc = userDoc;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userDoc == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'narratra. Rewards',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3A5EF0),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF3A5EF0),
          tabs: [
            Tab(
              icon: SvgPicture.asset(
                'lib/assets/icons/points.svg',
                width: 24,
                height: 24,
                color:
                    _tabController.index == 0
                        ? const Color(0xFF3A5EF0)
                        : Colors.grey,
              ),
              child: Text(
                'Points',
                style: GoogleFonts.nunito(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Tab(
              icon: SvgPicture.asset(
                'lib/assets/icons/goals.svg',
                width: 24,
                height: 24,
                color:
                    _tabController.index == 1
                        ? const Color(0xFF3A5EF0)
                        : Colors.grey,
              ),
              child: Text(
                'Goals',
                style: GoogleFonts.nunito(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [PointsTab(), GoalsTab()],
      ),
    );
  }
}
