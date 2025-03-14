import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class VoicePage extends StatelessWidget {
  const VoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Go back to previous page
          },
          icon: Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth:100,
        title: const Text(
          "Change Voice Actor", style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
        ),
      ),
    );  



  }
}