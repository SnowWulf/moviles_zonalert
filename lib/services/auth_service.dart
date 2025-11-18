import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener el usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registrar usuario con email y contraseña
  Future<Map<String, dynamic>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String nombre,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Actualizar el nombre de usuario
        await user.updateDisplayName(nombre);

        // Intentar guardar información adicional en Firestore con timeout
        try {
          await _firestore.collection('usuarios').doc(user.uid).set({
            'uid': user.uid,
            'nombre': nombre,
            'email': email,
            'fechaCreacion': FieldValue.serverTimestamp(),
            'zonasFavoritas': [],
            'reportesRealizados': 0,
          }).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Tiempo de espera agotado al guardar datos');
            },
          );
        } catch (firestoreError) {
          // Si Firestore falla, el usuario ya está creado en Authentication
          // Advertir pero continuar
          return {
            'success': true,
            'user': user,
            'message': 'Usuario registrado (datos pendientes de sincronizar)',
            'warning': true,
          };
        }

        return {
          'success': true,
          'user': user,
          'message': 'Usuario registrado exitosamente',
        };
      }

      return {
        'success': false,
        'message': 'Error al crear el usuario',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'La contraseña es muy débil';
          break;
        case 'email-already-in-use':
          message = 'El correo ya está registrado';
          break;
        case 'invalid-email':
          message = 'El correo electrónico no es válido';
          break;
        default:
          message = 'Error: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }

  // Iniciar sesión con email y contraseña
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return {
        'success': true,
        'user': result.user,
        'message': 'Inicio de sesión exitoso',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Usuario no encontrado';
          break;
        case 'wrong-password':
          message = 'Contraseña incorrecta';
          break;
        case 'invalid-email':
          message = 'Correo electrónico inválido';
          break;
        case 'user-disabled':
          message = 'Usuario deshabilitado';
          break;
        case 'invalid-credential':
          message = 'Credenciales inválidas';
          break;
        default:
          message = 'Error: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Restablecer contraseña
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Correo de recuperación enviado',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Usuario no encontrado';
          break;
        case 'invalid-email':
          message = 'Correo electrónico inválido';
          break;
        default:
          message = 'Error: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }

  // Obtener datos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = currentUser;
      if (user != null) {
        DocumentSnapshot doc =
            await _firestore.collection('usuarios').doc(user.uid).get();
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>?;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Actualizar perfil de usuario
  Future<bool> updateUserProfile({
    String? nombre,
    String? photoUrl,
  }) async {
    try {
      User? user = currentUser;
      if (user != null) {
        if (nombre != null) {
          await user.updateDisplayName(nombre);
          await _firestore.collection('usuarios').doc(user.uid).update({
            'nombre': nombre,
          });
        }
        if (photoUrl != null) {
          await user.updatePhotoURL(photoUrl);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
