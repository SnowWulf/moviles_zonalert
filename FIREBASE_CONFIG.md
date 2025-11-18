# Configuración de Firebase para ZonAlert

Este documento explica los archivos de configuración de Firebase incluidos en el repositorio.

## ⚠️ NOTA IMPORTANTE

Este es un proyecto personal y educativo. Los archivos de configuración de Firebase están incluidos en el repositorio para facilitar el desarrollo y despliegue.

**EN UN PROYECTO PROFESIONAL O PÚBLICO, ESTOS ARCHIVOS DEBERÍAN ESTAR EN `.gitignore` POR SEGURIDAD.**

## 📁 Archivos de Configuración Incluidos

### 1. **Android**: `android/app/google-services.json`
- Configuración de Firebase para Android
- Contiene: API Keys, Project ID, package names
- Generado desde Firebase Console

### 2. **iOS**: `ios/Runner/GoogleService-Info.plist`
- Configuración de Firebase para iOS
- Contiene: API Keys, Project ID, Bundle ID
- Generado desde Firebase Console

### 3. **Flutter/Dart**: `lib/firebase_options.dart`
- Opciones de Firebase para todas las plataformas
- Generado con FlutterFire CLI: `flutterfire configure`
- Contiene configuraciones para: Web, Android, iOS, macOS, Windows

### 4. **Firebase CLI**: `firebase.json`
- Configuración del proyecto Firebase
- Define las plataformas y rutas de los archivos de configuración

### 5. **Firebase Project**: `.firebaserc`
- Define el proyecto Firebase activo
- Proyecto actual: `test-5c420`

## 🔧 Cómo Configurar Firebase

### Método 1: Usar los archivos existentes (Recomendado)
Si clonas este repositorio, los archivos ya están configurados. Solo necesitas:

1. **Habilitar Cloud Firestore** en Firebase Console:
   - Ve a: https://console.firebase.google.com/project/test-5c420/firestore
   - Haz clic en "Crear base de datos"
   - Selecciona modo y ubicación
   - Espera 2-5 minutos

2. **Habilitar Firebase Authentication**:
   - Ve a: https://console.firebase.google.com/project/test-5c420/authentication
   - Habilita "Email/Password" en Sign-in methods

3. **Ejecutar la app**:
   ```bash
   flutter pub get
   flutter run
   ```

### Método 2: Reconfigurar desde cero
Si necesitas cambiar el proyecto de Firebase o reconfigurar:

1. **Instalar FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configurar Firebase**:
   ```bash
   flutterfire configure
   ```
   - Selecciona el proyecto: `test-5c420`
   - Selecciona las plataformas que uses

3. **Descargar archivos de configuración**:
   - **Android**: Descarga `google-services.json` desde Firebase Console y colócalo en `android/app/`
   - **iOS**: Descarga `GoogleService-Info.plist` desde Firebase Console y colócalo en `ios/Runner/`

## 🔐 Información del Proyecto

- **Project ID**: test-5c420
- **Project Number**: 992213462471
- **Database URL**: https://test-5c420-default-rtdb.firebaseio.com
- **Storage Bucket**: test-5c420.firebasestorage.app

## 📦 Package Names / Bundle IDs

- **Android**: `com.example.zonalert_new`
- **iOS**: `com.example.zonalertNew`
- **Web**: Configurado para dominio de Firebase

## 🛠️ Servicios de Firebase Habilitados

- ✅ **Firebase Authentication** (Email/Password)
- ✅ **Cloud Firestore** (Base de datos NoSQL)
- ⚠️ **Realtime Database** (Configurado pero no usado actualmente)
- ⚠️ **Cloud Storage** (Configurado pero no usado actualmente)

## 🚀 Scripts Útiles

### Windows PowerShell
El archivo `setup_firebase.ps1` contiene comandos útiles para configurar Firebase.

### Comandos comunes:
```bash
# Ver configuración actual
firebase projects:list

# Usar un proyecto específico
firebase use test-5c420

# Reconfigurar FlutterFire
flutterfire configure

# Actualizar dependencias
flutter pub get
```

## 📱 Plataformas Soportadas

- ✅ Android (Totalmente configurado)
- ✅ iOS (Totalmente configurado)
- ✅ Web (Totalmente configurado)
- ⚠️ macOS (Configuración placeholder - requiere configuración adicional)
- ⚠️ Windows (Configuración placeholder - requiere configuración adicional)

## 🔍 Verificar Configuración

Para verificar que Firebase está correctamente configurado:

1. **Verifica que existan los archivos**:
   - `android/app/google-services.json` ✅
   - `ios/Runner/GoogleService-Info.plist` ✅
   - `lib/firebase_options.dart` ✅
   - `firebase.json` ✅
   - `.firebaserc` ✅

2. **Ejecuta la app y verifica los logs**:
   ```bash
   flutter run -v
   ```
   - No debe haber errores de Firebase
   - Debe inicializar correctamente

## 🐛 Solución de Problemas

### Error: "Cloud Firestore API has not been used"
**Solución**: Habilita Cloud Firestore en Firebase Console.

### Error: "PERMISSION_DENIED"
**Solución**: Verifica las reglas de seguridad en Firestore/Realtime Database.

### Error: "google-services.json not found"
**Solución**: Asegúrate de que el archivo esté en `android/app/google-services.json`.

### Error: "GoogleService-Info.plist not found"
**Solución**: Asegúrate de que el archivo esté en `ios/Runner/GoogleService-Info.plist`.

## 📚 Documentación Adicional

- [Firebase para Flutter](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/project/test-5c420)
