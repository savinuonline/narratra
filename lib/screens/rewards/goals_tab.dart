import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../services/reward_service.dart';
import '../../models/user_reward.dart';
import 'dart:math';

class GoalsTab extends StatelessWidget {
  const GoalsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserReward>(
      stream: RewardService().userRewardsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error in StreamBuilder: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final rewards = snapshot.data!;
        final double progress =
            rewards.dailyGoal > 0
                ? (rewards.dailyGoalProgress / rewards.dailyGoal).clamp(
                  0.0,
                  1.0,
                )
                : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Today's Goal Card with Circular Display
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Reading Goal",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3A5EF0),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap:
                              () => _showTimePickerDialog(
                                context,
                                rewards.dailyGoal,
                              ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 180,
                                height: 180,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 15,
                                  backgroundColor: Colors.grey[200],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF3A5EF0),
                                      ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    formatMinutes(rewards.dailyGoalProgress),
                                    style: GoogleFonts.nunito(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF3A5EF0),
                                    ),
                                  ),
                                  Text(
                                    'of ${formatMinutes(rewards.dailyGoal)}',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Icon(
                                    Icons.edit,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF3A5EF0),
                        ),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toInt()}% completed',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Weekly Progress
              Text(
                'Weekly Progress',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3A5EF0),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWeeklyProgressChart(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem('Average', '45 min'),
                          _buildStatItem('Best Day', 'Monday'),
                          _buildStatItem('Total', '315 min'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tips Card
              Card(
                elevation: 4,
                color: const Color(0xFFF0F8FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Reading Tip',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Consistent daily reading helps improve comprehension and retention. Try to read at the same time each day to build a habit.',
                        style: GoogleFonts.nunito(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3A5EF0),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressChart() {
    // Generate sample data for now - in production, use actual user data
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weeklyData = [45, 30, 60, 25, 75, 40, 40];

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    weekDays[value.toInt()],
                    style: GoogleFonts.nunito(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value == 0) return Text('0');
                  if (value == 50) return Text('50');
                  if (value == 100) return Text('100');
                  return Text('');
                },
                reservedSize: 30,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 25,
            getDrawingHorizontalLine:
                (value) => FlLine(color: Colors.grey[300], strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            weekDays.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: weeklyData[index].toDouble(),
                  color: const Color(0xFF3A5EF0),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  width: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showTimePickerDialog(
    BuildContext context,
    int currentGoal,
  ) async {
    int hours = currentGoal ~/ 60;
    int minutes = currentGoal % 60;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Set Daily Reading Goal',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select your daily reading time goal'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hours wheel
                      SizedBox(
                        width: 70,
                        child: ListWheelScrollView(
                          itemExtent: 50,
                          diameterRatio: 1.5,
                          useMagnifier: true,
                          magnification: 1.2,
                          onSelectedItemChanged: (index) {
                            setState(() => hours = index);
                          },
                          controller: FixedExtentScrollController(
                            initialItem: hours,
                          ),
                          physics: const FixedExtentScrollPhysics(),
                          children: List.generate(11, (index) {
                            return Center(
                              child: Text(
                                '$index',
                                style: GoogleFonts.nunito(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Text(' hour ', style: GoogleFonts.nunito(fontSize: 16)),
                      // Minutes wheel
                      SizedBox(
                        width: 70,
                        child: ListWheelScrollView(
                          itemExtent: 50,
                          diameterRatio: 1.5,
                          useMagnifier: true,
                          magnification: 1.2,
                          onSelectedItemChanged: (index) {
                            setState(() => minutes = index * 5);
                          },
                          controller: FixedExtentScrollController(
                            initialItem: (minutes / 5).round(),
                          ),
                          physics: const FixedExtentScrollPhysics(),
                          children: List.generate(12, (index) {
                            return Center(
                              child: Text(
                                '${index * 5}',
                                style: GoogleFonts.nunito(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Text(' min', style: GoogleFonts.nunito(fontSize: 16)),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A5EF0),
                  ),
                  onPressed: () {
                    // Calculate total minutes
                    final totalMinutes = hours * 60 + minutes;

                    // Ensure the goal is within bounds (10 min to 10 hours)
                    if (totalMinutes >= 10 && totalMinutes <= 600) {
                      // Update the daily goal
                      RewardService().updateDailyGoal(totalMinutes);
                      Navigator.pop(context);
                    } else {
                      // Show error for invalid goal
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Goal must be between 10 minutes and 10 hours',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Set Goal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper function to format minutes as "Xh Ym"
  String formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      int hours = minutes ~/ 60;
      int mins = minutes % 60;
      return hours > 0 && mins > 0
          ? '${hours}h ${mins}m'
          : (mins == 0 ? '${hours}h' : '${mins}m');
    }
  }
}
