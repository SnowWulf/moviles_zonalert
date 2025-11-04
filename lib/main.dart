import 'screens/splashscreen.dart';
import 'utils/alert_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

// Notificador global para el modo oscuro
final ValueNotifier<bool> darkModeNotifier = ValueNotifier(true);
// Notificador global para el idioma
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('es', ''));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AlertHelper.init();
  
  final prefs = await SharedPreferences.getInstance();
  darkModeNotifier.value = prefs.getBool('modo_oscuro') ?? true;
  
  // Cargar idioma guardado o usar español por defecto
  final String? savedLanguage = prefs.getString('language');
  if (savedLanguage != null) {
    localeNotifier.value = Locale(savedLanguage, '');
  }
  
  runApp(const ZonAlertApp());
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
                cardColor: Colors.grey.shade50,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  iconTheme: IconThemeData(color: Color(0xFFE9AE5D)),
                  titleTextStyle: TextStyle(
                    color: Color(0xFFE9AE5D), 
                    fontWeight: FontWeight.bold, 
                    fontSize: 20
                  ),
                ),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: Colors.white,
                  selectedItemColor: Color(0xFFE9AE5D),
                  unselectedItemColor: Colors.grey,
                  type: BottomNavigationBarType.fixed,
                ),
                sliderTheme: SliderThemeData(
                  activeTrackColor: const Color(0xFFE9AE5D),
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: const Color(0xFFE9AE5D),
                  overlayColor: const Color(0xFFE9AE5D).withValues(alpha: 0.2),
                  valueIndicatorColor: const Color(0xFFE9AE5D),
                  valueIndicatorTextStyle: const TextStyle(color: Colors.black),
                ),
                textTheme: const TextTheme(
                  bodyMedium: TextStyle(color: Colors.black87),
                ),
                colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo)
                    .copyWith(secondary: const Color(0xFFE9AE5D)),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                primarySwatch: Colors.indigo,
                scaffoldBackgroundColor: const Color(0xFF142535),
                cardColor: const Color(0xFF1C3C50),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF142535),
                  foregroundColor: Color(0xFFE9AE5D),
                  iconTheme: IconThemeData(color: Color(0xFFE9AE5D)),
                  titleTextStyle: TextStyle(
                    color: Color(0xFFE9AE5D), 
                    fontWeight: FontWeight.bold, 
                    fontSize: 20
                  ),
                ),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: Color(0xFF142535),
                  selectedItemColor: Color(0xFFE9AE5D),
                  unselectedItemColor: Colors.white70,
                  type: BottomNavigationBarType.fixed,
                ),
                sliderTheme: SliderThemeData(
                  activeTrackColor: const Color(0xFFE9AE5D),
                  inactiveTrackColor: Colors.grey.shade600,
                  thumbColor: const Color(0xFFE9AE5D),
                  overlayColor: const Color(0xFFE9AE5D).withValues(alpha: 0.2),
                  valueIndicatorColor: const Color(0xFFE9AE5D),
                  valueIndicatorTextStyle: const TextStyle(color: Colors.black),
                ),
                textTheme: const TextTheme(
                  bodyMedium: TextStyle(color: Colors.white),
                ),
                colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: Colors.indigo, 
                  brightness: Brightness.dark
                ).copyWith(secondary: const Color(0xFFE9AE5D)),
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
