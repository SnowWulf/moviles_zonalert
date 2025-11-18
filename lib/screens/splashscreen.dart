import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Espera 3 segundos y redirige al AuthWrapper
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF142535), // Azul oscuro de fondo
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo centrado
            Image.asset(
              'android/assets/ZonAlert.png',
              width: 160,
              height: 160,
            ),
            const SizedBox(height: 40),

            // Círculo dorado girando
            const SizedBox(
              width: 45,
              height: 45,
              child: CircularProgressIndicator(
                color: Color(0xFFE9AE5D), // Dorado
                strokeWidth: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
