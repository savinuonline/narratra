import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/reward_service.dart';
import '../../models/user_reward.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class PointsTab extends StatelessWidget {
  // Add level names as a static map
  static const Map<int, String> levelNames = {
    1: 'New Listener',
    2: 'Page Turner',
    3: 'Story Seeker',
    4: 'Chapter Chaser',
    5: 'Bookworm',
    6: 'Tale Traveler',
    7: 'Narrative Explorer',
    8: 'Audiobook Aficionado',
    9: 'Literary Sage',
    10: 'Legendary Listener',
  };

  // Add level descriptions
  static const Map<int, String> levelDescriptions = {
    1: 'Just getting started—welcome aboard!',
    2: 'Warming up those ears with some chapters.',
    3: 'Actively diving into more stories.',
    4: 'Consistently consuming books.',
    5: 'Starting to stand out among readers.',
    6: 'Journeying through stories with ease.',
    7: 'Experienced listener with a thirst for more.',
    8: 'Knows their way around narrations.',
    9: 'Respected among fellow listeners.',
    10: 'A true master of the audiobook world.',
  };

  // Add points required for each level
  static const Map<int, int> levelPoints = {
    1: 0,
    2: 1000,
    3: 2500,
    4: 5000,
    5: 10000,
    6: 20000,
    7: 35000,
    8: 50000,
    9: 75000,
    10: 100000,
  };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserReward>(
      stream: RewardService().userRewardsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error in StreamBuilder: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Error loading rewards'),
                ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Return to Login'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final rewards = snapshot.data!;
        final currentUser = FirebaseAuth.instance.currentUser;
        final userName = currentUser?.displayName ?? "User";

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Points Card
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: const Color(0xFF3A5EF0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            userName,
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current XP',
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${rewards.xp}',
                                style: GoogleFonts.nunito(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Points: ${rewards.points}',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: rewards.levelProgress,
                              backgroundColor: Colors.blue[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rewards.levelName,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${rewards.xpToNextLevel} XP to next level',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rewards.levelDescription,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      child: SvgPicture.asset(
                        'lib/images/medal.svg',
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Daily & Weekly Rewards Section
              Text(
                'Daily Rewards',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Login Bonus section
                    ListTile(
                      leading: SvgPicture.asset(
                        'lib/assets/icons/calendar.svg',
                        width: 30,
                        height: 30,
                        colorFilter: ColorFilter.mode(
                          Colors.amber,
                          BlendMode.srcIn,
                        ),
                      ),
                      title: const Text('Daily Login Bonus'),
                      subtitle: const Text(
                        'Points increase with daily streaks',
                      ),
                      trailing: ElevatedButton(
                        onPressed: rewards.canClaimDailyBonus
                            ? () async {
                                final points = await RewardService().claimLoginBonus();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'You received $points points!',
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: rewards.canClaimDailyBonus
                              ? const Color(0xFF3A5EF0)
                              : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          rewards.canClaimDailyBonus ? 'Claim' : 'Claim',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Divider(),

                    // Weekly streak header
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                      ),
                      child: Text(
                        'Weekly Login Streak',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3A5EF0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Text(
                        'Log in daily to earn increasing rewards!',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),

                    // Weekly streak indicator
                    _buildWeeklyStreakIndicator(rewards),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Redeem Points Section
              _buildRewardsSection(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyStreakIndicator(UserReward rewards) {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final registrationDate = rewards.registrationDate;

    // Calculate the first day of the week containing registration date
    final firstDayOfWeek = registrationDate.subtract(
      Duration(days: registrationDate.weekday - 1),
    );
    final daysSinceRegistration = now.difference(firstDayOfWeek).inDays;
    final currentWeekNumber = (daysSinceRegistration / 7).floor();

    // Calculate the current day's index (0-6) based on registration date
    final currentDayIndex = (now.weekday - 1 + (currentWeekNumber * 7)) % 7;

    return Column(
      children: [
        // Current streak indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(
                '${rewards.currentStreak} Day Streak',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        // Weekly days indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final bool isClaimed = rewards.weeklyClaimedDays.contains(index);
              final bool isToday = index == currentDayIndex;
              final int dayPoints = rewards.getPointsForStreakDay();
              final int dayXp = rewards.getXpForStreakDay();

              return Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isClaimed
                              ? Colors.green
                              : (isToday ? Colors.blue[100] : Colors.grey[200]),
                          border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
                        ),
                        child: isClaimed
                            ? const Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [          
                                    Text(
                                      '+$dayXp XP',
                                      style: GoogleFonts.nunito(
                                        color: isToday ? Colors.blue : Colors.grey[600],
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      if (isToday && !isClaimed)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weekDays[index],
                    style: GoogleFonts.nunito(
                      color: isToday ? Colors.blue : Colors.grey[700],
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Redeem Points',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _RewardCard(
                title: 'Free Audiobook',
                points: 450,
                description: 'Redeem for any audiobook',
                onRedeem: () => _redeemReward(context, 450),
              ),
              const SizedBox(width: 12),
              _RewardCard(
                title: 'Ad-Free Hour',
                points: 50,
                description: 'Enjoy 1 hour of ad-free listening',
                onRedeem: () => _redeemReward(context, 50),
              ),
              const SizedBox(width: 12),
              _RewardCard(
                title: '15% Off Premium',
                points: 200,
                description: 'Discount on premium subscription',
                onRedeem: () => _redeemReward(context, 200),
              ),
              const SizedBox(width: 12),
              _RewardCard(
                title: 'Ad-Free Week',
                points: 300,
                description: 'Enjoy ad-free listening for a week',
                onRedeem: () => _redeemReward(context, 300),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _redeemReward(BuildContext context, int points) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Reward'),
        content: Text(
          'Are you sure you want to redeem this reward for $points points?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await RewardService().redeemPointsWithTransaction(points);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reward redeemed successfully!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }
}

class _RewardCard extends StatelessWidget {
  final String title;
  final int points;
  final String description;
  final VoidCallback onRedeem;

  const _RewardCard({
    required this.title,
    required this.points,
    required this.description,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onRedeem,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$points pts',
                  style: GoogleFonts.poppins(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
