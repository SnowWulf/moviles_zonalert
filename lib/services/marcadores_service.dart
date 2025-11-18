import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/marcador_info.dart';

class MarcadoresService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'marcadores';

  // Obtener referencia a la colección
  CollectionReference get _marcadoresRef => _firestore.collection(_collection);

  // Crear un nuevo marcador
  Future<Map<String, dynamic>> crearMarcador(MarcadorInfo marcador) async {
    try {
      await _marcadoresRef.doc(marcador.id).set(marcador.toMap());
      return {
        'success': true,
        'message': 'Marcador creado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al crear marcador: $e',
      };
    }
  }

  // Actualizar un marcador existente
  Future<Map<String, dynamic>> actualizarMarcador(MarcadorInfo marcador) async {
    try {
      await _marcadoresRef.doc(marcador.id).update(marcador.toMap());
      return {
        'success': true,
        'message': 'Marcador actualizado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al actualizar marcador: $e',
      };
    }
  }

  // Eliminar un marcador
  Future<Map<String, dynamic>> eliminarMarcador(String marcadorId) async {
    try {
      await _marcadoresRef.doc(marcadorId).delete();
      return {
        'success': true,
        'message': 'Marcador eliminado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al eliminar marcador: $e',
      };
    }
  }

  // Obtener todos los marcadores (una sola vez)
  Future<List<MarcadorInfo>> obtenerMarcadores() async {
    try {
      QuerySnapshot snapshot = await _marcadoresRef.get();
      return snapshot.docs.map((doc) {
        return MarcadorInfo.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Escuchar cambios en tiempo real
  Stream<List<MarcadorInfo>> escucharMarcadores() {
    return _marcadoresRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MarcadorInfo.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Obtener marcadores de un usuario específico
  Future<List<MarcadorInfo>> obtenerMarcadoresPorUsuario(String userId) async {
    try {
      QuerySnapshot snapshot = await _marcadoresRef
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) {
        return MarcadorInfo.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Verificar si un usuario es propietario de un marcador
  Future<bool> esUsuarioPropietario(String marcadorId, String userId) async {
    try {
      DocumentSnapshot doc = await _marcadoresRef.doc(marcadorId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['userId'] == userId;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Obtener un marcador específico
  Future<MarcadorInfo?> obtenerMarcador(String marcadorId) async {
    try {
      DocumentSnapshot doc = await _marcadoresRef.doc(marcadorId).get();
      if (doc.exists) {
        return MarcadorInfo.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
