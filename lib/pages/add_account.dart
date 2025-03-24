import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class AddAccount extends StatelessWidget {
  const AddAccount({super.key});

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
          "Add Account", style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
        ),
      ),
    );  
  }
}