import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../rewards/points_tab.dart';
import '../rewards/goals_tab.dart';

class RewardDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
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
            tabs: [
              Tab(icon: Icon(Icons.star), text: 'Points'),
              Tab(icon: Icon(Icons.flag), text: 'Goals'),
            ],
          ),
        ),
        body: TabBarView(children: [PointsTab(), GoalsTab()]),
      ),
    );
  }
}
