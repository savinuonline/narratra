import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter email & password')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        // Optionally, set the display name
        await user.updateDisplayName(_displayNameController.text.trim());

        // Create/update user document in Firestore
        final userDoc = _firestore.collection('user_rewards').doc(user.uid);

        await userDoc.set({
          'userId': user.uid,
          'displayName': _displayNameController.text.trim(),
          'points': 0,
          'dailyGoal': 30, // default daily goal
          'dailyGoalProgress': 0,
          'freeAudiobooks': 0,
          'premiumAudiobooks': 0,
          // add other necessary default fields
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sign-up successful!')));

        // Navigate to your main page or dashboard
        // e.g., Navigator.pushNamed(context, '/rewardDashboard');
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Signup error')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(onPressed: _signUp, child: const Text('Sign Up')),
          ],
        ),
      ),
    );
  }
}
