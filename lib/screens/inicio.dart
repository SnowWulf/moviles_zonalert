import 'package:flutter/material.dart';
import 'dart:math' show Random;
import '../l10n/app_localizations.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  late Map<String, int> resumenZonas;
  bool _cargado = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simula carga
    setState(() {
      final random = Random();
      resumenZonas = {
        'seguras': random.nextInt(10) + 5,
        'regulares': random.nextInt(8) + 3,
        'peligrosas': random.nextInt(6) + 1,
      };
      _cargado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dorado = theme.colorScheme.secondary;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con perfil y saludo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('android/assets/perfil.png'),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.welcome,
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            l10n.user,
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color ?? Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: theme.textTheme.bodyMedium?.color ?? Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Gráfica de seguridad
              AnimatedOpacity(
                opacity: _cargado ? 1 : 0,
                duration: const Duration(milliseconds: 600),
                child: _cargado
                    ? _buildGraficaSeguridad(resumenZonas, dorado, theme, l10n)
                    : Center(child: CircularProgressIndicator(color: dorado)),
              ),

              const SizedBox(height: 40),

              // Noticias / Alertas de la ciudad
              Text(
                l10n.newsTitle,
                style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color ?? Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildNoticia(
                titulo: l10n.news1Title,
                descripcion: l10n.news1Desc,
                color: dorado,
              ),
              _buildNoticia(
                titulo: l10n.news2Title,
                descripcion: l10n.news2Desc,
                color: Colors.redAccent,
              ),
              _buildNoticia(
                titulo: l10n.news3Title,
                descripcion: l10n.news3Desc,
                color: Colors.greenAccent.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraficaSeguridad(Map<String, int> resumen, Color dorado, ThemeData theme, AppLocalizations l10n) {
    final total = resumen.values.reduce((a, b) => a + b);
    final seguras = resumen['seguras']! / total;
    final regulares = resumen['regulares']! / total;
    final peligrosas = resumen['peligrosas']! / total;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: seguras,
              strokeWidth: 16,
              backgroundColor: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.2) ?? Colors.grey.withValues(alpha: 0.3),
              color: Colors.greenAccent,
            ),
          ),
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: seguras + regulares,
              strokeWidth: 16,
              backgroundColor: Colors.transparent,
              color: dorado,
            ),
          ),
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: seguras + regulares + peligrosas,
              strokeWidth: 16,
              backgroundColor: Colors.transparent,
              color: Colors.redAccent,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.summary,
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.black54, 
                  fontSize: 16
                ),
              ),
              Text(
                "$total ${l10n.zones}",
                style: TextStyle(
                    color: dorado,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoticia({
    required String titulo,
    required String descripcion,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color.fromRGBO((color.r * 255).round(), (color.g * 255).round(), (color.b * 255).round(), 0.15),
        border: Border.all(color: Color.fromRGBO((color.r * 255).round(), (color.g * 255).round(), (color.b * 255).round(), 0.5), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            descripcion,
            style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.black54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
