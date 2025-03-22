import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/my_button.dart';
import 'package:frontend/components/my_textfield.dart';
import 'package:frontend/components/squre_tile.dart';
import 'package:frontend/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isPasswordValid = false;
  String passwordError = '';

  // Password validation criteria
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasDigit = false;
  bool hasSpecialChar = false;

  void checkPassword(String password) {
    print("Password Changed: $password");
    setState(() {
      hasMinLength = password.length >= 8;
      hasUppercase = password.contains(RegExp(r'[A-Z]'));
      hasLowercase = password.contains(RegExp(r'[a-z]'));
      hasDigit = password.contains(RegExp(r'[0-9]'));
      hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      isPasswordValid =
          hasMinLength &&
          hasUppercase &&
          hasLowercase &&
          hasDigit &&
          hasSpecialChar;
    });
  }

  // sign user up method
  void signUserUp() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Validate fields
      if (firstNameController.text.isEmpty ||
          lastNameController.text.isEmpty ||
          usernameController.text.isEmpty ||
          contactController.text.isEmpty) {
        throw 'Please fill in all fields';
      }

      // Check if passwords match
      if (passwordController.text != confirmPasswordController.text) {
        throw 'Passwords don\'t match';
      }

      if (!isPasswordValid) {
        throw 'Password does not meet security requirements';
      }

      // Check if email exists and get sign-in methods
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
        emailController.text.trim(),
      );

      // If the email exists but has no sign-in methods, delete it from authentication
      if (methods.isNotEmpty) {
        try {
          // Try to sign in with email to get the user
          final userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                email: emailController.text.trim(),
                password:
                    'dummy-password', // This will likely fail, which is expected
              );

          // If we somehow got here, delete the user
          await userCredential.user?.delete();
        } catch (e) {
          // Ignore sign-in errors as we expect them
        }
      }

      // Create new user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );

      // After creating the user, store additional info in Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .set({
            'firstName': firstNameController.text,
            'lastName': lastNameController.text,
            'username': usernameController.text,
            'contact': contactController.text,
            'email': emailController.text,
            'userId': userCredential.user!.uid,
            'preferences': [],
            'createdAt': Timestamp.now(),
          });

      // Pop loading circle
      if (context.mounted) Navigator.pop(context);

      // Show success message
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Account created successfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to preferences page with user ID
                    Navigator.pushReplacementNamed(
                      context,
                      '/preferences',
                      arguments: {'uid': userCredential.user!.uid},
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      // Pop loading circle
      Navigator.pop(context);
      String errorMessage = 'An error occurred';

      if (e.code == 'email-already-in-use') {
        errorMessage =
            'This email is already registered. Please try signing in or use a different email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak';
      }

      showErrorMessage(errorMessage);
    } catch (e) {
      // Pop loading circle
      Navigator.pop(context);
      showErrorMessage(e.toString());
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 25),

                // Logo
                Image.asset('lib/images/LogoBlue.png', height: 100),

                const SizedBox(height: 25),

                Text(
                  'Let\'s create an account for you!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),

                const SizedBox(height: 25),

                // First Name
                MyTextField(
                  controller: firstNameController,
                  hintText: 'First Name',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Last Name
                MyTextField(
                  controller: lastNameController,
                  hintText: 'Last Name',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Username
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Contact
                MyTextField(
                  controller: contactController,
                  hintText: 'Contact Number',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Email
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Password
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  onChanged: checkPassword,
                ),

                const SizedBox(height: 10),

                // Confirm Password
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 20),

                // Password requirements
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Requirements:',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildRequirement('At least 8 characters', hasMinLength),
                      _buildRequirement('One uppercase letter', hasUppercase),
                      _buildRequirement('One lowercase letter', hasLowercase),
                      _buildRequirement('One number', hasDigit),
                      _buildRequirement(
                        'One special character',
                        hasSpecialChar,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Sign Up Button
                MyButton(text: "Sign Up", onTap: signUserUp),

                const SizedBox(height: 25),

                // Already have an account?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Login now!!",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          color: isMet ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
      ],
    );
  }
}
