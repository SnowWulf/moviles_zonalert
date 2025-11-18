# 🚀 Inicio Rápido sin Configurar Firebase

Si quieres probar la app SIN configurar Firebase primero, sigue estos pasos:

## Paso 1: Comentar la inicialización de Firebase

Abre `lib/main.dart` y comenta estas líneas:

```dart
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Comenta estas líneas:
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  
  await AlertHelper.init();
  // ... resto del código
}
```

## Paso 2: Cambiar el home en main.dart

Cambia la línea del home:

```dart
// En lugar de:
home: const SplashScreen(),

// Usa directamente:
home: const HomePage(),
```

## Paso 3: Ejecutar

```bash
flutter run
```

---

## ⚠️ Nota Importante

Esto es solo para PROBAR la interfaz sin Firebase. Para usar las funcionalidades de autenticación necesitas configurar Firebase siguiendo `FIREBASE_SETUP.md`.

## Características que NO funcionarán sin Firebase:

- ❌ Registro de usuarios
- ❌ Inicio de sesión
- ❌ Cerrar sesión
- ❌ Recuperación de contraseña
- ❌ Guardado de datos de usuario

## Características que SÍ funcionarán:

- ✅ Navegación entre pantallas
- ✅ Mapa
- ✅ Configuraciones
- ✅ Temas claro/oscuro
- ✅ Cambio de idioma
- ✅ UI completa

---

**Recomendación:** Configura Firebase correctamente usando `setup_firebase.ps1` o `FIREBASE_SETUP.md` para tener todas las funcionalidades.
