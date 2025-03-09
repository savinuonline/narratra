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
        setState(() {}); // Rebuild to update SVG colors
      }
    });
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('user_rewards')
              .doc(_user!.uid)
              .get();
      setState(() {
        _userDoc = userDoc;
      });
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
        elevation: 0,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Narratra. ',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF3A5EF0),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              TextSpan(
                text: 'Rewards',
                style: GoogleFonts.nunito(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3A5EF0),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF3A5EF0),
          tabs: [
            Tab(
              icon: SvgPicture.asset(
                'assets/icons/points.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  _tabController.index == 0
                      ? const Color(0xFF3A5EF0)
                      : Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              text: 'Points',
            ),
            Tab(
              icon: SvgPicture.asset(
                'assets/icons/goals.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  _tabController.index == 1
                      ? const Color(0xFF3A5EF0)
                      : Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              text: 'Goals',
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
