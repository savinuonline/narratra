import 'package:flutter/material.dart';

class RedeemPointsItem extends StatelessWidget {
  final String title;
  final int points;
  final VoidCallback onRedeem;
  final bool isEnabled;
  
  const RedeemPointsItem({
    super.key,
    required this.title,
    required this.points,
    required this.onRedeem,
    required this.isEnabled,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text('$points points'),
        trailing: ElevatedButton(
          onPressed: isEnabled ? onRedeem : null,
          child: Text('Redeem'),
        ),
      ),
    );
  }
}