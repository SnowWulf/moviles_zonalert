# Reglas de Seguridad de Firestore para ZonAlert

## Configuración de Reglas

Para que la funcionalidad de marcadores funcione correctamente, debes configurar las siguientes reglas en tu proyecto de Firebase:

### Cómo aplicar las reglas:

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Firestore Database** → **Reglas**
4. Copia y pega las siguientes reglas:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Reglas para la colección de usuarios
    match /usuarios/{userId} {
      // Los usuarios pueden leer su propia información
      allow read: if request.auth != null && request.auth.uid == userId;
      
      // Los usuarios pueden crear su propio documento
      allow create: if request.auth != null && request.auth.uid == userId;
      
      // Los usuarios pueden actualizar su propia información
      allow update: if request.auth != null && request.auth.uid == userId;
      
      // No se permite eliminar usuarios
      allow delete: if false;
    }
    
    // Reglas para la colección de marcadores
    match /marcadores/{marcadorId} {
      // Todos los usuarios autenticados pueden leer todos los marcadores
      allow read: if request.auth != null;
      
      // Solo usuarios autenticados pueden crear marcadores
      // Y deben incluir su userId en el documento
      allow create: if request.auth != null 
                    && request.resource.data.userId == request.auth.uid
                    && request.resource.data.keys().hasAll([
                      'id', 'latitud', 'longitud', 'tipoExperiencia',
                      'experiencia', 'descripcion', 'userId', 'fechaCreacion'
                    ]);
      
      // Solo el creador puede actualizar su marcador
      allow update: if request.auth != null 
                    && resource.data.userId == request.auth.uid
                    && request.resource.data.userId == resource.data.userId;
      
      // Solo el creador puede eliminar su marcador
      allow delete: if request.auth != null 
                    && resource.data.userId == request.auth.uid;
    }
  }
}
```

### Explicación de las Reglas:

#### Colección `usuarios`:
- **read**: Solo el propietario puede leer su información
- **create**: Los usuarios pueden crear su propio documento
- **update**: Solo el propietario puede actualizar su información
- **delete**: Deshabilitado para proteger los datos

#### Colección `marcadores`:
- **read**: Cualquier usuario autenticado puede ver todos los marcadores
- **create**: 
  - Requiere autenticación
  - El userId debe coincidir con el usuario autenticado
  - Debe incluir todos los campos requeridos
- **update**: 
  - Solo el creador puede modificar el marcador
  - No se permite cambiar el userId
- **delete**: Solo el creador puede eliminar el marcador

### Validaciones adicionales:

Las reglas validan que:
1. Los usuarios estén autenticados antes de cualquier operación
2. Los marcadores solo puedan ser modificados por sus creadores
3. No se pueda cambiar el propietario de un marcador
4. Todos los campos requeridos estén presentes al crear un marcador

### Aplicar las reglas:

1. Copia las reglas anteriores
2. Ve a Firebase Console → Firestore → Reglas
3. Pega las reglas
4. Haz clic en **Publicar**

⚠️ **Importante**: Sin estas reglas, la aplicación no funcionará correctamente o será insegura.
