import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../rewards/points_tab.dart';
import '../rewards/goals_tab.dart';

class RewardDashboard extends StatefulWidget {
  @override
  _RewardDashboardState createState() => _RewardDashboardState();
}

class _RewardDashboardState extends State<RewardDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  color: Color(0xFF3A5EF0),
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
          labelColor: Color(0xFF3A5EF0),
          labelStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF3A5EF0),
          tabs: [
            Tab(
              icon: SvgPicture.asset(
                'assets/icons/points.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  _tabController.index == 0 ? Color(0xFF3A5EF0) : Colors.grey,
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
                  _tabController.index == 1 ? Color(0xFF3A5EF0) : Colors.grey,
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
