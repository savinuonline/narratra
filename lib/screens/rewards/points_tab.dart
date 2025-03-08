import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/reward_service.dart';
import '../../models/user_reward.dart';
import 'package:share_plus/share_plus.dart';

class PointsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<UserReward>(
        stream: RewardService().userRewardsStream,
        builder: (context, snapshot) {
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
                            Row(
                              // Row for Points and value
                              children: [
                                Text(
                                  'Current Points',
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ), // Space between "Current Points" and the number
                                Text(
                                  '${rewards.points}',
                                  style: GoogleFonts.nunito(
                                    fontSize: 24, // Match username size
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              // Rounded corners for progress bar
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: _calculateProgressToNextLevel(rewards),
                                backgroundColor: Colors.blue[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                minHeight: 10, // Slightly thicker bar
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              // Level and points to next level
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Level ${rewards.level}',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  '${_calculatePointsToNextLevel(rewards)} points to next level',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
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
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Referral Section
                Text(
                  'Refer & Earn',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.people, // Hugging People Icon
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Share with friends',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Both you and your friend get bonus points!',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _shareReferralLink(context),
                          icon: const Icon(Icons.share),
                          label: const Text('Share Referral Link'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Daily Bonus Section
                Text(
                  'Daily Rewards',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ), // Poppins font
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Colors.amber,
                    ),
                    title: const Text('Daily Login Bonus'),
                    subtitle: const Text('50 points'),
                    trailing: ElevatedButton(
                      onPressed:
                          RewardService().isSameDay(
                                rewards.lastLoginBonusDate,
                                DateTime.now(),
                              )
                              ? null
                              : () async {
                                final bonus =
                                    await RewardService()
                                        .claimDailyLoginBonus();
                                if (bonus > 0 && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Claimed $bonus points for daily login!',
                                      ),
                                    ),
                                  );
                                }
                              },
                      child: const Text('Claim'),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Redeem Points Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Redeem Points',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RedeemRewardsPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'See More',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _RewardCard(
                        title: 'Free Audiobook',
                        points: 1000,
                        onRedeem: () => _redeemReward(context, 1000),
                      ),
                      const SizedBox(width: 12),
                      _RewardCard(
                        title: 'Premium Month',
                        points: 2000,
                        onRedeem: () => _redeemReward(context, 2000),
                      ),
                      const SizedBox(width: 12),
                      _RewardCard(
                        title: '50% Off Coupon',
                        points: 500,
                        onRedeem: () => _redeemReward(context, 500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _shareReferralLink(BuildContext context) async {
    try {
      final referralLink =
          await RewardService().createReferralLink(); // Get the dynamic link
      final message =
          'Join me on Narratra! Use my referral link: $referralLink\n'
          'Download the app now and get bonus points!';

      await Share.share(message, subject: 'Get bonus points on Narratra!');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate referral link')),
        );
      }
    }
  }

  Future<void> _redeemReward(BuildContext context, int points) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
  }

  // Helper function to calculate points to next level
  int _calculatePointsToNextLevel(UserReward rewards) {
    int nextLevelPoints = (rewards.level) * 1000;
    return nextLevelPoints - rewards.points;
  }

  // Helper function to calculate progress within the current level
  double _calculateProgressToNextLevel(UserReward rewards) {
    int nextLevelPoints =
        (rewards.level) * 1000; // Points needed for *next* level
    int currentLevelBasePoints = (rewards.level - 1) * 1000;
    if (rewards.points >= nextLevelPoints) {
      return 0.0; // Already at or above next level
    }
    return (rewards.points - currentLevelBasePoints) /
        (nextLevelPoints - currentLevelBasePoints).toDouble();
  }
}

class RedeemRewardsPage extends StatelessWidget {
  const RedeemRewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redeem Rewards'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        // Scrollable content
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Horizontal Scrollable Rewards
            SizedBox(
              height: 160, // Adjust the height as needed
              child: ListView(
                scrollDirection: Axis.horizontal, // Horizontal scrolling
                children: [
                  _RewardCard(
                    title: 'Free Audiobook',
                    points: 1000,
                    onRedeem: () {},
                  ),
                  _RewardCard(
                    title: 'Premium Month',
                    points: 2000,
                    onRedeem: () {},
                  ),
                  _RewardCard(
                    title: '50% Off Coupon',
                    points: 500,
                    onRedeem: () {},
                  ),

                  // Add more reward cards here
                ],
              ),
            ),
            const SizedBox(
              height: 24,
            ), // Add space between horizontal and grid view
            // Grid View for other Rewards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _RewardCard(
                  title: 'Gift Card \$5',
                  points: 2500,
                  onRedeem: () {},
                ),
                _RewardCard(
                  title: 'Gift Card \$10',
                  points: 4500,
                  onRedeem: () {},
                ),
                // Add more rewards for the grid view
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final String title;
  final int points;
  final VoidCallback onRedeem;

  const _RewardCard({
    required this.title,
    required this.points,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onRedeem,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$points pts',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
