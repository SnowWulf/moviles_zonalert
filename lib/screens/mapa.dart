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
import '../models/marcador_info.dart';
import 'package:provider/provider.dart';
import '../providers/zonas_provider.dart';
import '../services/marcadores_service.dart';
import '../services/auth_service.dart';


typedef OnDataChangedCallback = void Function(
  Map<String, MarcadorInfo> marcadores,
  Map<String, int> zonas,
);

// Página del mapa
class MapaPage extends StatefulWidget {
  
  final OnDataChangedCallback? onDataChanged;
  const MapaPage({super.key, this.onDataChanged});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

//Disparador de alertas
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
  StreamSubscription<List<MarcadorInfo>>? _marcadoresStream;
  double _currentHeading = 0;
  final Map<String, MarcadorInfo> _marcadoresInfo = {};
  double _radioAlerta = 100;
  
  // Servicios Firebase
  final MarcadoresService _marcadoresService = MarcadoresService();
  final AuthService _authService = AuthService();

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
    _marcadoresStream?.cancel();
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

  // ===============================
  // PRIMERA UBICACIÓN SEGURA
  // ===============================
  try {
    final p = await Geolocator.getCurrentPosition();
    setState(() {
      _ubicacionActual = LatLng(p.latitude, p.longitude);
    });
  } catch (_) {
    return;  // Evita que siga si falla
  }

