import 'package:flutter/material.dart';

class MediaPlayerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 3, 21, 46), // Dark Blue (Top)
              Color.fromARGB(255, 202, 218, 234), // Light Blue (Bottom)
            ],
            stops: [0.3, 1.0], // Adjusted for smoother transition
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 40), // Space for status bar
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                "PLAYING NOW",
                style: TextStyle(
                  fontSize: 18,
                  color: const Color.fromARGB(255, 234, 234, 240),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Spacer(), // Pushes content to center
            Text(
              "Media Player Page",
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
