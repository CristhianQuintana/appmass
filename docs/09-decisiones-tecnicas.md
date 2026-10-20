# Decisiones técnicas

Fecha: 14 de octubre de 2026.

## Arquitectura

La interfaz vive en `presentation`, el estado en `application` y el acceso a Supabase en `data`. Las reglas de validación, redirección y lectura del perfil se prueban sin pintar la pantalla o con repositorios simulados.

No se crearon carpetas para pedidos, catálogo, preparación ni reparto. Esos módulos todavía no tienen código.

## Estado y navegación

Riverpod 3.4.3 es la única biblioteca de estado. `go_router` 18.0.2 decide la ruta con la sesión y el perfil. Ocultar una ruta no autoriza la operación: cuando existan pedidos, PostgreSQL tendrá que filtrarlos.

La consulta del perfil no reintenta sola. Si falla, la pantalla explica el error y ofrece reintento. Un reintento automático dejaría la interfaz cargando o podría mostrar datos de una cuenta anterior.

## Supabase

Se usa la clave pública con `publishableKey`. El arranque rechaza HTTP, claves `sb_secret_` y JWT cuyo claim `role` sea `service_role`.

`debug` queda en `false` para que el SDK no imprima la sesión en consola.

El flujo de Auth es PKCE. La sesión y el verificador PKCE se guardan con `flutter_secure_storage` 11.2.0, cifrado en Android mediante el Keystore. El valor por defecto del SDK 2.18.3 es SharedPreferences sin cifrar; no se usó para el token.

No se exige biometría para abrir la sesión. Sería una decisión de producto y dejaría fuera dispositivos sin sensor.

## Conflicto con el mockup de ingreso

El HTML de `Document/Diseño/login.md` permite elegir operador, transportista o supervisor y rellena un correo. También simula un acceso concedido y anuncia servidores operativos.

Eso contradice RF-AUT-02 y la sección 4.1 de las medidas de seguridad. La pantalla implementada pide correo y contraseña. El rol se lee después, desde el perfil. No hay credenciales de ejemplo, no hay semáforo de servidores y la versión mostrada es `1.0.0`, la del `pubspec.yaml`.

El logotipo remoto del mockup no se incrusta. No hay autorización de marca ni conviene depender de una URL externa.

## Lo que no se añadió

- `google_fonts`: Montserrat e Inter se incorporarán solo si se aprueba empaquetar los archivos.
- Registro público y selector de rol.
- Pantallas de carrito o de registro de cliente.
- Datos ficticios de pedidos en las pantallas de inicio. Esas pantallas dicen que el módulo todavía no existe.
- Tema oscuro. La app queda en claro hasta diseñarlo y probarlo.

## Recuperación de contraseña

La pantalla pide el correo y responde de forma genérica. No envía un `redirectTo`, para no abrir una redirección hacia un dominio no autorizado. La caducidad y el uso único del enlace dependen de Supabase Auth y no se pudieron probar.
