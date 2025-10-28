import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math' show sqrt, pow;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import '/utils/alert_helper.dart'; 
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AlertHelper.inicializarNotificaciones(); // 👈 Necesario
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

// Clase para almacenar información de cada marcador
class MarcadorInfo {
  Marker marker;
  String tipoExperiencia;
  String experiencia;
  String descripcion;

  MarcadorInfo({
    required this.marker,
    required this.tipoExperiencia,
    required this.experiencia,
    required this.descripcion,
  });
}

// Página del mapa
class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class AlertHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> inicializarNotificaciones() async {
    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: initSettingsAndroid);

    await _notificationsPlugin.initialize(initSettings);
  }

  //Notificaciones:
  static Future<void> vibrarYNotificar(String titulo, String mensaje) async {
    // Vibrar (si está disponible)
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000); // 1 segundo
    }

    // Mostrar notificación
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'zonalert_channel',
      'ZonAlert Notificaciones',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails generalNotificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      titulo,
      mensaje,
      generalNotificationDetails,
    );
  }
}


class _MapaPageState extends State<MapaPage> {

  

  @override
    void dispose() {
    _posicionStream?.cancel();
    super.dispose();
  }

  final Map<String, MarcadorInfo> _marcadoresInfo = {};
  LatLng _ubicacionActual = LatLng(0, 0);
  
  //lista de zonas peligrosas
  final List<List<LatLng>> _zonasPeligrosas = [
  [
    LatLng(1.2136, -77.2811),
    LatLng(1.2140, -77.2815),
    LatLng(1.2139, -77.2809),
  ],
  [
    LatLng(1.2150, -77.2820),
    LatLng(1.2155, -77.2825),
    LatLng(1.2153, -77.2818),
  ],
];



  final MapController _mapController = MapController();
  //LatLng _ubicacionActual = LatLng(1.2136, -77.2811); // Pasto por defecto

  StreamSubscription<Position>? _posicionStream;
  double _zoomActual = 15.0;
  static const double RADIO_ALERTA = 80.0; // metros, ajustable

  
  //GPS:

