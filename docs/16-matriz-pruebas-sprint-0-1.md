# Matriz de pruebas de los Sprints 0 y 1

Fecha de ejecución: 14 de octubre de 2026  
Comando: `flutter test`  
Resultado de esa corrida: 30 pruebas aprobadas, código de salida 0.  
`flutter analyze`: sin issues.  
No hubo dispositivo Android ni proyecto Supabase. Esos casos quedan bloqueados o sin probar, no aprobados.

| Caso | Qué se hizo | Estado |
| --- | --- | --- |
| S0-T01 Trazabilidad | Requisitos de acceso relacionados con rutas y pruebas en esta matriz | Parcial. Falta aprobación de negocio |
| S0-T02 Alcance | Exclusiones escritas en `docs/02-alcance-mvp.md` | Parcial. Sin acta de aprobación |
| S0-T03 Roles | Matriz en `docs/03-matriz-roles-permisos.md` | Parcial. Sigue siendo propuesta |
| S0-T04 Entornos | No hay claves de producción en el repositorio | Aprobado por inspección de archivos. El proyecto de desarrollo todavía no existe |
| S0-T05 Secretos | Búsqueda de `service_role`, `sb_secret_` y JWT. Solo hay nombres de rol, mensajes y un JWT de prueba fabricado en el test | Aprobado en el árbol actual. No certifica el binario instalado |
| S0-T06 Versiones | `flutter doctor` y `flutter pub get` | Parcial. Android sin licencias ni dispositivo |
| S0-T07 Migración | SQL versionado, no aplicado | Bloqueado |
| S0-T08 Plan de pruebas | Este archivo y `Document/Pruebas/Pruebas.md` | Parcial |
| S1-T01 Login correcto | El controlador pasa a sesión iniciada con un repositorio simulado. El operador de prueba llega a su inicio | Parcial. Falta Supabase real |
| S1-T02 Credenciales incorrectas | Mensaje genérico, sin el correo, y la sesión sigue cerrada | Aprobado en la lógica de cliente |
| S1-T03 Campos vacíos o inválidos | Pruebas de validador y de la pantalla | Aprobado |
| S1-T04 Envío repetido | El segundo toque no incrementa la llamada | Aprobado |
| S1-T05 Ruta protegida sin sesión | `resolveRedirect` manda al ingreso. La app sin configuración no muestra el ingreso interno | Aprobado en prueba. Deep link en Android sin probar |
| S1-T06 Perfil no disponible | Perfil inactivo y error de lectura terminan en "Acceso no habilitado" | Aprobado con datos simulados |
| S1-T07 Cierre de sesión | La identidad desaparece y vuelve el ingreso | Aprobado con repositorio simulado |
| S1-T08 Error de red | El fallo de red no marca la sesión como iniciada | Aprobado |
| S1-T09 Recuperación | La respuesta de aceptación no dice que la cuenta exista | Parcial. Enlace vencido o reutilizado sin probar |
| S1-T10 Usuario deshabilitado | La interfaz bloquea `is_active = false`. Auth no revoca el token en esta prueba | Bloqueado en el backend |
| S1-T11 Cambio de usuario | El cierre borra la identidad anterior | Parcial. No se inició una segunda cuenta real |
| S1-T12 Prueba por rol | La redirección cubre los tres roles. El widget cubre al operador, al inactivo y al error | Parcial |

## Defectos abiertos

- No hay defecto de las 30 pruebas automáticas.
- Bloqueo externo: sin Supabase no se puede demostrar RLS ni el login real.
- Bloqueo externo: sin licencias y sin dispositivo no se puede demostrar Android.
