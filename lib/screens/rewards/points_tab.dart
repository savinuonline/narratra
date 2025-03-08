import 'package:flutter/material.dart';
import '../../services/reward_service.dart';
import '../../models/user_reward.dart';

class PointsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserReward>(
      stream: RewardService().userRewardsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final rewards = snapshot.data!;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Points Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade900],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Points',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        '${rewards.points}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Level ${rewards.level}',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value:
                            1 -
                            (rewards.pointsToNextLevel /
                                (rewards.level * 1000)),
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${rewards.pointsToNextLevel} points to next level',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Daily Bonus Section
              Text(
                'Daily Rewards',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: Colors.amber),
                  title: Text('Daily Login Bonus'),
                  subtitle: Text('50 points'),
                  trailing: ElevatedButton(
                    onPressed:
                        rewards.canClaimDailyBonus
                            ? () => RewardService().claimDailyLoginBonus()
                            : null,
                    child: Text('Claim'),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Redeem Points Section
              Text(
                'Redeem Points',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _RewardCard(
                    title: 'Free Audiobook',
                    points: 1000,
                    onRedeem: () => _redeemReward(context, 1000),
                  ),
                  _RewardCard(
                    title: 'Premium Month',
                    points: 2000,
                    onRedeem: () => _redeemReward(context, 2000),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _redeemReward(BuildContext context, int points) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Redeem Reward'),
            content: Text(
              'Are you sure you want to redeem this reward for $points points?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Redeem'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final success = await RewardService().redeemPoints(points);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Reward redeemed successfully!' : 'Not enough points',
          ),
        ),
      );
    }
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
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                '$points pts',
                style: TextStyle(
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