  // ===============================
  // STREAM CON PREVENCIÓN DE NaN
  // ===============================
  _posicionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position pos) {
      final nueva = LatLng(pos.latitude, pos.longitude);    

      // Calcular distancia entre posiciones
      final double distancia = Distance().as(
        LengthUnit.Meter,
        _ubicacionActual,
        nueva,
      );    

      // Evitar NaN
      if (distancia.isNaN) return;    

      // Evitar micro-movimientos
      if (distancia < 3) return;    

      // Actualizar y verificar zonas
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
    _escucharMarcadoresFirebase();

    double lerp(double a, double b, double t) => a + (b - a) * t;
    
    _compassSubscription = FlutterCompass.events!.listen((event) {
     double? h = event.heading;

     // Validar que no sea null ni NaN
     if (h == null || h.isNaN) return;

     // Convertir a double seguro
     double heading = h % 360;

     setState(() {
       _currentHeading = lerp(_currentHeading, heading, 0.1); 
     });
  });
  }

  // Escuchar cambios de marcadores en tiempo real desde Firebase
  void _escucharMarcadoresFirebase() {
    _marcadoresStream = _marcadoresService.escucharMarcadores().listen((marcadores) {
      setState(() {
        _marcadoresInfo.clear();
        for (var marcadorInfo in marcadores) {
          // Crear el widget del marcador con la animación
          final marcadorConWidget = MarcadorInfo(
            id: marcadorInfo.id,
            marker: Marker(
              point: marcadorInfo.marker.point,
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () => _abrirDialogoMarcador(
                  posicion: marcadorInfo.marker.point,
                  idExistente: marcadorInfo.id,
                ),
                child: AnimatedBuilder(
                  animation: _flotarAnim,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_flotarAnim.value),
                      child: child,
                    );
                  },
                  child: _imagenMarcador(marcadorInfo.tipoExperiencia, marcadorInfo.experiencia),
                ),
              ),
            ),
            tipoExperiencia: marcadorInfo.tipoExperiencia,
            experiencia: marcadorInfo.experiencia,
            descripcion: marcadorInfo.descripcion,
            userId: marcadorInfo.userId,
            fechaCreacion: marcadorInfo.fechaCreacion,
            fotoUrl: marcadorInfo.fotoUrl,
          );
          _marcadoresInfo[marcadorInfo.id] = marcadorConWidget;
        }
      });
      _notificarCambios();
    });
  }

  // Método auxiliar para crear imagen del marcador
  Widget _imagenMarcador(String tipoExp, String exp) {
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

  // Mostrar información de un marcador sin permitir edición
  void _mostrarInfoMarcador(MarcadorInfo marcador) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: theme.dialogTheme.backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    l10n.markerInfo,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            marcador.tipoExperiencia == 'Bueno'
                                ? Icons.sentiment_satisfied
                                : marcador.tipoExperiencia == 'Regular'
                                    ? Icons.sentiment_neutral
                                    : Icons.sentiment_dissatisfied,
                            color: marcador.tipoExperiencia == 'Bueno'
                                ? Colors.green
                                : marcador.tipoExperiencia == 'Regular'
                                    ? Colors.amber
                                    : Colors.red,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${l10n.type}: ${marcador.tipoExperiencia}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${l10n.experience}: ${marcador.experiencia}",
                                  style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (marcador.descripcion.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          l10n.description,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          marcador.descripcion,
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${l10n.reported}: ${_formatearFecha(marcador.fechaCreacion, l10n)}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.close),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Formatear fecha de forma legible
  String _formatearFecha(DateTime fecha, AppLocalizations l10n) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);
    
    if (diferencia.inDays == 0) {
      if (diferencia.inHours == 0) {
        return l10n.timeAgoMinutes.replaceAll('{0}', '${diferencia.inMinutes}');
      }
      return l10n.timeAgoHours.replaceAll('{0}', '${diferencia.inHours}');
    } else if (diferencia.inDays == 1) {
      return l10n.timeAgoYesterday;
    } else if (diferencia.inDays < 7) {
      return l10n.timeAgoDays.replaceAll('{0}', '${diferencia.inDays}');
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  void _abrirDialogoMarcador({required LatLng posicion, String? idExistente}) async {
    final marcadorExistente = idExistente != null ? _marcadoresInfo[idExistente] : null;
    
    // Verificar si el usuario actual puede editar este marcador
    final currentUserId = _authService.currentUser?.uid;
    final bool puedeEditar = idExistente == null || 
        (marcadorExistente != null && marcadorExistente.userId == currentUserId);
    
    if (idExistente != null && !puedeEditar) {
      // Solo mostrar información, no permitir edición
      _mostrarInfoMarcador(marcadorExistente!);
      return;
    }

    // Valores internos constantes (no traducidos)
    const String valorBueno = 'Bueno';
    const String valorRegular = 'Regular';
    const String valorMalo = 'Malo';
    const String valorSinIncidente = 'Sin incidente';
    const String valorRobo = 'Robo';
    const String valorAccidente = 'Accidente';
    const String valorCalleOscura = 'Calle oscura';
    const String valorOtra = 'Otra';
    
    String tipoExperiencia = marcadorExistente?.tipoExperiencia ?? valorBueno;
    String experiencia = marcadorExistente?.experiencia ?? valorSinIncidente;
    String otraExperiencia = '';
    String descripcion = marcadorExistente?.descripcion ?? '';

    // Si el marcador anterior tenía una experiencia "Otra" la restauramos
    if (![valorSinIncidente, valorRobo, valorAccidente, valorCalleOscura].contains(experiencia)) {
      otraExperiencia = experiencia;
      experiencia = valorOtra;
    }

    final TextEditingController descripcionController =
        TextEditingController(text: descripcion);
    final TextEditingController otraExperienciaController =
        TextEditingController(text: otraExperiencia);

    final List<String> opcionesExperiencia = [
      valorSinIncidente,
      valorRobo,
      valorAccidente,
      valorCalleOscura,
      valorOtra,
    ];

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: theme.dialogTheme.backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setStateDialog) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      idExistente == null ? l10n.addExperience : l10n.editMarker,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  //Tipo de experiencia
                  Text(
                    l10n.experienceType,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300,
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: tipoExperiencia,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(
                          value: valorBueno,
                          child: Row(
                            children: [
                              const Icon(Icons.sentiment_satisfied, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(l10n.good),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: valorRegular,
                          child: Row(
                            children: [
                              const Icon(Icons.sentiment_neutral, color: Colors.amber),
                              const SizedBox(width: 8),
                              Text(l10n.regular),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: valorMalo,
                          child: Row(
                            children: [
                              const Icon(Icons.sentiment_dissatisfied, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(l10n.bad),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          tipoExperiencia = value!;
                          // Si es buena, deshabilitamos los incidentes
                          if (tipoExperiencia == valorBueno) {
                            experiencia = valorSinIncidente;
                          }
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tipo de incidente
                  Text(
                    l10n.incidentType,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Opacity(
                    opacity: tipoExperiencia == valorBueno ? 0.5 : 1.0,
                    child: IgnorePointer(
                      ignoring: tipoExperiencia == valorBueno,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300,
                          ),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: const SizedBox(),
                          value: opcionesExperiencia.contains(experiencia)
                              ? experiencia
                              : valorSinIncidente,
                          items: [
                            DropdownMenuItem(value: valorSinIncidente, child: Text(l10n.noIncident)),
                            DropdownMenuItem(value: valorRobo, child: Text(l10n.robbery)),
                            DropdownMenuItem(value: valorAccidente, child: Text(l10n.accident)),
                            DropdownMenuItem(value: valorCalleOscura, child: Text(l10n.darkStreet)),
                            DropdownMenuItem(value: valorOtra, child: Text(l10n.other)),
                          ],
                          onChanged: (value) {
                            setStateDialog(() {
                              experiencia = value!;
                            });
                          },
                        ),
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

                  const SizedBox(height: 16),

                  //Descripción
                  Text(
                    l10n.description,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descripcionController,
                    maxLines: 3,
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      hintText: l10n.addDetails,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                    ),
                    onChanged: (value) {
                      descripcion = value;
                    },
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt),
                    label: Text(l10n.addPhoto),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      side: BorderSide(color: theme.colorScheme.secondary),
                      foregroundColor: theme.colorScheme.secondary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (idExistente != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              _eliminarMarcador(idExistente);
                            },
                            icon: const Icon(Icons.delete, size: 20),
                            label: Text(l10n.delete),
                          ),
                        ),
                      if (idExistente != null) const SizedBox(width: 12),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: idExistente != null ? 1 : 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _guardarMarcador(
                              idExistente ??
                                  DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                              posicion,
                              tipoExperiencia,
                              tipoExperiencia == valorBueno
                                  ? valorSinIncidente
                                  : (experiencia == valorOtra
                                      ? otraExperienciaController.text
                                      : experiencia),
                              descripcionController.text,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(idExistente == null ? l10n.add : l10n.save),
                        ),
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
  ) async {
    final l10n = AppLocalizations.of(context);
    final currentUserId = _authService.currentUser?.uid;
    
    if (currentUserId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mustLogin)),
      );
      return;
    }

    // Verificar si es actualización o creación nueva
    final bool esNuevo = !_marcadoresInfo.containsKey(id);
    
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
          child: _imagenMarcador(tipoExperiencia, experiencia),
        ),
      ),
    );

    final marcadorInfo = MarcadorInfo(
      id: id,
      marker: marcador,
      tipoExperiencia: tipoExperiencia,
      experiencia: experiencia,
      descripcion: descripcion,
      userId: currentUserId,
      fechaCreacion: esNuevo ? DateTime.now() : (_marcadoresInfo[id]?.fechaCreacion ?? DateTime.now()),
    );

    // Guardar en Firebase
    final resultado = esNuevo
        ? await _marcadoresService.crearMarcador(marcadorInfo)
        : await _marcadoresService.actualizarMarcador(marcadorInfo);

    if (!mounted) return;

    if (resultado['success']) {
      // Para el reporte diario (solo si es nuevo)
      if (esNuevo) {
        context.read<ZonasProvider>().registrarReporteHoy();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(esNuevo ? l10n.markerCreated : l10n.markerUpdated),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(esNuevo ? l10n.errorCreating : l10n.errorUpdating),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    // No necesitamos llamar setState ni _notificarCambios 
    // porque el listener de Firebase lo hará automáticamente
  }

  void _eliminarMarcador(String id) async {
    final l10n = AppLocalizations.of(context);
    final resultado = await _marcadoresService.eliminarMarcador(id);
    
    if (!mounted) return;
    
    if (resultado['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.markerDeleted),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorDeleting),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    // No necesitamos setState ni _notificarCambios
    // porque el listener de Firebase lo hará automáticamente
  }
  
  void _notificarCambios() {
    if (widget.onDataChanged != null) {
      int seguras = _marcadoresInfo.values
          .where((m) => m.tipoExperiencia.toLowerCase() == 'bueno')
          .length;
  
      int riesgoMedio = _marcadoresInfo.values
          .where((m) => m.tipoExperiencia.toLowerCase() == 'regular')
          .length;
  
      int peligrosas = _marcadoresInfo.values
          .where((m) => m.tipoExperiencia.toLowerCase() == 'malo')
          .length;
  
      final conteos = {
        'seguras': seguras,
        'riesgoMedio': riesgoMedio,
        'peligrosas': peligrosas,
      };
  
      // DEBUG: imprimir en consola para verificar flujo
      debugPrint('mapa.dart -> _notificarCambios: marcadores=${_marcadoresInfo.length}, conteos=$conteos');
  
      widget.onDataChanged!(
        _marcadoresInfo,
        conteos,
      );
    }
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
                          angle: (_currentHeading * (3.141592 / 180)) * -1,
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

