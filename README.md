# MASS Operaciones

Aplicación Flutter para el ciclo operativo de pedidos de un minimarket: registro, preparación, asignación y entrega. El proyecto se trata como una solución independiente hasta que exista autorización para usar la marca, el catálogo o los sistemas de Tiendas MASS.

Estado al 14 de octubre de 2026: el flujo operativo de los sprints 2 a 6 está en el código local y en migraciones SQL. No hay proyecto Supabase creado, así que esas reglas no se ejecutaron contra una base real. No hay commit ni repositorio remoto, y la aplicación no se ejecutó en un dispositivo Android.

## Qué hace hoy

- Inicio y cierre de sesión contra Supabase Auth, cuando el entorno local está configurado.
- El rol no se elige en la pantalla de acceso. Sale del perfil guardado en PostgreSQL.
- Un usuario sin perfil, inactivo o con un rol desconocido no entra a las pantallas operativas.
- La sesión se guarda cifrada con el almacén del sistema, no en texto plano.
- Catálogo de prueba, registro de pedidos, preparación, asignación, mapa externo, resultado de entrega, resumen y personal. Los importes y los cambios de estado los confirma PostgreSQL.

## Requisitos

- Flutter 3.47.4, canal stable, en `D:\Flutter`
- Dart 3.13.3
- Android SDK 36, con licencias aceptadas, para compilar Android
- Un proyecto Supabase de desarrollo, separado de cualquier entorno real

`flutter doctor` del 14 de octubre de 2026 reportó Android sin `cmdline-tools` y con licencias sin aceptar. No había un emulador ni un teléfono conectado. Windows, Chrome y Edge sí estaban disponibles.

## Ejecutar en local

```powershell
flutter pub get
copy env\dev.json.example env\dev.json
```

Edita `env/dev.json` con la URL `https` del proyecto y la clave pública (`anon` o `sb_publishable_`). No pongas la clave `service_role` ni una clave `sb_secret_`.

```powershell
flutter run --dart-define-from-file=env/dev.json
```

Sin ese archivo la aplicación abre una pantalla de configuración y no intenta conectar. Desde ahí, **Abrir demostración local** recorre la interfaz con datos ficticios en el dispositivo. `env/dev.json` está ignorado por Git.

## Verificaciones

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

El 14 de octubre de 2026, en esta máquina: `flutter analyze` no reportó issues y `flutter test` terminó con 37 pruebas aprobadas. Esa ejecución no incluye un dispositivo Android ni un proyecto Supabase real.

## Documentación

La definición de producto, el roadmap y los planes de prueba están en `Document/`. Las decisiones de trabajo están en `docs/`. El modelo operativo de los sprints 2 a 6 está en `docs/17-modelo-operativo.md`. Las migraciones están en `supabase/migrations/`.

## Pendiente antes de usarla con cuentas reales

1. Crear el proyecto Supabase de desarrollo y aplicar las migraciones en orden.
2. Desactivar el registro público y definir la política de contraseñas en Auth.
3. Crear el primer administrador con `provision_staff_profile`, usando `service_role` fuera de la app.
4. Comprobar las políticas con un administrador, un operador y un transportista distintos.
5. Aceptar las licencias de Android y ejecutar el flujo en un dispositivo o emulador.
6. Crear el repositorio Git, el primer commit y comprobar la ejecución de GitHub Actions.
