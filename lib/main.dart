import 'package:flutter/material.dart';
import 'screens/splashscreen.dart';
import 'utils/alert_helper.dart';
import 'package:flutter/material.dart';
import 'screens/home_page.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AlertHelper.init(); // Inicializa notificaciones
  runApp(const ZonAlertApp());
}


class ZonAlertApp extends StatelessWidget {
  const ZonAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      debugShowCheckedModeBanner: false,
      title: 'ZonAlert',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const SplashScreen(), // <-- inicia aquí
    );
  }
}
