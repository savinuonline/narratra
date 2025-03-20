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
            stops: [0.3, 1.5],
          ),
        ),
        child: Center(
          child: Text(
            " media player page",
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
