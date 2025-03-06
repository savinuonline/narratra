import 'package:flutter/material.dart';
import '../../../services/reward_service.dart';
import '../../../models/user_reward.dart';

class ReferralTab extends StatefulWidget {
  const ReferralTab({super.key});

  @override
  _ReferralTabState createState() => _ReferralTabState();
}

class _ReferralTabState extends State<ReferralTab> {
  late RewardService _rewardService;
  UserReward? _userReward;
  bool _isLoading = true;
  String? _referralLink;
  
  @override
  void initState() {
    super.initState();
    _rewardService = RewardService();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final rewards = await _rewardService.getUserRewards();
      final link = await _rewardService.createReferralLink();
      setState(() {
        _userReward = rewards;
        _referralLink = link;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
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
                  Icon(Icons.group_add, size: 48, color: Theme.of(context).primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Invite Friends & Earn Points',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'For each friend who joins using your link, you\'ll earn 100 points!',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'You have invited: ${_userReward?.referrals.length ?? 0} friends',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          if (_referralLink != null) ...[
            Text(
              'Your Referral Link:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _referralLink!,
                      style: TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      // Implement copy to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Link copied to clipboard')),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            ElevatedButton.icon(
              icon: Icon(Icons.share),
              label: Text('Share Your Referral Link'),
              onPressed: () => _rewardService.shareReferralLink(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}