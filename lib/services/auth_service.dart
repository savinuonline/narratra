import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    signInOption: SignInOption.standard,
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize Firebase with reCAPTCHA configuration
  Future<void> initializeFirebase() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
      // Configure reCAPTCHA to be less intrusive
      await _auth.setSettings(
        appVerificationDisabledForTesting: true, // Only use in development
        phoneNumber: null,
        smsCode: null,
      );
    }
  }

  //Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();

      // If user cancels the sign-in flow, return null
      if (gUser == null) {
        return null;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create new credential for user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Finally, sign in
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  //Email and Password Sign In
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
    {bool rememberMe = true}
  ) async {
    try {
      await initializeFirebase();

      // Sign in with email and password
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        print('Successfully signed in user: ${userCredential.user?.email}');
        return userCredential;
      }
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found for that email.',
      );
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw e; // Re-throw the exception to be handled by the caller
    } catch (e) {
      print('Unexpected error: $e');
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  //Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('Successfully signed out');
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
