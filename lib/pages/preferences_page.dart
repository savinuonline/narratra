import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PreferencesPage extends StatelessWidget {
  PreferencesPage({super.key});

  final user = FirebaseAuth.instance.currentUser;

  //Sign user out
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Center(
        child: Text(
          "LOGGED IN AS: ${user?.email!}",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
