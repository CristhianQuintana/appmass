# Revisión del Sprint 1

Fecha: 14 de octubre de 2026  
Resultado: incremento local construido y probado en código. No está cerrado para un piloto ni para cuentas reales.

## Hecho

- Estructura `lib/app`, `lib/core` y `lib/features`.
- Tema claro con el amarillo, el negro y el blanco del mockup.
- Riverpod y `go_router`.
- Arranque de Supabase solo con configuración HTTPS y clave pública.
- Ingreso, recuperación genérica y cierre de sesión.
- Migración de perfiles con RLS y provisión de roles fuera del cliente.
- Inicios separados para administrador, operador y transportista, sin datos operativos simulados.
- 30 pruebas automáticas aprobadas el 14 de octubre de 2026.

## Probado

- Validación de correo y contraseña.
- Rechazo de claves privilegiadas en la configuración.
- Un envío de login no se duplica mientras el primero sigue en curso.
- Credenciales rechazadas y fallos de red no abren sesión.
- Un anónimo, un perfil inactivo y un error de perfil no entran al inicio operativo.
- Cerrar sesión quita la identidad y vuelve al ingreso.
- Cada rol, en la función de redirección, solo permanece en su propia ruta.

Esas pruebas usan repositorios simulados. No hablan con Supabase.

## No probado

- Login real, caducidad del enlace de recuperación y revocación de una cuenta deshabilitada.
- Las políticas RLS contra dos identidades de prueba.
- Instalación y uso en Android.
- GitHub Actions. El archivo `.github/workflows/flutter-ci.yml` no se ha ejecutado.
- MFA.

## Decisión

Se puede seguir con la preparación del entorno Supabase y la prueba en Android. No se debe empezar el catálogo ni los pedidos hasta tener el proyecto de desarrollo y una fuente de datos explícitamente ficticia o autorizada.

El Sprint 1 no se declara cerrado: faltan la evidencia de RLS, la ejecución en el dispositivo objetivo y la CI.
