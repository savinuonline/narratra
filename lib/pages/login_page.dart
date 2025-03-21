import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/my_button.dart';
import 'package:frontend/components/my_textfield.dart';
import 'package:frontend/components/squre_tile.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final _authService = AuthService();
  bool _isLoading = false;
  bool _rememberMe = false;

  void showSuccessMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 50),
                const SizedBox(height: 20),
                FutureBuilder<DocumentSnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection('Users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      final username = userData?['username'] ?? 'User';
                      return Text(
                        'Welcome Back! $username!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                    return const Text('Loading...');
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'Successfully logged in',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 124, 166, 239),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showNoAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('No Account Found'),
          content: const Text(
            'There\'s no account associated with this email. Would you like to join us?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onTap?.call();
              },
              child: const Text('Sign Up'),
            ),
          ],
        );
      },
    );
  }

  void showGoogleSignInSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 50),
                const SizedBox(height: 20),
                const Text(
                  'Google Sign-In Successful!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Welcome to Narratra',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 124, 166, 239),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //sign user in method
  void signUserIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showErrorMessage('Please fill in all fields');
      return;
    }

    if (!emailController.text.contains('@')) {
      showErrorMessage('Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (result != null && mounted) {
        showSuccessMessage();

        // Check if user has completed registration
        final userDoc =
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(result.user!.uid)
                .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final preferences = userData['preferences'] as List<dynamic>?;

          if (preferences == null || preferences.isEmpty) {
            // Navigate to preferences selection if not set
            Navigator.pushReplacementNamed(
              context,
              '/preferences',
              arguments: {'uid': result.user!.uid},
            );
          } else {
            // Navigate to main screen if preferences are set
            Navigator.pushReplacementNamed(context, '/main');
          }
        } else {
          showErrorMessage('User data not found. Please try again.');
        }
      } else if (mounted) {
        // Check if the email exists in Firebase Auth
        try {
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(
            emailController.text.trim(),
          );
          showErrorMessage('Invalid password. Please try again.');
        } catch (e) {
          showNoAccountDialog();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = 'An error occurred during sign in.';
        switch (e.code) {
          case 'user-not-found':
            showNoAccountDialog();
            return;
          case 'wrong-password':
            message = 'Wrong password provided.';
            break;
          case 'invalid-email':
            message = 'Invalid email address.';
            break;
          case 'user-disabled':
            message = 'This account has been disabled.';
            break;
          case 'too-many-requests':
            message = 'Too many attempts. Please try again later.';
            break;
          default:
            message = e.message ?? 'An unexpected error occurred.';
        }
        showErrorMessage(message);
      }
    } catch (e) {
      if (mounted) {
        showErrorMessage('An unexpected error occurred: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Oops!'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Let\'s fix it!'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                //logo
                Image.asset('lib/images/LogoBlue.png', height: 100),

                const SizedBox(height: 35),
                //welcome back
                Text(
                  'Nice to see you again, We missed You!!',
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

                //"Remember me" and "Forgot Password?"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remember me
                      Transform.translate(
                        offset: const Offset(-10, 0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: const Color.fromARGB(
                                255,
                                12,
                                171,
                                245,
                              ),
                              checkColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-5, 0),
                              child: const Text('Remember me'),
                            ),
                          ],
                        ),
                      ),

                      // Forgot Password
                      GestureDetector(
                        onTap: () {
                          // Add your forgot password functionality here
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                //sign in button
                MyButton(
                  text: _isLoading ? "Signing in..." : "Log In",
                  onTap: _isLoading ? null : signUserIn,
                ),

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
                      onTap: () async {
                        final result = await AuthService().signInWithGoogle();
                        if (result != null && mounted) {
                          showGoogleSignInSuccess();

                          // Check if user has completed registration
                          final userDoc =
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(result.user!.uid)
                                  .get();

                          if (userDoc.exists) {
                            final userData =
                                userDoc.data() as Map<String, dynamic>;
                            final preferences =
                                userData['preferences'] as List<dynamic>?;

                            if (preferences == null || preferences.isEmpty) {
                              // Navigate to preferences selection if not set
                              Navigator.pushReplacementNamed(
                                context,
                                '/preferences',
                                arguments: {'uid': result.user!.uid},
                              );
                            } else {
                              // Navigate to main screen if preferences are set
                              Navigator.pushReplacementNamed(context, '/main');
                            }
                          } else {
                            // Create new user document if it doesn't exist
                            try {
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(result.user!.uid)
                                  .set({
                                    'firstName':
                                        result.user!.displayName
                                            ?.split(' ')
                                            .first ??
                                        '',
                                    'lastName':
                                        result.user!.displayName
                                            ?.split(' ')
                                            .last ??
                                        '',
                                    'username':
                                        result.user!.displayName?.replaceAll(
                                          ' ',
                                          '',
                                        ) ??
                                        '',
                                    'email': result.user!.email,
                                    'userId': result.user!.uid,
                                    'preferences': [],
                                    'createdAt': Timestamp.now(),
                                  });

                              // Navigate to preferences selection for new user
                              Navigator.pushReplacementNamed(
                                context,
                                '/preferences',
                                arguments: {'uid': result.user!.uid},
                              );
                            } catch (e) {
                              showErrorMessage(
                                'Error creating user profile: $e',
                              );
                            }
                          }
                        }
                      },
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
