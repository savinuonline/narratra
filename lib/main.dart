import 'package:flutter/material.dart';
import 'splashscreen.dart'; // Import the splash screen file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Narratra App',
      home: const SplashScreen(), // Only the splash screen is shown
    );
  }
}
