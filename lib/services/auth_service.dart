import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //Google Sign In
  signInWithGoogle() async {
    //Begin interactive signIn process
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    //Obtain auth details from request
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    //Create a new credential for the user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    //Sign in the user with the credential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
