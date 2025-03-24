import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RedeemRewardsPage extends StatelessWidget {
  const RedeemRewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Available Rewards',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Categories in a single row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _CategoryChip(label: 'All', isSelected: true),
                  const SizedBox(width: 8),
                  _CategoryChip(label: 'Books'),
                  const SizedBox(width: 8),
                  _CategoryChip(label: 'Premium'),
                  const SizedBox(width: 8),
                  _CategoryChip(label: 'Gift Cards'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Vertical scrollable grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return _EnhancedRewardCard(
                    title: _getRewardTitle(index),
                    points: _getRewardPoints(index),
                    iconData: _getRewardIcon(index),
                    onRedeem:
                        () => _redeemReward(context, _getRewardPoints(index)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRewardTitle(int index) {
    final titles = [
      'Free Audiobook',
      'Premium Month',
      '50% Off Coupon',
      '\$5 Gift Card',
      '\$10 Gift Card',
      'Special Badge',
    ];
    return titles[index];
  }

  int _getRewardPoints(int index) {
    final points = [1000, 2000, 500, 2500, 4500, 300];
    return points[index];
  }

  IconData _getRewardIcon(int index) {
    final icons = [
      Icons.book,
      Icons.star,
      Icons.local_offer,
      Icons.card_giftcard,
      Icons.card_giftcard,
      Icons.emoji_events,
    ];
    return icons[index];
  }

  void _redeemReward(BuildContext context, int points) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Redeeming $points points')));
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _CategoryChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {},
      ),
    );
  }
}

class _EnhancedRewardCard extends StatelessWidget {
  final String title;
  final int points;
  final IconData iconData;
  final VoidCallback onRedeem;

  const _EnhancedRewardCard({
    required this.title,
    required this.points,
    required this.iconData,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onRedeem,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, size: 40, color: Colors.blue),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$points pts',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onRedeem,
                child: const Text('Redeem'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 36),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
