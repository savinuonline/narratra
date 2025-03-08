import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../services/reward_service.dart';

class ReferralTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.card_giftcard, size: 48, color: Colors.blue),
                  SizedBox(height: 16),
                  Text(
                    'Invite Friends',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Share Narratra with friends and both get rewards!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final link = await RewardService().createReferralLink();
                      Share.share(
                        'Join me on Narratra! Use my referral link: $link',
                      );
                    },
                    icon: Icon(Icons.share),
                    label: Text('Share Referral Link'),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          Text(
            'Referral Benefits',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 12),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.star, color: Colors.amber),
                    title: Text('You Get'),
                    subtitle: Text('100 points + 1 free audiobook'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.star, color: Colors.amber),
                    title: Text('Your Friend Gets'),
                    subtitle: Text('1 free audiobook to start'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
