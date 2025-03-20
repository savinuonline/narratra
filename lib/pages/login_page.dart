import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/my_button.dart';
import 'package:frontend/components/my_textfield.dart';
import 'package:frontend/components/squre_tile.dart';
import 'package:frontend/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //sign user in method
  void signUserIn() async {
    // Validate inputs
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showErrorMessage('Please fill in all fields');
      return;
    }

    //show loading circle
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Sign in with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Pop loading circle if successful
      if (context.mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      // Pop loading circle
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (e.code == 'user-not-found') {
        // Show dialog asking if they want to register
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Account Not Found'),
                content: const Text(
                  'No account found under that email! Would you like to register?',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onTap?.call(); // Switch to registration page
                    },
                    child: const Text('Register'),
                  ),
                ],
              );
            },
          );
        }
      } else if (e.code == 'wrong-password') {
        showErrorMessage('Incorrect password');
      } else if (e.code == 'invalid-email') {
        showErrorMessage('Invalid email format');
      } else if (e.code == 'user-disabled') {
        showErrorMessage('This account has been disabled');
      } else {
        showErrorMessage('An error occurred while signing in: ${e.message}');
      }
    } catch (e) {
      // Pop loading circle
      if (context.mounted) {
        Navigator.pop(context);
      }
      showErrorMessage('An unexpected error occurred: $e');
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
                const SizedBox(height: 15),
                //logo
                Image.asset('lib/images/BlackLogo.png', height: 100),

                const SizedBox(height: 35),
                //welcome back
                Text(
                  'Welcome back, you\'ve been missed!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),

                const SizedBox(height: 25),
                //email textfield
                MyTextField(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 10),

                //password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),

                const SizedBox(height: 10),
                //forgot password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                //sign in button
                MyButton(text: "Log In", onTap: signUserIn),

                const SizedBox(height: 30),
                //or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          "Or continue with",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),

                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                //google + apple sign in buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Google
                    SqureTile(
                      onTap: () => AuthService().signInWithGoogle(),
                      imagePath: 'lib/images/GoogleLogo.png',
                    ),

                    const SizedBox(width: 10),

                    //Apple
                    SqureTile(
                      onTap: () => {},
                      imagePath: 'lib/images/AppleLogo.png',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                //not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Register now!",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
