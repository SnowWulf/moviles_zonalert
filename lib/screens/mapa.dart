import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final MapController _mapController = MapController();
  LatLng _ubicacionActual = LatLng(1.2136, -77.2811); // Coordenadas de Pasto por defecto

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
  }

  Future<void> _obtenerUbicacion() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) return;

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) return;
    }

    final posicion = await Geolocator.getCurrentPosition();
    setState(() {
      _ubicacionActual = LatLng(posicion.latitude, posicion.longitude);
    });
    _mapController.move(_ubicacionActual, 15);
  }

  void _centrarUbicacion() {
    _mapController.move(_ubicacionActual, 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZonAlert - Mapa de Riesgo'),
        backgroundColor: Colors.indigo,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _ubicacionActual,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.zonalert',
              ),

              // Ejemplo de zona de riesgo alta
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: [
                      LatLng(1.2130, -77.2820),
                      LatLng(1.2135, -77.2800),
                      LatLng(1.2145, -77.2810),
                    ],
                    color: Colors.red.withOpacity(0.4),
                    borderColor: Colors.red,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),

              // Marcador de ubicación actual
              MarkerLayer(
                markers: [
                  Marker(
                    point: _ubicacionActual,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.my_location, color: Colors.blue),
                  ),
                ],
              ),
            ],
          ),

          // Indicadores de riesgo
          Positioned(
            top: 10,
            left: 10,
            child: Card(
              color: Colors.white70,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('🟢 Bajo riesgo'),
                    Text('🟡 Riesgo medio'),
                    Text('🔴 Alto riesgo'),
                  ],
                ),
              ),
            ),
          ),

          // Botón para centrar mapa
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _centrarUbicacion,
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
