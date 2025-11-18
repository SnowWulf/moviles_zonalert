# Funcionalidad de Marcadores Compartidos - ZonAlert

## 📍 Descripción

Esta funcionalidad permite a los usuarios crear marcadores en el mapa que se sincronizan automáticamente con Firebase, permitiendo que todos los usuarios vean los marcadores de los demás en tiempo real.

## ✨ Características

### 1. **Crear Marcadores**
- Toca cualquier punto del mapa para crear un nuevo marcador
- Completa la información:
  - **Tipo de experiencia**: Bueno, Regular o Malo
  - **Tipo de incidente**: Sin incidente, Robo, Accidente, Calle oscura, u Otra
  - **Descripción**: Detalles adicionales sobre el lugar
  - **Foto**: (Preparado para implementación futura)

### 2. **Visualización en Tiempo Real**
- Todos los marcadores se sincronizan automáticamente
- Los cambios se reflejan instantáneamente en todos los dispositivos
- Diferentes iconos según el tipo de experiencia/incidente

### 3. **Permisos de Edición**
- **Propietario del marcador**: Puede editar y eliminar su marcador
- **Otros usuarios**: Solo pueden ver la información del marcador

### 4. **Información del Marcador**
Al tocar un marcador existente:
- Si eres el propietario: Se abre el diálogo de edición completo
- Si es de otro usuario: Se muestra solo información (lectura)

## 🔒 Seguridad

### Reglas de Firestore
El sistema implementa reglas de seguridad que garantizan:
- Solo usuarios autenticados pueden crear marcadores
- Solo el creador puede modificar o eliminar su marcador
- Todos pueden ver todos los marcadores

**Importante**: Debes configurar las reglas de Firestore. Ver `FIRESTORE_RULES.md`

## 🛠️ Archivos Modificados/Creados

### Nuevos Archivos:
1. **`lib/services/marcadores_service.dart`**
   - Servicio para gestionar marcadores en Firebase
   - Métodos CRUD completos
   - Sincronización en tiempo real

2. **`FIRESTORE_RULES.md`**
   - Reglas de seguridad de Firestore
   - Instrucciones de configuración

### Archivos Modificados:
1. **`lib/models/marcador_info.dart`**
   - Añadidos campos: `id`, `userId`, `fechaCreacion`, `fotoUrl`
   - Métodos `toMap()` y `fromMap()` para Firebase
   - Soporte para serialización

2. **`lib/screens/mapa.dart`**
   - Integración con Firebase Firestore
   - Listener de cambios en tiempo real
   - Sistema de permisos de edición
   - Diálogo de información para marcadores de otros usuarios
   - Mensajes de confirmación/error

## 📱 Flujo de Uso

### Crear un Marcador:
1. Usuario toca el mapa en el punto deseado
2. Se abre el diálogo de creación
3. Usuario completa la información
4. Al presionar "Agregar", el marcador se guarda en Firebase
5. Todos los usuarios conectados ven el nuevo marcador instantáneamente

### Ver Marcador de Otro Usuario:
1. Usuario toca un marcador existente
2. Si no es el propietario, se muestra un diálogo de solo lectura
3. Puede ver tipo de experiencia, incidente, descripción y fecha

### Editar Propio Marcador:
1. Usuario toca su propio marcador
2. Se abre el diálogo de edición completo
3. Puede modificar cualquier campo
4. Puede eliminar el marcador
5. Los cambios se sincronizan automáticamente

## 🔄 Sincronización

### Cómo Funciona:
1. **Listener en Tiempo Real**: 
   ```dart
   _marcadoresService.escucharMarcadores().listen(...)
   ```
   
2. **Actualización Automática**: 
   - Cuando Firebase detecta cambios, el listener recibe la actualización
   - La UI se actualiza automáticamente con `setState()`
   - No es necesario recargar manualmente

3. **Optimización**:
   - Solo se descargan cambios incrementales
   - Los marcadores se mantienen en caché local
   - Funciona offline con sincronización posterior

## 🎨 Iconos de Marcadores

### Por Tipo de Experiencia (sin incidente):
- **Bueno**: cara_buena.png (verde)
- **Regular**: cara_regular.png (amarillo)
- **Malo**: cara_mala.png (rojo)

### Por Tipo de Incidente:
- **Robo**: bandit.png
- **Accidente**: fender.png
- **Calle oscura**: dark.png
- **Otra**: other.png

## ⚙️ Configuración Requerida

### 1. Firebase Console:
- Aplicar reglas de Firestore (ver `FIRESTORE_RULES.md`)
- Verificar que Authentication esté habilitado
- Verificar que Firestore esté creado

### 2. Dependencias (ya incluidas):
```yaml
dependencies:
  cloud_firestore: ^5.4.4
  firebase_auth: ^5.3.1
  firebase_core: ^3.6.0
```

### 3. Usuario Autenticado:
- Los usuarios deben iniciar sesión para crear marcadores
- La app debe tener `AuthService` funcionando correctamente

## 🐛 Solución de Problemas

### El marcador no aparece:
1. Verifica conexión a internet
2. Verifica que el usuario esté autenticado
3. Revisa las reglas de Firestore
4. Verifica logs en Firebase Console

### No puedo editar un marcador:
- Solo el creador puede editar su marcador
- Verifica que estés usando la misma cuenta

### Error de permisos:
- Verifica que las reglas de Firestore estén correctamente configuradas
- Asegúrate de que el usuario esté autenticado

## 📊 Estructura de Datos en Firestore

### Colección: `marcadores`
```javascript
{
  id: "timestamp_string",
  latitud: 1.2136,
  longitud: -77.2811,
  tipoExperiencia: "Malo",
  experiencia: "Robo",
  descripcion: "Ocurrió un robo aquí ayer",
  userId: "uid_del_usuario",
  fechaCreacion: Timestamp,
  fotoUrl: null // Opcional
}
```

## 🚀 Mejoras Futuras

- [ ] Subida de fotos a Firebase Storage
- [ ] Filtros por tipo de experiencia
- [ ] Comentarios en marcadores
- [ ] Reportes de marcadores falsos
- [ ] Estadísticas de marcadores por zona
- [ ] Notificaciones push cuando se crea un marcador cerca
- [ ] Caducidad automática de marcadores antiguos
- [ ] Sistema de votos/validación comunitaria

## 📞 Soporte

Si encuentras algún problema con la funcionalidad de marcadores compartidos, verifica:
1. Reglas de Firestore configuradas correctamente
2. Usuario autenticado
3. Conexión a internet activa
4. Versiones de dependencias compatibles
