import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class MarcadorInfo {
  String id;
  Marker marker;
  String tipoExperiencia;
  String experiencia;
  String descripcion;
  String userId; // ID del usuario que creó el marcador
  DateTime fechaCreacion;
  String? fotoUrl; // URL de la foto (opcional)

  MarcadorInfo({
    required this.id,
    required this.marker,
    required this.tipoExperiencia,
    required this.experiencia,
    required this.descripcion,
    required this.userId,
    required this.fechaCreacion,
    this.fotoUrl,
  });

  // Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitud': marker.point.latitude,
      'longitud': marker.point.longitude,
      'tipoExperiencia': tipoExperiencia,
      'experiencia': experiencia,
      'descripcion': descripcion,
      'userId': userId,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fotoUrl': fotoUrl,
    };
  }

  // Crear desde Map de Firebase (sin el marker, se crea después)
  factory MarcadorInfo.fromMap(Map<String, dynamic> map, String docId) {
    return MarcadorInfo(
      id: docId,
      marker: Marker(
        point: LatLng(map['latitud'] as double, map['longitud'] as double),
        width: 50,
        height: 50,
        child: Container(), // Se reemplazará en el UI
      ),
      tipoExperiencia: map['tipoExperiencia'] as String,
      experiencia: map['experiencia'] as String,
      descripcion: map['descripcion'] as String,
      userId: map['userId'] as String,
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
      fotoUrl: map['fotoUrl'] as String?,
    );
  }
}