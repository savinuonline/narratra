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
      body: Column(
        children: [
          // Add "Become a Premium" text at the top
          Padding(
            padding: EdgeInsets.only(top: 90, bottom: 4),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Become a Premium',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Get access to the Premium Features of Narratra and the feel the Book',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center, // Center the text
                  ),
                ],
              ),
            ),
          ),
Expanded(
            child: ListView(
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
                SubscriptionPlanCard(
                  title: 'Premium (Family)',
                  price: 'Rs.1299/month',
                  features: [
                    'Everything in Premium',
                    'Up to 6 family accounts',
                    'Family Dashboard',
                    'Parental controls',
                    'Shared Playlists',
                    'Family audiobook recommendations',
                  ],
                ),
              ],
            ),
          ),
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
              style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 0, 0, 0)),
            ),
            SizedBox(height: 16),
            ...features.map((feature) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.check, color: const Color.fromARGB(255, 0, 0, 0)),
                  SizedBox(width: 8),
                  Text(feature),
                ],
              ),
            )).toList(),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle the get started button press
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  'Get Started',
                  style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}