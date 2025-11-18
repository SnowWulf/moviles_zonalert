# 🚀 Guía Rápida de Implementación - Marcadores Compartidos

## ✅ Pasos para Activar la Funcionalidad

### 1️⃣ Configurar Reglas de Firestore (OBLIGATORIO)

1. Abre [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto **moviles_zonalert**
3. Ve a **Firestore Database** → **Reglas**
4. Copia y pega las reglas del archivo `FIRESTORE_RULES.md`
5. Haz clic en **Publicar**

⚠️ **Sin este paso, la app no funcionará correctamente**

### 2️⃣ Verificar Índices de Firestore (Opcional pero recomendado)

Firebase puede pedir crear índices compuestos la primera vez que uses ciertas consultas. Si ves un error sobre índices:

1. Firebase te mostrará un link en el log/consola
2. Haz clic en el link
3. Espera a que Firebase cree el índice (toma 1-2 minutos)

### 3️⃣ Probar la Funcionalidad

1. **Ejecuta la app**: `flutter run`
2. **Inicia sesión** con un usuario (requisito para crear marcadores)
3. **Toca el mapa** para crear un marcador
4. **Completa la información** y presiona "Agregar"
5. **Abre la app en otro dispositivo** con diferente usuario para ver sincronización

## 📋 Checklist de Verificación

Antes de probar, asegúrate de que:

- [ ] Firebase está inicializado correctamente (`firebase_options.dart` existe)
- [ ] Reglas de Firestore están configuradas
- [ ] La autenticación de Firebase funciona (usuarios pueden iniciar sesión)
- [ ] Internet está habilitado en el dispositivo/emulador
- [ ] Las dependencias están instaladas: `flutter pub get`

## 🎯 Funcionalidades Implementadas

### ✨ Características Principales:

1. **Crear Marcadores**
   - Toca el mapa → Completa formulario → Guarda
   - Se sincroniza automáticamente con Firebase
   - Visible para todos los usuarios inmediatamente

2. **Ver Marcadores de Otros**
   - Toca cualquier marcador en el mapa
   - Si no es tuyo: Solo lectura (información)
   - Muestra fecha de creación y detalles

3. **Editar/Eliminar Propios Marcadores**
   - Toca tu marcador → Se abre formulario de edición
   - Puedes modificar cualquier campo
   - Botón "Eliminar" disponible solo para propietario

4. **Sincronización en Tiempo Real**
   - Los cambios se reflejan instantáneamente
   - Sin necesidad de recargar
   - Funciona con múltiples usuarios simultáneamente

## 🔧 Archivos Importantes

### Nuevos:
- `lib/services/marcadores_service.dart` - Servicio de Firebase
- `FIRESTORE_RULES.md` - Reglas de seguridad
- `FUNCIONALIDAD_MARCADORES.md` - Documentación completa
- `IMPLEMENTACION_RAPIDA.md` - Este archivo

### Modificados:
- `lib/models/marcador_info.dart` - Modelo con campos Firebase
- `lib/screens/mapa.dart` - Integración Firebase + permisos

## 🐛 Solución Rápida de Problemas

### Problema: "No puedo crear marcadores"
**Solución**: 
- Verifica que estés autenticado (sesión iniciada)
- Revisa las reglas de Firestore

### Problema: "Los marcadores no aparecen"
**Solución**:
- Verifica conexión a internet
- Revisa Firebase Console → Firestore → Colección "marcadores"
- Verifica que las reglas permitan lectura

### Problema: "Error de permisos en Firestore"
**Solución**:
- Asegúrate de haber aplicado las reglas del archivo `FIRESTORE_RULES.md`
- Verifica que el usuario esté autenticado

### Problema: "No puedo editar un marcador"
**Solución**:
- Solo puedes editar tus propios marcadores
- Verifica que uses la misma cuenta que creó el marcador

## 📊 Verificar en Firebase Console

Para ver que todo funciona:

1. Firebase Console → Firestore Database
2. Deberías ver una colección llamada `marcadores`
3. Cada documento tiene:
   - `id`, `latitud`, `longitud`
   - `tipoExperiencia`, `experiencia`, `descripcion`
   - `userId`, `fechaCreacion`
   - `fotoUrl` (opcional, por ahora null)

## 🎨 Tipos de Marcadores

### Iconos por Experiencia (sin incidente):
- 😊 Bueno → cara_buena.png
- 😐 Regular → cara_regular.png
- ☹️ Malo → cara_mala.png

### Iconos por Incidente:
- 🦹 Robo → bandit.png
- 🚗 Accidente → fender.png
- 🌑 Calle oscura → dark.png
- ❓ Otra → other.png

## 📱 Flujo de Usuario

```
Usuario Toca Mapa
    ↓
Sistema Verifica Autenticación
    ↓
[Sí] → Abre Diálogo Creación
    ↓
Usuario Completa Formulario
    ↓
Presiona "Agregar"
    ↓
Se Guarda en Firebase
    ↓
Todos los Usuarios Ven el Marcador
    ↓
[Fin]

[No] → Muestra mensaje "Debes iniciar sesión"
```

## 🔐 Seguridad Implementada

- ✅ Solo usuarios autenticados pueden crear marcadores
- ✅ Solo el creador puede editar/eliminar su marcador
- ✅ Todos pueden ver todos los marcadores
- ✅ No se puede cambiar el propietario de un marcador
- ✅ Validación de campos requeridos en Firestore

## 🚀 Próximos Pasos Recomendados

1. **Configurar reglas de Firestore** (OBLIGATORIO)
2. **Probar con 2+ usuarios** para ver sincronización
3. **Implementar subida de fotos** (preparado en UI)
4. **Añadir filtros** por tipo de experiencia
5. **Configurar notificaciones push** para alertas

## 📞 ¿Necesitas Ayuda?

Si encuentras problemas:

1. Revisa los logs de la app: `flutter logs`
2. Revisa Firebase Console para errores
3. Verifica que las reglas estén publicadas
4. Asegúrate de tener conexión a internet
5. Consulta `FUNCIONALIDAD_MARCADORES.md` para documentación completa

---

**¡Todo listo para usar! 🎉**

La funcionalidad está completamente implementada y lista para producción. Solo necesitas configurar las reglas de Firestore y probar.
