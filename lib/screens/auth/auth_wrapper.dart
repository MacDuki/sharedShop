// Screens
import 'package:appfast/screens/dashboard/dashboard_screen.dart';
import 'package:appfast/screens/login/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<void> _ensureUserDocument(User user) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // Crear documento de usuario si no existe
      await userDoc.set({
        'email': user.email,
        'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'budgetIds': [],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras se verifica el estado de autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si hay un usuario autenticado
        if (snapshot.hasData && snapshot.data != null) {
          // Asegurar que el documento de usuario existe
          _ensureUserDocument(snapshot.data!);
          return const DashboardScreen();
        }

        // Si no hay usuario autenticado
        return const LoginScreen();
      },
    );
  }
}
