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
                price: 'Rs.499/month',
                description: 'Most Popular Choice',
              ),
              Divider(height: 20, thickness: 1),
              SubscriptionOption(
                title: 'Premium',
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
      elevation: 4, // Adds shadow to the card
      margin: EdgeInsets.symmetric(vertical: 10), // Adds margin around the card
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Adjust color if needed
              ),
            ),
            SizedBox(height: 35),
            Text(
              price,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Adjust color if needed
              ),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey, // Adjust color if needed
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add subscribe logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button background color
                  foregroundColor: Colors.white, // Button text color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Subscribe'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}