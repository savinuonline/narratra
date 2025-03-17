import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SubscriptionPage(),
    );
  }
}

class SubscriptionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Your Plan'),
      ),
      body: ListView(
        children: [
          SubscriptionPlanCard(
            title: 'Free',
            price: 'Rs.0/month',
            features: [
              'Access to Selected Audiobooks',
              'Basic Audio Quality',
              'Ad-Supported Listening',
              'Mobile App Access',
              'Basic Recommendations',
            ],
          ),
          SubscriptionPlanCard(
            title: 'Premium',
            price: 'Rs.699/month',
            features: [
              'Unlimited access to all audiobooks',
              'High Quality audio (330kps)',
              'Ad-free Experience',
              'Offline Listening',
              'Adaptive recommendations',
              'Multiple voice options',
              'Priority access to new features',
            ],
          ),
          // if there are more packages can be added here
        ],
      ),
    );
  }
}

class SubscriptionPlanCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;

  SubscriptionPlanCard({
    required this.title,
    required this.price,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              price,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 16),
            ...features.map((feature) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('• $feature'),
            )).toList(),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle the get started button press
                },
                child: Text('Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}