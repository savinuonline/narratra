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

  Future showSuccessMessage() async {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(parent: animation1, curve: Curves.elasticOut),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation1, curve: Curves.easeOut),
            ),
            child: Dialog(
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
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Transform.rotate(
                            angle: (1 - value) * 2 * 3.14,
                            child: child,
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 50,
                      ),
                    ),
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
                          return TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 600),
                            tween: Tween<Offset>(
                              begin: const Offset(0, 30),
                              end: Offset.zero,
                            ),
                            builder: (context, Offset offset, child) {
                              return Transform.translate(
                                offset: offset,
                                child: Opacity(
                                  opacity: (30 - offset.dy) / 30,
                                  child: Text(
                                    'Welcome Back, $username!',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return const Text('Loading...');
                      },
                    ),
                    const SizedBox(height: 10),
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<Offset>(
                        begin: const Offset(0, 20),
                        end: Offset.zero,
                      ),
                      builder: (context, Offset offset, child) {
                        return Transform.translate(
                          offset: offset,
                          child: Opacity(
                            opacity: (20 - offset.dy) / 20,
                            child: const Text(
                              'Successfully logged in',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                foregroundColor: Colors.white,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  124,
                                  166,
                                  239,
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Continue'),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showNoAccountDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(parent: animation1, curve: Curves.elasticOut),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation1, curve: Curves.easeOut),
            ),
            child: Dialog(
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
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Transform.rotate(
                            angle: (1 - value) * 2 * 3.14,
                            child: child,
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.search_off,
                        color: Color.fromARGB(255, 124, 166, 239),
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 400),
                      tween: Tween<Offset>(
                        begin: const Offset(0, 30),
                        end: Offset.zero,
                      ),
                      builder: (context, Offset offset, child) {
                        return Transform.translate(
                          offset: offset,
                          child: Opacity(
                            opacity: (30 - offset.dy) / 30,
                            child: const Text(
                              'Oops! Who Are You?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<Offset>(
                        begin: const Offset(0, 20),
                        end: Offset.zero,
                      ),
                      builder: (context, Offset offset, child) {
                        return Transform.translate(
                          offset: offset,
                          child: Opacity(
                            opacity: (20 - offset.dy) / 20,
                            child: const Text(
                              'Sorry, I don\'t have your info...\nWould you like to join us?',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Maybe Later'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      124,
                                      166,
                                      239,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.onTap?.call();
                                  },
                                  child: const Text('Join Now!'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showIncompleteProfileDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation1, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation1, curve: Curves.easeOut),
            ),
            child: Dialog(
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
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.rotate(
                          angle: (1 - value) * 2 * 3.14,
                          child: Transform.scale(
                            scale:
                                value *
                                (1 + 0.2 * (1 - value)), // Add bounce effect
                            child: child,
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.face,
                        color: Color.fromARGB(255, 124, 166, 239),
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween<Offset>(
                        begin: const Offset(0, 30),
                        end: Offset.zero,
                      ),
                      builder: (context, Offset offset, child) {
                        return Transform.translate(
                          offset: offset,
                          child: Opacity(
                            opacity: (30 - offset.dy) / 30,
                            child: const Text(
                              'Almost There!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<Offset>(
                        begin: const Offset(0, 20),
                        end: Offset.zero,
                      ),
                      builder: (context, Offset offset, child) {
                        return Transform.translate(
                          offset: offset,
                          child: Opacity(
                            opacity: (20 - offset.dy) / 20,
                            child: const Text(
                              'We\'re missing some details about you.\nLet\'s make your profile awesome!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                foregroundColor: Colors.white,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  124,
                                  166,
                                  239,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onTap?.call();
                              },
                              child: const Text('Complete Profile'),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
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
      // Try to sign in directly
      final result = await _authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
        rememberMe: _rememberMe,
      );

      if (result != null && mounted) {
        // Check if user has completed registration
        final userDoc =
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(result.user!.uid)
                .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final preferences = userData['preferences'] as List<dynamic>?;

          // Show success message first
          await showSuccessMessage();

          if (preferences == null || preferences.isEmpty) {
            // Navigate to preferences selection if not set
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/preferences',
              (route) => false,
              arguments: {'uid': result.user!.uid},
            );
          } else {
            // Navigate to main screen if preferences are set
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main',
              (route) => false,
            );
          }
        } else {
          // User exists in Auth but not in Firestore
          // Create user document
          try {
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(result.user!.uid)
                .set({
                  'firstName': '',
                  'lastName': '',
                  'username': result.user!.email?.split('@')[0] ?? '',
                  'email': result.user!.email,
                  'userId': result.user!.uid,
                  'preferences': [],
                  'createdAt': Timestamp.now(),
                });

            // Navigate to preferences selection for new user
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/preferences',
              (route) => false,
              arguments: {'uid': result.user!.uid},
            );
          } catch (e) {
            showErrorMessage('Error creating user profile: $e');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        switch (e.code) {
          case 'user-not-found':
            showNoAccountDialog();
            break;
          case 'wrong-password':
            showErrorMessage('Incorrect password. Please try again.');
            break;
          case 'invalid-email':
            showErrorMessage('Invalid email address.');
            break;
          case 'user-disabled':
            showErrorMessage('This account has been disabled.');
            break;
          case 'too-many-requests':
            showErrorMessage('Too many attempts. Please try again later.');
            break;
          default:
            showErrorMessage(e.message ?? 'An unexpected error occurred.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showErrorMessage('An unexpected error occurred: $e');
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
