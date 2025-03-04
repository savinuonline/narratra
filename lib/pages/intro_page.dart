import 'package:flutter/material.dart';
import 'package:frontend/pages/login_page.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          //logo
          Padding(
            padding: const EdgeInsets.only(
              left: 70.0,
              right: 70.0,
              bottom: 5,
              top: 50.0,
            ),
            child: Image.asset('lib/images/Books.png'),
          ),

          //Brand Caption
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '"Close Your Eyes and Let the Story Unfold!"',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          //Sub text
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              "Trending Books Everyday",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),

          const Spacer(),

          //Get started button
          GestureDetector(
            onTap:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const LoginPage();
                    },
                  ),
                ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(15),
              ),

              padding: const EdgeInsets.all(20),
              child: const Text(
                "Get Started",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
