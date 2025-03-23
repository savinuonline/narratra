import 'package:flutter/material.dart';

class subscription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 380),
            Text(
              'Upgrade to Premium',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Text(
              'Unlimited Al Generations',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Unlimited Pro Sketches',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Adds Free!',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            // Premium Section with Blue Background
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Premium',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rs.699/month',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Premium (Family)',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '\Rs.1299/month',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle continue action
                },
                child: Text(
                  'Continue with Free Package',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  // Handle restore purchase action
                },
                child: Text('Restore Purchase'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}