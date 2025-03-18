import 'package:flutter/material.dart';
import 'package:frontend/pages/FreePlan_Page.dart';


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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
            onPressed: () {
            // Handle the back button press
            Navigator.pop(context); // Navigate back to the previous screen
          },
        )
      ),
      body: Column(
        children: [
          // Add "Become a Premium" text at the top
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
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
SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Free',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Rs.0/month',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text('Upstream'),
                    Text('Preheat for Casual Liaverns'),
                    Text('Access to Selected Audbooks'),
                    Text('Basic Audio Quality'),
                    Text('Ad-Supported Listening'),
                    Text('Mobile App access'),
                    Text('Basic Recommendations'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FreePlanPage()),
                        );
                      },
                      child: Text('Get Started'),
                    ),
                  ],
                ),
              ),
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
      color: title == 'Premium' ? const Color.fromARGB(255, 53, 68, 227) : Colors.white, // Set background color for Premium card
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: title == 'Premium' ? Colors.white : Colors.black, // Set text color for Premium card
              ),
            ),
            SizedBox(height: 8),
            
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: price.split('/')[0], // Extract the numeric part
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold, 
                      color: title == 'Premium' ? Colors.white : const Color.fromARGB(255, 0, 0, 0), // Set text color for Premium card
                    ),
                  ),
                  TextSpan(
                    text: '/${price.split('/')[1]}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal, 
                      color: title == 'Premium' ? Colors.white : Colors.grey, // Set text color for Premium card
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ...features.map((feature) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.check, color: title == 'Premium' ? Colors.white : const Color.fromARGB(255, 0, 0, 0)), // Set icon color for Premium card
                  SizedBox(width: 8),
                  Text(
                    feature,
                    style: TextStyle(
                      color: title == 'Premium' ? Colors.white : Colors.black, // Set text color for Premium card
                    ),
                  ),
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
                  backgroundColor: title == 'Premium' ? Colors.white : const Color.fromARGB(255, 53, 68, 227), // Set button color for Premium card
                ),
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    color: title == 'Premium' ? const Color.fromARGB(255, 53, 68, 227) : Colors.white, // Set text color for Premium card
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}