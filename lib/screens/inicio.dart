import 'package:flutter/material.dart';
import 'dart:math' show Random;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';
import '../utils/config.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  late Map<String, int> resumenZonas;
  bool _cargado = false;

  bool _cargandoNoticias = true;
  List<Map<String, dynamic>> noticias = [];
  
  String _nombreUsuario = 'Usuario';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _cargarDatos();
    _cargarNoticias();
  }
  
  void _cargarDatosUsuario() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _nombreUsuario = user.displayName ?? user.email?.split('@')[0] ?? 'Usuario';
      });
    }
  }

  /// Simula la carga de datos de seguridad
  Future<void> _cargarDatos() async {
  await Future.delayed(const Duration(milliseconds: 800));

  if (!mounted) return;

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


  /// Carga las noticias desde tu Worker
  Future<void> _cargarNoticias() async {
  try {
    final url = Uri.parse(Config.newsUrl);
    final response = await http.get(url);

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        if (!mounted) return;
        setState(() {
          noticias = List<Map<String, dynamic>>.from(data['articles']);
          _cargandoNoticias = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          noticias = [];
          _cargandoNoticias = false;
        });
      }
    } else {
      if (!mounted) return;
      setState(() {
        noticias = [];
        _cargandoNoticias = false;
      });
    }
  } catch (e) {
    if (!mounted) return;
    setState(() {
      noticias = [];
      _cargandoNoticias = false;
    });
  }
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
                              color: theme.textTheme.bodyMedium?.color?.withAlpha(180) ?? Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _nombreUsuario,
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

              _cargandoNoticias
                  ? Center(child: CircularProgressIndicator(color: dorado))
                  : noticias.isEmpty
                      ? Text(
                          'No hay noticias disponibles.',
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color ?? Colors.black54),
                        )
                      : Column(
                          children: noticias.map((article) {
                            return _buildNoticia(
                              titulo: article['title'] ?? '',
                              descripcion: article['description'] ?? '',
                              color: dorado,
                            );
                          }).toList(),
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
              backgroundColor: theme.textTheme.bodyMedium?.color?.withAlpha(50) ?? Colors.grey.withAlpha(80),
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
                  color: theme.textTheme.bodyMedium?.color?.withAlpha(180) ?? Colors.black54,
                  fontSize: 16,
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
        color: Color.fromRGBO((color.r * 255.0).round() & 0xff, (color.g * 255.0).round() & 0xff, (color.b * 255.0).round() & 0xff, 0.15),
        border: Border.all(color: Color.fromRGBO((color.r * 255.0).round() & 0xff, (color.g * 255.0).round() & 0xff, (color.b * 255.0).round() & 0xff, 0.5), width: 1),
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
            style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withAlpha(180) ?? Colors.black54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