  Future<void> _iniciarSeguimientoUbicacion() async {
  bool servicio = await Geolocator.isLocationServiceEnabled();
  if (!servicio) return;

  LocationPermission permiso = await Geolocator.checkPermission();
  if (permiso == LocationPermission.denied) {
    permiso = await Geolocator.requestPermission();
    if (permiso == LocationPermission.denied) return;
  }
  if (permiso == LocationPermission.deniedForever) return;

  // posición inicial
  try {
    final p = await Geolocator.getCurrentPosition();
    setState(() {
      _ubicacionActual = LatLng(p.latitude, p.longitude);
    });
    _mapController.move(_ubicacionActual, _zoomActual);
  } catch (_) {}

  // stream para actualizar mientras te mueves
  _posicionStream = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    ),
  ).listen((Position pos) {
    final nueva = LatLng(pos.latitude, pos.longitude);
    setState(() => _ubicacionActual = nueva);
    _mapController.move(nueva, _zoomActual);
    _verificarProximidad(nueva);
  });
}


  @override
    void initState() {
    super.initState();

    _pedirPermisosNotificacion();

    // Iniciar seguimiento GPS
    _iniciarSeguimientoUbicacion();
    }

  Future<void> _pedirPermisosNotificacion() async {
  await Permission.notification.request();
  }

  Future<void> _obtenerUbicacion() async {
  
  //Alertas para las etiquetas :
  for (final marcador in _marcadoresInfo.values) {
    final double distancia = Distance().as(
      LengthUnit.Meter,
      _ubicacionActual,
      marcador.marker.point,
    );
  if (distancia <= RADIO_ALERTA) {
    AlertHelper.vibrarYNotificar(
      '⚠️ Peligro cercano',
      'Estás a menos de ${RADIO_ALERTA.toInt()} metros de un marcador de tipo ${marcador.tipoExperiencia}',
    );
    return;
  }
}

      bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicioHabilitado) return;

      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) return;
      }

      // Escuchar actualizaciones en tiempo real
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5, // cada 5 metros actualiza
        ),
      ).listen((Position posicion) {
        setState(() {
          _ubicacionActual = LatLng(posicion.latitude, posicion.longitude);
        });

        // Mover el mapa contigo
        _mapController.move(_ubicacionActual, 16);

        // Comprobar si estás cerca de una zona peligrosa
        for (var info in _marcadoresInfo.values) {
          final distancia = Geolocator.distanceBetween(
            _ubicacionActual.latitude,
            _ubicacionActual.longitude,
            info.marker.point.latitude,
            info.marker.point.longitude,
          );

          if (distancia < 50 && info.tipoExperiencia == 'Malo') {
            AlertHelper.vibrarYNotificar(
              '⚠️ Zona peligrosa cercana',
              'Te estás acercando a un área marcada como peligrosa.',
            );
          }
        }
      });
    }

  void _centrarUbicacion() {
    _mapController.move(_ubicacionActual, 15);
  }

  // Crear o editar marcador
  void _abrirDialogoMarcador({required LatLng posicion, String? idExistente}) {
    String tipoExperiencia = 'Bueno';
    String experiencia = 'Robo';
    String otraExperiencia = '';
    String descripcion = '';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StatefulBuilder(
                builder: (context, setStateDialog) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Agrega tu experiencia en este lugar",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tipo de experiencia
                    Text("Tipo de experiencia"),
                    DropdownButton<String>(
                      value: tipoExperiencia,
                      items: ['Bueno', 'Regular', 'Malo']
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Row(
                                  children: [
                                    Icon(
                                      e == 'Bueno'
                                          ? Icons.sentiment_satisfied
                                          : e == 'Regular'
                                              ? Icons.sentiment_neutral
                                              : Icons.sentiment_dissatisfied,
                                      color: e == 'Bueno'
                                          ? Colors.green
                                          : e == 'Regular'
                                              ? Colors.amber
                                              : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(e),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          tipoExperiencia = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // Experiencia
                    Text("Experiencia"),
                    DropdownButton<String>(
                      value: experiencia,
                      items: ['Robo', 'Accidente', 'Calle oscura', 'Otra']
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          experiencia = value!;
                        });
                      },
                    ),

                    if (experiencia == 'Otra') ...[
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: "Escribe tu experiencia",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          otraExperiencia = value;
                        },
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Descripción
                    Text("Descripción"),
                    TextField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: "Agrega más detalles",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        descripcion = value;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Foto (botón)
                    ElevatedButton.icon(
                      onPressed: () {
                        // Implementar image picker después
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Agregar foto"),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancelar"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Guardar marcador
                            Navigator.pop(context);
                            _guardarMarcador(
                              idExistente ??
                                  DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                              posicion,
                              tipoExperiencia,
                              experiencia == 'Otra'
                                  ? otraExperiencia
                                  : experiencia,
                              descripcion,
                            );
                          },
                          child: const Text("Agregar"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _guardarMarcador(
    String id,
    LatLng posicion,
    String tipoExperiencia,
    String experiencia,
    String descripcion,
  ) {
    double hue;
    switch (tipoExperiencia) {
      case 'Bueno':
        hue = 120; // verde
        break;
      case 'Regular':
        hue = 60; // amarillo
        break;
      case 'Malo':
      default:
        hue = 0; // rojo
        break;
    }

    Widget emojiMarcador(String tipo) {
       switch (tipo) {
         case 'Robo':
           return const Text('🦹', style: TextStyle(fontSize: 36)); // ladrón
         case 'Accidente':
           return const Text('💥', style: TextStyle(fontSize: 36)); // accidente
         case 'Calle oscura':
           return const Text('🌑', style: TextStyle(fontSize: 36)); // noche
         default:
           return const Text('❗', style: TextStyle(fontSize: 36)); // otra
       }
      }

      final Marker marcador = Marker(
        point: posicion,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _abrirDialogoMarcador(posicion: posicion, idExistente: id),
          child: emojiMarcador(experiencia),
        ),
      );




    setState(() {
      _marcadoresInfo[id] = MarcadorInfo(
        marker: marcador,
        tipoExperiencia: tipoExperiencia,
        experiencia: experiencia,
        descripcion: descripcion,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    onTap: (tapPos, latlng) {
                      _abrirDialogoMarcador(posicion: latlng);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
                      subdomains: ['a', 'b', 'c', 'd'],
                      ),

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
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _ubicacionActual,
                          width: 40,
                          height: 40,
                          child:
                              const Icon(Icons.my_location, color: Colors.blue),
                        ),
                        ..._marcadoresInfo.values.map((e) => e.marker),
                      ],
                    ),
                  ],
                ),
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
                Positioned(
                 bottom: 5,
                 right: 5,
                 child: Container(
                   color: Colors.black54,
                   padding: const EdgeInsets.all(4),
                   child: const Text(
                     '© OpenStreetMap © CARTO',
                     style: TextStyle(color: Colors.white, fontSize: 10),
                   ),
                 ),
                ),
                
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (index) {},
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

  void _verificarProximidad(LatLng posicion) {
  // 1) revisar marcadores malos
  _marcadoresInfo.forEach((id, info) {
    if (info.tipoExperiencia.toLowerCase() == 'malo') {
      final double distancia = Distance().as(LengthUnit.Meter, posicion, info.marker.point);
      if (distancia <= RADIO_ALERTA) {
        // usa AlertHelper o la instancia local
        AlertHelper.vibrarYNotificar('⚠️ Cerca de marcador', info.experiencia);
      }
    }
  });

  // 2) revisar zonas (polígonos) - versión simple: distancia a vértices
  for (final zona in _zonasPeligrosas) {
    for (final vert in zona) {
      final double distancia = Distance().as(LengthUnit.Meter, posicion, vert);
      if (distancia <= RADIO_ALERTA) {
        AlertHelper.vibrarYNotificar('🚨 Zona peligrosa', 'Estás cerca de una zona marcada');
        return;
      }
    }
  }
}



}
