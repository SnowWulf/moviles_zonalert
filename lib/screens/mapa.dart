import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/utils/notification_settings.dart';
import '../l10n/app_localizations.dart';

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
  final Function(Map<String, MarcadorInfo>, List<List<LatLng>>)? onDataChanged;
  const MapaPage({super.key, this.onDataChanged});

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

  static Future<void> vibrarYNotificar(String titulo, String mensaje) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 3000);
    }

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

class _MapaPageState extends State<MapaPage> with SingleTickerProviderStateMixin {
  static const double radioBarrio = 500.0; // metros
  
  late final AnimationController _flotarController;
  late final Animation<double> _flotarAnim;
  final MapController _mapController = MapController();
  LatLng _ubicacionActual = const LatLng(1.2130, -77.2820);
  final double _zoomActual = 16.0;
  StreamSubscription<Position>? _posicionStream;
  StreamSubscription<CompassEvent>? _compassSubscription;
  double _currentHeading = 0;
  final Map<String, MarcadorInfo> _marcadoresInfo = {};
  double _radioAlerta = 100;

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

  @override
  void dispose() {
    _flotarController.dispose();
    _compassSubscription?.cancel();
    _posicionStream?.cancel();
    super.dispose();
  }

  Future<void> _iniciarSeguimientoUbicacion() async {
    bool servicio = await Geolocator.isLocationServiceEnabled();
    if (!servicio) return;
  
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) return;
    }
    if (permiso == LocationPermission.deniedForever) return;

    try {
      final p = await Geolocator.getCurrentPosition();
      setState(() {
        _ubicacionActual = LatLng(p.latitude, p.longitude);
      });
    } catch (_) {}
  
    _posicionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position pos) {
      final nueva = LatLng(pos.latitude, pos.longitude);

      final double distancia = Distance().as(
        LengthUnit.Meter,
        _ubicacionActual,
        nueva,
      );

      if (distancia < 3) return;

      setState(() => _ubicacionActual = nueva);
      _verificarProximidad(nueva);
    });
  }
    
  Future<void> _cargarConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _radioAlerta = prefs.getDouble('radio_alerta') ?? 100.0;
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion(); 
  
    _flotarController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _flotarAnim = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _flotarController, curve: Curves.easeInOut),
    );

    _iniciarSeguimientoUbicacion();
    
    _compassSubscription = FlutterCompass.events!.listen((event) {
      setState(() {
        _currentHeading = event.heading ?? 0.0;
      });
    });
  }

  void _abrirDialogoMarcador({required LatLng posicion, String? idExistente}) {
    final marcadorExistente = idExistente != null ? _marcadoresInfo[idExistente] : null;

    String tipoExperiencia = marcadorExistente?.tipoExperiencia ?? 'Bueno';
    String experiencia = marcadorExistente?.experiencia ?? 'Sin incidente';
    String otraExperiencia = '';
    String descripcion = marcadorExistente?.descripcion ?? '';

    // Si el marcador anterior tenía una experiencia "Otra" la restauramos
    if (!["Sin incidente", "Robo", "Accidente", "Calle oscura"].contains(experiencia)) {
      otraExperiencia = experiencia;
      experiencia = "Otra";
    }

    final TextEditingController descripcionController =
        TextEditingController(text: descripcion);
    final TextEditingController otraExperienciaController =
        TextEditingController(text: otraExperiencia);

    final List<String> opcionesExperiencia = [
      "Sin incidente",
      "Robo",
      "Accidente",
      "Calle oscura",
      "Otra",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: StatefulBuilder(
              builder: (context, setStateDialog) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      idExistente == null
                          ? "Agrega tu experiencia en este lugar"
                          : "Editar marcador existente",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  //Tipo de experiencia
                  const Text("Tipo de experiencia"),
                  DropdownButton<String>(
                    value: tipoExperiencia,
                    isExpanded: true,
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
                        // Si es buena, deshabilitamos los incidentes
                        if (tipoExperiencia == 'Bueno') {
                          experiencia = 'Sin incidente';
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // Tipo de incidente
                  const Text("Tipo de incidente"),
                  const SizedBox(height: 4),

                  Opacity(
                    opacity: tipoExperiencia == 'Bueno' ? 0.5 : 1.0,
                    child: IgnorePointer(
                      ignoring: tipoExperiencia == 'Bueno',
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: opcionesExperiencia.contains(experiencia)
                            ? experiencia
                            : "Sin incidente",
                        items: opcionesExperiencia
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
                    ),
                  ),

                  // Campo para “Otra experiencia”
                  if (experiencia == 'Otra' && tipoExperiencia != 'Bueno') ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: otraExperienciaController,
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

                  //Descripción
                  const Text("Descripción"),
                  TextField(
                    controller: descripcionController,
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

                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Agregar foto"),
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (idExistente != null)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _eliminarMarcador(idExistente);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text("Eliminar"),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancelar"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _guardarMarcador(
                                idExistente ??
                                    DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                posicion,
                                tipoExperiencia,
                                tipoExperiencia == 'Bueno'
                                    ? 'Sin incidente'
                                    : (experiencia == 'Otra'
                                        ? otraExperienciaController.text
                                        : experiencia),
                                descripcionController.text,
                              );
                            },
                            child: Text(idExistente == null
                                ? "Agregar"
                                : "Guardar"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
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
    Widget imagenMarcador(String tipoExp, String exp) {
      // Si no hubo incidente, mostrar carita según el tipo de experiencia
      if (exp == 'Sin incidente') {
        switch (tipoExp) {
          case 'Bueno':
            return Image.asset('assets/cara_buena.png', width: 45, height: 45);
          case 'Regular':
            return Image.asset('assets/cara_regular.png', width: 45, height: 45);
          case 'Malo':
            return Image.asset('assets/cara_mala.png', width: 45, height: 45);
        }
      }

      // Si hubo incidente, usar el ícono del incidente
      switch (exp) {
        case 'Robo':
          return Image.asset('assets/bandit.png', width: 45, height: 45);
        case 'Accidente':
          return Image.asset('assets/fender.png', width: 45, height: 45);
        case 'Calle oscura':
          return Image.asset('assets/dark.png', width: 45, height: 45);
        default:
          return Image.asset('assets/other.png', width: 45, height: 45);
      }
    }

    final Marker marcador = Marker(
      point: posicion,
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () => _abrirDialogoMarcador(posicion: posicion, idExistente: id),
        child: AnimatedBuilder(
          animation: _flotarAnim,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_flotarAnim.value),
              child: child,
            );
          },
          child: imagenMarcador(tipoExperiencia, experiencia),
        ),
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

  void _eliminarMarcador(String id) {
    setState(() {
      _marcadoresInfo.remove(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dorado = theme.colorScheme.secondary;
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.person, color: dorado),
          onPressed: () {},
        ),
        centerTitle: true,
        title: Text(
          'ZonAlert',
          style: theme.appBarTheme.titleTextStyle ?? TextStyle(
            color: dorado,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: dorado.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _ubicacionActual,
                    initialZoom: 16,
                    keepAlive: true,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onTap: (tapPos, latlng) => _abrirDialogoMarcador(posicion: latlng),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.zonalert',
                      maxZoom: 19,
                    ),
                    PolygonLayer(
                      polygons: _generarPoligonos().map((grupo) {
                        return Polygon(
                          points: grupo,
                          color: _colorPoligono(grupo),
                          borderColor: dorado.withValues(alpha: 0.8),
                          borderStrokeWidth: 2,
                        );
                      }).toList(),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _ubicacionActual,
                          width: 40,
                          height: 40,
                          child: Transform.rotate(
                            angle: -(_currentHeading * (3.1416 / 180)),
                            child: Icon(
                              Icons.navigation,
                              color: dorado,
                              size: 40,
                            ),
                          ),
                        ),
                        ..._marcadoresInfo.values.map((e) => e.marker),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 70,
                  right: 10,
                  child: FloatingActionButton(
                    backgroundColor: dorado,
                    onPressed: () {
                      _mapController.move(_ubicacionActual, _zoomActual);
                    },
                    child: Icon(Icons.my_location, color: theme.scaffoldBackgroundColor),
                  ),
                ),
                // texto de niveles de riesgo con traducciones
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dorado, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.lowRisk, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(l10n.mediumRisk, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(l10n.highRisk, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Text(
                    '© ZonAlert 2025',
                    style: TextStyle(
                      color: dorado.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verificarProximidad(LatLng posicion) async {
    final notificacionesActivas = await NotificationSettings.areNotificationsEnabled();

    if (!notificacionesActivas) {
      return;
    }

    for (final info in _marcadoresInfo.values) {
      if (info.tipoExperiencia.toLowerCase() == 'malo' ||
          info.tipoExperiencia.toLowerCase() == 'regular') {
        final double distancia = Distance().as(
          LengthUnit.Meter,
          posicion,
          info.marker.point,
        );

        if (distancia <= _radioAlerta) {
          await AlertHelper.vibrarYNotificar(
            '⚠️ Alerta, cerca de aquí se reportó:',
            info.experiencia,
          );
          return;
        }
      }
    }

    for (final zona in _zonasPeligrosas) {
      for (final vert in zona) {
        final double distancia = Distance().as(
          LengthUnit.Meter,
          posicion,
          vert,
        );

        if (distancia <= _radioAlerta) {
          await AlertHelper.vibrarYNotificar(
            '🚨 Zona peligrosa',
            'Estás cerca de una zona marcada',
          );
          return;
        }
      }
    }
  }

  List<List<LatLng>> _generarPoligonos() {
    final List<List<LatLng>> poligonos = [];
    final marcadores = _marcadoresInfo.values.toList();

    for (int i = 0; i < marcadores.length; i++) {
      final List<LatLng> grupo = [marcadores[i].marker.point];

      for (int j = i + 1; j < marcadores.length; j++) {
        final double distancia = Distance().as(
          LengthUnit.Meter,
          marcadores[i].marker.point,
          marcadores[j].marker.point,
        );

        if (distancia <= radioBarrio) {
          grupo.add(marcadores[j].marker.point);
        }
      }

      if (grupo.length >= 3) {
        if (!poligonos.any((p) => p.toSet().containsAll(grupo))) {
          poligonos.add(grupo);
        }
      }
    }

    return poligonos;
  }

  Color _colorPoligono(List<LatLng> grupo) {
    int bueno = 0, regular = 0, malo = 0;

    for (final punto in grupo) {
      final marcador = _marcadoresInfo.values.firstWhere((m) => m.marker.point == punto);
      switch (marcador.tipoExperiencia.toLowerCase()) {
        case 'bueno':
          bueno++;
          break;
        case 'regular':
          regular++;
          break;
        case 'malo':
          malo++;
          break;
      }
    }

    if (malo >= regular && malo >= bueno) return const Color.fromRGBO(255, 0, 0, 0.4);
    if (regular >= bueno && regular >= malo) return const Color.fromRGBO(255, 255, 0, 0.4);
    return const Color.fromRGBO(0, 255, 0, 0.4);
  }
}

