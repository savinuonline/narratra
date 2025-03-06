import 'package:flutter/material.dart';
import '../../../services/reward_service.dart';
import '../../../models/user_reward.dart';

class GoalsTab extends StatefulWidget {
  const GoalsTab({super.key});

  @override
  _GoalsTabState createState() => _GoalsTabState();
}

class _GoalsTabState extends State<GoalsTab> {
  late RewardService _rewardService;
  UserReward? _userReward;
  bool _isLoading = true;
  final _goalController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _rewardService = RewardService();
    _loadGoals();
  }
  
  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }
  
  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);
    try {
      final rewards = await _rewardService.getUserRewards();
      setState(() {
        _userReward = rewards;
        _goalController.text = rewards.dailyGoal.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _updateGoal() async {
    final newGoal = int.tryParse(_goalController.text);
    if (newGoal != null && newGoal > 0) {
      try {
        await _rewardService.updateDailyGoal(newGoal);
        await _loadGoals();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Daily goal updated')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating goal')),
        );
      }
    }
  }
  
  Future<void> _updateProgress(int increment) async {
    try {
      await _rewardService.updateGoalProgress(increment);
      await _loadGoals();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating progress')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (_userReward == null) {
      return Center(child: Text('No goal data available'));
    }
    
    final progress = _userReward!.goalProgress;
    final progressPercent = (progress * 100).toStringAsFixed(1);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Daily Goal Progress',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                      Text(
                        '$progressPercent%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${_userReward!.dailyGoalProgress} / ${_userReward!.dailyGoal}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _updateProgress(1),
                        child: Text('+1'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _updateProgress(5),
                        child: Text('+5'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _updateProgress(10),
                        child: Text('+10'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          Text(
            'Set Your Daily Goal',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _goalController,
                  decoration: InputDecoration(
                    labelText: 'Daily Goal',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: _updateGoal,
                child: Text('Save'),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          Text(
            'Tip: You earn 1 point for each 1% of your daily goal completed!',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}