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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Reading Goal',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: rewards.goalProgress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${(rewards.goalProgress * 100).toInt()}% Complete',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '${rewards.dailyGoalProgress} / ${rewards.dailyGoal} minutes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              Text(
                'Set Daily Goal',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Slider(
                        value: rewards.dailyGoal.toDouble(),
                        min: 10,
                        max: 240,
                        divisions: 23,
                        label: '${rewards.dailyGoal} minutes',
                        onChanged: (value) {
                          RewardService().updateDailyGoal(value.toInt());
                        },
                      ),
                      Text(
                        'Slide to set your daily reading goal',
                        style: TextStyle(color: Colors.grey[600]),
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
