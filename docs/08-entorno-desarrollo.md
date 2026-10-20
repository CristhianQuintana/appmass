# Entorno de desarrollo

Fecha de verificación: 14 de octubre de 2026.

## Versiones observadas

| Herramienta | Versión | Origen |
| --- | --- | --- |
| Flutter | 3.47.4, canal stable | `D:\Flutter`, revisión `9584c6713b` |
| Dart | 3.13.3 | Incluido en ese Flutter |
| Android SDK | 36.0.0 | `C:\Users\USER\AppData\Local\Android\sdk` |
| Emulador instalado | 37.1.11.0 | Sin un dispositivo virtual en ejecución |
| Sistema | Windows 11 25H2 | `flutter doctor` |

## Dependencias resueltas con `flutter pub add`

| Paquete | Restricción |
| --- | --- |
| flutter_riverpod | 3.4.3 |
| go_router | 18.0.2 |
| supabase_flutter | 2.18.3 |
| flutter_secure_storage | 11.2.0 |
| http | 1.6.0 |

`http` ya llegaba de forma transitiva. Se declaró de forma directa porque el repositorio de autenticación clasifica `ClientException`. `intl` y `url_launcher` también llegan por transitividad. No se usan todavía: el formato de moneda entra con los pedidos y el mapa externo con las entregas.

## Android

- `minSdk` 27, como propone la especificación de seguridad.
- `applicationId` sigue siendo `com.example.app_mass`. Cambiarlo queda pendiente porque afecta la firma.
- Las copias de seguridad automáticas de la app están desactivadas.
- El tráfico en claro está desactivado.

## Problemas que siguen abiertos

- Falta el componente `cmdline-tools`.
- Las licencias de Android no están aceptadas: `flutter doctor --android-licenses`.
- No había un emulador ni un teléfono conectado. La app no se instaló ni se ejecutó en Android.
- Visual Studio está incompleto. No se compiló el objetivo Windows.
- Existe otro Flutter en `C:\Users\USER\flutter`. El proyecto usa el de `D:\Flutter`, que coincide con `android/local.properties`.

## Comprobaciones ejecutadas

- `flutter pub get` resolvió las dependencias.
- `flutter analyze`: sin issues.
- `flutter test`: 30 pruebas aprobadas.
- No se ejecutó `flutter build apk` ni `flutter run` en un dispositivo.
