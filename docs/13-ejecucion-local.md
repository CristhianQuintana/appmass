# Ejecución local

La guía operativa está en el `README.md` de la raíz. Este archivo fija el orden mínimo para reproducir la verificación hecha el 14 de octubre de 2026.

## Prerrequisitos

- Flutter 3.47.4 en el `PATH`. En esta máquina está en `D:\Flutter\bin`.
- Dart 3.13.3.
- Para Android: SDK 36, licencias aceptadas y un dispositivo o emulador con API 27 o superior. Esos dos últimos puntos no estaban listos.

## Pasos

```powershell
cd <ruta-del-proyecto>
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Para abrir la interfaz conectada a desarrollo, después de crear `env/dev.json`:

```powershell
flutter run --dart-define-from-file=env/dev.json
```

Sin configuración, la app debe mostrar "Configuración requerida" y no una sesión.

## Problemas conocidos

- `flutter doctor` marca `cmdline-tools` ausentes y licencias de Android sin aceptar.
- No hay emulador en ejecución. No se pudo comprobar la instalación en un teléfono.
- El proyecto Supabase de desarrollo no existe, así que el login real no se pudo ejercer.
- El repositorio Git todavía no está inicializado en esta carpeta y no hay remoto.
