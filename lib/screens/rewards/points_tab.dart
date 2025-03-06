import 'package:flutter/material.dart';
import '../../../services/reward_service.dart';
import '../../../models/user_reward.dart';
import '../../../widgets/redeem_points_item.dart';

class PointsTab extends StatefulWidget {
  const PointsTab({super.key});

  @override
  _PointsTabState createState() => _PointsTabState();
}

class _PointsTabState extends State<PointsTab> {
  late RewardService _rewardService;
  UserReward? _userReward;
  bool _isLoading = true;
  String _message = '';
  
  @override
  void initState() {
    super.initState();
    _rewardService = RewardService();
    _loadRewards();
  }
  
  Future<void> _loadRewards() async {
    setState(() => _isLoading = true);
    try {
      final rewards = await _rewardService.getUserRewards();
      setState(() {
        _userReward = rewards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Error loading rewards: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _claimDailyBonus() async {
    try {
      final pointsAwarded = await _rewardService.claimDailyLoginBonus();
      if (pointsAwarded > 0) {
        setState(() {
          _message = 'Daily bonus claimed! +$pointsAwarded points';
        });
        await _loadRewards();
      } else {
        setState(() {
          _message = 'You already claimed your daily bonus today.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error claiming bonus: $e';
      });
    }
  }
  
  Future<void> _redeemPoints(int points) async {
    try {
      final success = await _rewardService.redeemPoints(points);
      if (success) {
        setState(() {
          _message = 'Successfully redeemed $points points!';
        });
        await _loadRewards();
      } else {
        setState(() {
          _message = 'Not enough points to redeem.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error redeeming points: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (_userReward == null) {
      return Center(child: Text('No reward data available'));
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Level and points card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Level ${_userReward!.level}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_userReward!.points} Points',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: 1 - (_userReward!.pointsToNextLevel / (1000.0)),
                    minHeight: 10,
                  ),
                  SizedBox(height: 8),
                  Text('${_userReward!.pointsToNextLevel} points to next level'),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Daily login bonus
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Claim Daily Bonus'),
            onPressed: _claimDailyBonus,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          
          if (_message.isNotEmpty) ...[
            SizedBox(height: 16),
            Text(
              _message,
              style: TextStyle(
                color: _message.contains('Error') ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          SizedBox(height: 24),
          
          // Redeem points section
          Text(
            'Redeem Your Points',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          
          RedeemPointsItem(
            title: '1 Week Premium',
            points: 500,
            onRedeem: () => _redeemPoints(500),
            isEnabled: _userReward!.points >= 500,
          ),
          
          RedeemPointsItem(
            title: '1 Month Premium',
            points: 1500,
            onRedeem: () => _redeemPoints(1500),
            isEnabled: _userReward!.points >= 1500,
          ),
          
          RedeemPointsItem(
            title: 'Special Badge',
            points: 300,
            onRedeem: () => _redeemPoints(300),
            isEnabled: _userReward!.points >= 300,
          ),
        ],
      ),
    );
  }
}