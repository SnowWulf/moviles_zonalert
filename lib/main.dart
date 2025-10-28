import 'package:flutter/material.dart';
import 'screens/splashscreen.dart';
import 'utils/alert_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AlertHelper.init(); // Inicializa notificaciones
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
