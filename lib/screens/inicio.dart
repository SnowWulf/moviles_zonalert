import 'package:flutter/material.dart';
import 'dart:math' show Random;

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
    const azulOscuro = Color(0xFF142535);
    const dorado = Color(0xFFE9AE5D);

    return Scaffold(
      backgroundColor: azulOscuro,
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
                        children: const [
                          Text(
                            "Bienvenido 👋",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Usuario de ZonAlert",
                            style: TextStyle(
                              color: Colors.white,
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
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Gráfica de seguridad
              AnimatedOpacity(
                opacity: _cargado ? 1 : 0,
                duration: const Duration(milliseconds: 600),
                child: _cargado
                    ? _buildGraficaSeguridad(resumenZonas, dorado)
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
              ),

              const SizedBox(height: 40),

              // Noticias / Alertas de la ciudad
              const Text(
                "Noticias de tu zona",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildNoticia(
                titulo: "📍 Nueva zona segura detectada en el centro",
                descripcion:
                    "El sistema registró mejoras en la seguridad del Parque Nariño y sus alrededores.",
                color: dorado,
              ),
              _buildNoticia(
                titulo: "⚠️ Aumento de incidentes en el barrio Obrero",
                descripcion:
                    "Se reportaron 3 alertas recientes. Evita transitar de noche por la zona.",
                color: Colors.redAccent,
              ),
              _buildNoticia(
                titulo: "🚓 Patrullajes activos en Avenida Panamericana",
                descripcion:
                    "La policía incrementó la vigilancia en los accesos principales.",
                color: Colors.greenAccent.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraficaSeguridad(Map<String, int> resumen, Color dorado) {
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
              backgroundColor: Colors.white12,
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
              const Text(
                "Resumen",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                "$total zonas",
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
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
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
