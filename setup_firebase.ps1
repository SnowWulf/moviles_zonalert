# Script de configuración de Firebase para ZonAlert
# Ejecuta este script después de configurar tu proyecto en Firebase Console

Write-Host "🔥 Configurador de Firebase para ZonAlert" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si Firebase CLI está instalado
Write-Host "Verificando Firebase CLI..." -ForegroundColor Yellow
$firebaseInstalled = Get-Command firebase -ErrorAction SilentlyContinue

if (-not $firebaseInstalled) {
    Write-Host "❌ Firebase CLI no está instalado." -ForegroundColor Red
    Write-Host "Instálalo con: npm install -g firebase-tools" -ForegroundColor Yellow
    Write-Host "O visita: https://firebase.google.com/docs/cli" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "¿Deseas continuar sin Firebase CLI? (s/n)"
    if ($continue -ne "s") {
        exit
    }
} else {
    Write-Host "✅ Firebase CLI instalado" -ForegroundColor Green
}

Write-Host ""
Write-Host "Selecciona una opción:" -ForegroundColor Cyan
Write-Host "1. Configurar Firebase automáticamente (recomendado)" -ForegroundColor White
Write-Host "2. Abrir guía de configuración manual" -ForegroundColor White
Write-Host "3. Solo instalar dependencias" -ForegroundColor White
Write-Host ""

$opcion = Read-Host "Opción"

switch ($opcion) {
    "1" {
        Write-Host ""
        Write-Host "🚀 Configurando Firebase automáticamente..." -ForegroundColor Cyan
        
        # Login a Firebase
        Write-Host "Iniciando sesión en Firebase..." -ForegroundColor Yellow
        firebase login
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Sesión iniciada correctamente" -ForegroundColor Green
            
            # Configurar FlutterFire
            Write-Host ""
            Write-Host "Configurando FlutterFire..." -ForegroundColor Yellow
            flutterfire configure
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "✅ Firebase configurado correctamente!" -ForegroundColor Green
                Write-Host ""
                Write-Host "Instalando dependencias..." -ForegroundColor Yellow
                flutter pub get
                
                Write-Host ""
                Write-Host "🎉 ¡Configuración completa!" -ForegroundColor Green
                Write-Host ""
                Write-Host "Próximos pasos:" -ForegroundColor Cyan
                Write-Host "1. Habilita Email/Password en Firebase Console > Authentication" -ForegroundColor White
                Write-Host "2. Crea Firestore Database en Firebase Console" -ForegroundColor White
                Write-Host "3. Ejecuta: flutter run" -ForegroundColor White
            } else {
                Write-Host "❌ Error al configurar FlutterFire" -ForegroundColor Red
            }
        } else {
            Write-Host "❌ Error al iniciar sesión en Firebase" -ForegroundColor Red
        }
    }
    
    "2" {
        Write-Host ""
        Write-Host "📖 Abriendo guía de configuración manual..." -ForegroundColor Cyan
        Start-Process "FIREBASE_SETUP.md"
        
        Write-Host ""
        Write-Host "Después de seguir la guía, instala las dependencias con:" -ForegroundColor Yellow
        Write-Host "flutter pub get" -ForegroundColor White
    }
    
    "3" {
        Write-Host ""
        Write-Host "📦 Instalando dependencias..." -ForegroundColor Cyan
        flutter pub get
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ Dependencias instaladas correctamente" -ForegroundColor Green
            Write-Host ""
            Write-Host "No olvides configurar Firebase siguiendo FIREBASE_SETUP.md" -ForegroundColor Yellow
        } else {
            Write-Host "❌ Error al instalar dependencias" -ForegroundColor Red
        }
    }
    
    default {
        Write-Host ""
        Write-Host "❌ Opción no válida" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Presiona Enter para salir..." -ForegroundColor Gray
Read-Host
