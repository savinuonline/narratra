// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/reward_service.dart';
import '../../models/user_reward.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class PointsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<UserReward>(
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
                                  'Current Points',
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${rewards.points}',
                                  style: GoogleFonts.nunito(
                                    fontSize: 24,
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
                                minHeight: 10,
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

                // Weekly streak indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (index) {
                    // Determine if this day has been claimed
                    final bool isClaimed = rewards.weeklyClaimedDays.contains(
                      index,
                    );
                    final bool isToday = rewards.currentStreak == index;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isClaimed ? Colors.green : Colors.grey[300],
                              border:
                                  isToday
                                      ? Border.all(color: Colors.blue, width: 2)
                                      : null,
                            ),
                            child:
                                isClaimed
                                    ? const Center(
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    )
                                    : Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color:
                                              isToday
                                                  ? Colors.blue
                                                  : Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
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
                    );
                  }),
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
                            SvgPicture.asset(
                              'lib/assets/icons/gift_card.svg',
                              width: 24,
                              height: 48,
                              color: Color.fromARGB(255, 23, 132, 221),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Share with friends',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Both you and your friend get a free audiobook!',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    () => _generateAndShareInviteCode(context),
                                icon: const Icon(Icons.share),
                                label: const Text('Share Invite'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 44),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showRedeemDialog(context),
                                icon: const Icon(Icons.redeem),
                                label: const Text('Redeem Code'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 47),
                                ),
                              ),
                            ),
                          ],
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
                    trailing: FutureBuilder<bool>(
                      future: RewardService().canClaimDailyBonus(),
                      builder: (context, canClaimSnapshot) {
                        final bool canClaim = canClaimSnapshot.data ?? false;

                        return ElevatedButton(
                          onPressed:
                              canClaim
                                  ? () async {
                                    final points =
                                        await RewardService().claimLoginBonus();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'You received $points points!',
                                        ),
                                      ),
                                    );
                                  }
                                  : null, // Button disabled when canClaim is false
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3A5EF0),
                          ),
                          child: Text(
                            'Claim Daily Bonus',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
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

  Future<void> _generateAndShareInviteCode(BuildContext context) async {
    try {
      final inviteCode = await RewardService().generateInviteCode();
      final message =
          'Join me on Narratra! Use my invite code: $inviteCode\n'
          'We both get a free audiobook when you sign up!';

      await Share.share(message, subject: 'Get a free audiobook on Narratra!');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate invite code: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _showRedeemDialog(BuildContext context) async {
    final TextEditingController codeController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Redeem Invite Code'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter the 8-digit invite code from your friend'),
                const SizedBox(height: 12),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Invite Code',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    LengthLimitingTextInputFormatter(8),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    letterSpacing: 4,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                  if (codeController.text.length == 8) {
                    Navigator.pop(context, codeController.text);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid 8-digit code'),
                      ),
                    );
                  }
                },
                child: const Text('Redeem'),
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      try {
        await RewardService().redeemInviteCode(result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Success! You received a free audiobook!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

class RedeemRewardsPage extends StatelessWidget {
  const RedeemRewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Rewards',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white12,
      ),
      body: SingleChildScrollView(
        // Scrollable content
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
