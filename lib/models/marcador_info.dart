import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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