import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFF142535),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'android/assets/ZonAlert.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(
                    color: Color(0xFFE9AE5D),
                    strokeWidth: 4,
                  ),
                ],
              ),
            ),
          );
        }

        // Si hay usuario autenticado, ir a HomePage
        if (snapshot.hasData) {
          return const HomePage();
        }

        // Si no hay usuario, ir a LoginPage
        return const LoginPage();
      },
    );
  }
}
