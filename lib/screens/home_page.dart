import 'package:flutter/material.dart';
import 'mapa.dart';
import 'inicio.dart';
import 'datos.dart';
import 'configuraciones.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/zonas_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  /// NO definimos _pages aquí porque depende del provider
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    final zonas = context.read<ZonasProvider>();

    _pages = [
      const InicioPage(),

      /// 🔥 Mapa conectado con provider
      MapaPage(
        onDataChanged: (marcadores, conteos) {
          zonas.actualizarZonas(
            nuevasSeguras: conteos['seguras']!,
            nuevosRiesgoMedio: conteos['riesgoMedio']!,
            nuevasPeligrosas: conteos['peligrosas']!,
          );
        },
      ),

      const AnalisisZonasPage(),
      const ConfiguracionesPage(),
    ];

    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: l10n.navMap,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics),
            label: l10n.navData,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
