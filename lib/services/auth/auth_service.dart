import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';


class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? result = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? auth = await result?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: auth?.accessToken,
        idToken: auth?.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return userCredential.user != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(
        OAuthProvider('apple.com').credential(
          idToken: credential.identityToken,
          accessToken: credential.authorizationCode,
        ),
      );

      if (userCredential.user == null) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

}