import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? result = await GoogleSignIn().signIn();

      // Si el usuario cancela el modal
      if (result == null) {
        throw Exception('Inicio de sesión cancelado');
      }

      final GoogleSignInAuthentication auth = await result.authentication;

      if (auth?.accessToken == null || auth?.idToken == null) {
        throw Exception('Error al obtener credenciales de Google');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: auth!.accessToken,
        idToken: auth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Error al iniciar sesión con Google: ${e.toString()}');
    }
  }

  Future<void> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      await _firebaseAuth.signInWithCredential(
        OAuthProvider('apple.com').credential(
          idToken: credential.identityToken,
          accessToken: credential.authorizationCode,
        ),
      );
    } catch (e) {
      throw Exception('Error al iniciar sesión con Apple: ${e.toString()}');
    }
  }
}
