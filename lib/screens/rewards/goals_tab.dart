import 'package:flutter/material.dart';
import '../../../services/reward_service.dart';
import '../../../models/user_reward.dart';

class GoalsTab extends StatelessWidget {
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
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Daily Reading Goal',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: rewards.goalProgress,
                        minHeight: 8,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${rewards.dailyGoalProgress} / ${rewards.dailyGoal} minutes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (rewards.goalProgress >= 1.0)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Goal completed! +100 points',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
}
