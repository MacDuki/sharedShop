// Screens
import 'package:appfast/screens/dashboard/dashboard_screen.dart';
import 'package:appfast/screens/login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

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
          return const DashboardScreen();
        }

        // Si no hay usuario autenticado
        return const LoginScreen();
      },
    );
  }
}
