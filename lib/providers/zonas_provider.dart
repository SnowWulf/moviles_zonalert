import 'package:flutter/material.dart';
import '../services/ia_service.dart';

class ZonasProvider extends ChangeNotifier {
  int seguras = 0;
  int riesgoMedio = 0;
  int peligrosas = 0;

  /// Tendencia semanal (1 = lunes ... 7 = domingo)
  final Map<int, int> reportesPorDia = {
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
    6: 0,
    7: 0,
  };

  /// Estado del insight
  String _ultimoInsight = '';
  bool generandoInsight = false;

  /// Servicio IA
  final IaService iaService = IaService();



  //ACTUALIZACIÓN DE ZONAS
  void actualizarZonas({
    required int nuevasSeguras,
    required int nuevosRiesgoMedio,
    required int nuevasPeligrosas,
  }) {
    seguras = nuevasSeguras;
    riesgoMedio = nuevosRiesgoMedio;
    peligrosas = nuevasPeligrosas;
    notifyListeners();
  }



  //TENDENCIAS
  void registrarReporteHoy() {
    final int diaActual = DateTime.now().weekday;
    reportesPorDia[diaActual] = (reportesPorDia[diaActual] ?? 0) + 1;
    notifyListeners();
  }

  void reiniciarTendencia() {
    for (var d = 1; d <= 7; d++) {
      reportesPorDia[d] = 0;
    }
    notifyListeners();
  }



  //MÉTRICAS
  double get total => (seguras + riesgoMedio + peligrosas).toDouble();

  double get porcentajeSeguras =>
      total == 0 ? 0 : (seguras / total) * 100;

  double get porcentajeRiesgoMedio =>
      total == 0 ? 0 : (riesgoMedio / total) * 100;

  double get porcentajePeligrosas =>
      total == 0 ? 0 : (peligrosas / total) * 100;



  //INSIGHTS - GETTER REAL
  String? get ultimoInsight =>
      _ultimoInsight.isEmpty ? null : _ultimoInsight;

  //MÉTODO MANUAL actualizarInsight()
  void actualizarInsight(String texto) {
    _ultimoInsight = texto;
    notifyListeners();
  }

  //GENERAR INSIGHT CON IA
  Future<void> generarInsightIA() async {
    generandoInsight = true;
    notifyListeners();

    try {
      final prompt = """
Eres una IA experta en seguridad urbana y análisis de datos de reportes ciudadanos. 
Tu tarea es generar insights prácticos, creativos y poco obvios, que ayuden a mejorar la seguridad de la ciudad. 

Datos actuales:

- Zonas seguras: $seguras
- Zonas de riesgo medio: $riesgoMedio
- Zonas peligrosas: $peligrosas

Tendencia semanal de reportes:
${_formatearTendencias()}

Instrucciones:
1. Detecta patrones que un humano promedio podría pasar por alto.
2. Sugiere consejos o acciones concretas que usuarios o autoridades podrían aplicar.
3. Evita recomendaciones genéricas como "ten cuidado" o "evita la zona".
4. Resume todo en un análisis de máximo 5 líneas, destacando riesgos, oportunidades y medidas innovadoras.

Devuelve únicamente el texto del insight listo para mostrar al usuario.
""";


      final respuesta = await iaService.generarInsight(prompt);

      _ultimoInsight = respuesta;
    } catch (e) {
      _ultimoInsight =
          "No fue posible generar el insight en este momento. Intenta de nuevo.";
    }

    generandoInsight = false;
    notifyListeners();
  }

  //Helper para tendencias
  String _formatearTendencias() {
    return reportesPorDia.entries
        .map((e) => "Día ${e.key}: ${e.value} reportes")
        .join("\n");
  }
}
