import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalisisZonasPage extends StatefulWidget {
  const AnalisisZonasPage({super.key});

  @override
  State<AnalisisZonasPage> createState() => _AnalisisZonasPageState();
}

class _AnalisisZonasPageState extends State<AnalisisZonasPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dorado = theme.colorScheme.secondary;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'Análisis de Zonas',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: dorado,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Título principal
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Resumen de Seguridad',
                style: GoogleFonts.montserrat(
                  color: dorado,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tarjetas de indicadores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard('Zonas seguras', '72%', Icons.shield_outlined, Colors.greenAccent),
                _buildInfoCard('Riesgo medio', '18%', Icons.warning_amber_rounded, Colors.amberAccent),
                _buildInfoCard('Zonas críticas', '10%', Icons.dangerous_rounded, Colors.redAccent),
              ],
            ),
            const SizedBox(height: 30),

            // Gráfico de tendencias
            _buildLineChart(),
            const SizedBox(height: 30),

            // Gráfico circular
            _buildPieChart(),
            const SizedBox(height: 30),

            // Noticias / insights del modelo
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Insights del Análisis IA',
                style: GoogleFonts.montserrat(
                  color: dorado,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildInsightCard(
              'El aumento del 15% en reportes nocturnos en el norte sugiere baja iluminación en vías principales.',
            ),
            _buildInsightCard(
              'Las zonas cercanas a parques registran una disminución del 8% en incidentes tras mayor presencia policial.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3), 
            blurRadius: 6, 
            offset: const Offset(0, 3)
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              color: theme.textTheme.bodyMedium?.color ?? Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.white54;
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          backgroundColor: theme.cardColor,
          gridData: FlGridData(
            show: true, 
            drawVerticalLine: false, 
            getDrawingHorizontalLine: (_) => FlLine(
              color: textColor.withValues(alpha: 0.3), 
              strokeWidth: 1
            )
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, 
                reservedSize: 32, 
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}', 
                  style: TextStyle(color: textColor, fontSize: 10)
                )
              )
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, 
                getTitlesWidget: (value, _) {
                  switch (value.toInt()) {
                    case 1: return Text('Lun', style: TextStyle(color: textColor, fontSize: 10));
                    case 2: return Text('Mar', style: TextStyle(color: textColor, fontSize: 10));
                    case 3: return Text('Mié', style: TextStyle(color: textColor, fontSize: 10));
                    case 4: return Text('Jue', style: TextStyle(color: textColor, fontSize: 10));
                    case 5: return Text('Vie', style: TextStyle(color: textColor, fontSize: 10));
                  }
                  return const SizedBox.shrink();
                }
              )
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(1, 3),
                FlSpot(2, 2.5),
                FlSpot(3, 3.8),
                FlSpot(4, 2),
                FlSpot(5, 4),
              ],
              color: theme.colorScheme.secondary,
              isCurved: true,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true, 
                color: theme.colorScheme.secondary.withValues(alpha: 0.2)
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final theme = Theme.of(context);
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.greenAccent,
              value: 72,
              title: 'Seguras',
              radius: 60,
              titleStyle: GoogleFonts.montserrat(
                color: Colors.black87, 
                fontWeight: FontWeight.bold, 
                fontSize: 12
              ),
            ),
            PieChartSectionData(
              color: Colors.amberAccent,
              value: 18,
              title: 'Riesgo medio',
              radius: 55,
              titleStyle: GoogleFonts.montserrat(
                color: Colors.black87, 
                fontWeight: FontWeight.bold, 
                fontSize: 10
              ),
            ),
            PieChartSectionData(
              color: Colors.redAccent,
              value: 10,
              title: 'Críticas',
              radius: 50,
              titleStyle: GoogleFonts.montserrat(
                color: Colors.black87, 
                fontWeight: FontWeight.bold, 
                fontSize: 10
              ),
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildInsightCard(String text) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3), 
            blurRadius: 6, 
            offset: const Offset(0, 3)
          )
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.insights, color: theme.colorScheme.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.white70, 
                fontSize: 13, 
                height: 1.4
              ),
            ),
          ),
        ],
      ),
    );
  }
}
