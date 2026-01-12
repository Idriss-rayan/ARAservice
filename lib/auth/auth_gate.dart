import 'package:araservice/auth/register_page.dart';
import 'package:araservice/main_navigation_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Attente de Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ Utilisateur connecté
        if (snapshot.hasData) {
          return const MainNavigationScreen();
        }

        // ❌ Non connecté
        return const RegisterPage();
      },
    );
  }
}
