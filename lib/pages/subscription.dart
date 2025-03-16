import 'package:flutter/material.dart';

class SubscriptionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

  
      appBar: AppBar(),
      body: SingleChildScrollView(
      
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.arrow_back, color: Colors.black,),
              Center(
                child: Text(
                  'Become a Premium',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Adjust color if needed
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Get access to the Premium Features of Narratra and feel the Book',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey, // Adjust color if needed
                  ),
                ),
              ),
              SizedBox(height: 40),
              SubscriptionOption(
                title: 'Free',
                price: 'Rs.0/month',
                description: 'Perfect for Casual Listeners',
              ),
              Divider(height: 20, thickness: 1),
              SubscriptionOption(
                title: 'Premium',
                price: 'Rs.699/month',
                description: 'Most Popular Choice',
              ),
              Divider(height: 20, thickness: 1),
              SubscriptionOption(
                title: 'Premium (Family)',
                price: 'Rs.1299/month',
                description: 'Best Values for Families',
              ),
              Divider(height: 20, thickness: 1),
              const Center(
                child: Text(
                  'Cancel Anytime ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey, // Adjust color if needed
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Restore Purchases ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey, // Adjust color if needed
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubscriptionOption extends StatelessWidget {
  final String title;
  final String price;
  final String description;

  SubscriptionOption({
    required this.title,
    required this.price,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: 180, // Set a fixed height for the card
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            // Position the button in the center-right with an offset
            Positioned(
              right: -50, // Align to the right
              top: 80, // Adjust this value to move the button up or down
              child: ElevatedButton(
                onPressed: () {
                  // Add subscribe logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Features'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}