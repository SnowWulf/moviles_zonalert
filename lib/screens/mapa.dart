import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const ZonAlertApp());
}

class ZonAlertApp extends StatelessWidget {
  const ZonAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZonAlert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const MapaPage(),
    );
  }
}

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
      // AppBar moderna
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.indigo),
          onPressed: () {},
        ),
        centerTitle: true,
        title: const Text(
          'ZonAlert',
          style: TextStyle(
            color: Colors.indigo,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      // Contenedor central con el mapa dentro
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
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
          ),
        ),
      ),

      // Barra inferior
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        currentIndex: 1, // “Mapa” seleccionado
        onTap: (index) {}, // sin funcionalidad por ahora
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Datos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}
