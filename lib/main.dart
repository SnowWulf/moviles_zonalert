import 'package:flutter/material.dart';
import 'screens/splashscreen.dart';

void main() {
  runApp(const ZonAlertApp());
}

class ZonAlertApp extends StatelessWidget {
  const ZonAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( //nombre aplicación, este va en el widget_test.dart
      debugShowCheckedModeBanner: false,
      title: 'ZonAlert',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const SplashScreen(), // <-- inicia aquí
    );
  }
}
