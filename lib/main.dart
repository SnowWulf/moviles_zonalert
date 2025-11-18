import 'screens/splashscreen.dart';
import 'utils/alert_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//Para datos
import 'package:provider/provider.dart';
import 'providers/zonas_provider.dart';

// Notificador global para el modo oscuro
final ValueNotifier<bool> darkModeNotifier = ValueNotifier(true);
// Notificador global para el idioma
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('es', ''));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await AlertHelper.init();
  
  final prefs = await SharedPreferences.getInstance();
  darkModeNotifier.value = prefs.getBool('modo_oscuro') ?? true;
  
  // Cargar idioma guardado o usar español por defecto
  final String? savedLanguage = prefs.getString('language');
  if (savedLanguage != null) {
    localeNotifier.value = Locale(savedLanguage, '');
  }
  
  runApp(
    //AÑADIMOS el Provider SIN romper el resto
    ChangeNotifierProvider(
      create: (_) => ZonasProvider(),
      child: const ZonAlertApp(),
    ),
  );
}

class ZonAlertApp extends StatelessWidget {
  const ZonAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'ZonAlert',
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: ThemeData(
                brightness: Brightness.light,
                primarySwatch: Colors.indigo,
                scaffoldBackgroundColor: Colors.white,
                cardColor: Colors.white,
                dialogTheme: const DialogThemeData(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  iconTheme: IconThemeData(color: Color(0xFFD97706)), // Ámbar oscuro
                  titleTextStyle: TextStyle(
                    color: Color(0xFFD97706), // Ámbar oscuro
                    fontWeight: FontWeight.bold, 
                    fontSize: 20
                  ),
                  elevation: 2,
                ),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: Colors.white,
                  selectedItemColor: Color(0xFFD97706), // Ámbar oscuro
                  unselectedItemColor: Colors.grey,
                  type: BottomNavigationBarType.fixed,
                  elevation: 8,
                ),
                sliderTheme: SliderThemeData(
                  activeTrackColor: const Color(0xFFD97706),
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: const Color(0xFFD97706),
                  overlayColor: const Color(0xFFD97706).withValues(alpha: 0.2),
                  valueIndicatorColor: const Color(0xFFD97706),
                  valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                ),
                textTheme: const TextTheme(
                  bodyMedium: TextStyle(color: Colors.black87),
                  titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    elevation: 2,
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD97706), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo)
                    .copyWith(
                      secondary: const Color(0xFFD97706), // Ámbar oscuro
                      brightness: Brightness.light,
                    ),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                primarySwatch: Colors.indigo,
                scaffoldBackgroundColor: const Color(0xFF0F1419),
                cardColor: const Color(0xFF1A1F26),
                dialogTheme: const DialogThemeData(
                  backgroundColor: Color(0xFF1A1F26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF1A1F26),
                  foregroundColor: Color(0xFFFFA726),
                  iconTheme: IconThemeData(color: Color(0xFFFFA726)),
                  titleTextStyle: TextStyle(
                    color: Color(0xFFFFA726), 
                    fontWeight: FontWeight.bold, 
                    fontSize: 20
                  ),
                  elevation: 0,
                ),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: Color(0xFF1A1F26),
                  selectedItemColor: Color(0xFFFFA726),
                  unselectedItemColor: Colors.white60,
                  type: BottomNavigationBarType.fixed,
                  elevation: 8,
                ),
                sliderTheme: SliderThemeData(
                  activeTrackColor: const Color(0xFFFFA726),
                  inactiveTrackColor: Colors.grey.shade700,
                  thumbColor: const Color(0xFFFFA726),
                  overlayColor: const Color(0xFFFFA726).withValues(alpha: 0.2),
                  valueIndicatorColor: const Color(0xFFFFA726),
                  valueIndicatorTextStyle: const TextStyle(color: Colors.black),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA726),
                    foregroundColor: Colors.black,
                    elevation: 2,
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFFFA726), width: 2),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF252B33),
                ),
                textTheme: const TextTheme(
                  bodyMedium: TextStyle(color: Colors.white),
                  titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: Colors.indigo, 
                  brightness: Brightness.dark
                ).copyWith(secondary: const Color(0xFFFFA726)),
              ),
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
