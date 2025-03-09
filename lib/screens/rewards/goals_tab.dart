import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import '../../services/reward_service.dart';
import '../../models/user_reward.dart';

class GoalsTab extends StatelessWidget {
  const GoalsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserReward>(
      stream: RewardService().userRewardsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final rewards = snapshot.data!;
        final double progress = rewards.dailyGoalProgress / rewards.dailyGoal;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Reading',
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: CircularProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                strokeWidth: 10,
                                backgroundColor: Colors.grey[200],
                                color: Colors.blue,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${rewards.dailyGoalProgress}',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'of your ${rewards.dailyGoal}-minute goal',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  onPressed:
                                      () => _showGoalChangeDialog(
                                        context,
                                        rewards.dailyGoal,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Weekly Progress',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildWeeklyProgressChart(rewards),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showGoalChangeDialog(
    BuildContext context,
    int currentGoal,
  ) async {
    final TextEditingController hoursController = TextEditingController();
    final TextEditingController minutesController = TextEditingController();

    final result = await showDialog<int>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Set Daily Goal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: hoursController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        decoration: const InputDecoration(labelText: 'Hours'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: minutesController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        decoration: const InputDecoration(labelText: 'Minutes'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final hours = int.tryParse(hoursController.text) ?? 0;
                  final minutes = int.tryParse(minutesController.text) ?? 0;
                  final totalMinutes = (hours * 60) + minutes;
                  if (totalMinutes >= 10 && totalMinutes <= 600) {
                    Navigator.pop(context, totalMinutes);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter a valid goal between 10 minutes and 10 hours',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Set Goal'),
              ),
            ],
          ),
    );

    if (result != null && context.mounted) {
      await RewardService().updateDailyGoal(result);
    }
  }

  Widget _buildWeeklyProgressChart(UserReward rewards) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: _buildBarGroups(rewards),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    switch (value.toInt()) {
                      0 => 'S',
                      1 => 'M',
                      2 => 'T',
                      3 => 'W',
                      4 => 'T',
                      5 => 'F',
                      6 => 'S',
                      _ => '',
                    },
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(UserReward rewards) {
    // Example data, replace with actual weekly progress data
    final weeklyProgress = [30, 45, 60, 20, 50, 40, 35];

    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: weeklyProgress[index].toDouble(),
            color: Colors.blue,
            width: 16,
          ),
        ],
      );
    });
  }
}
