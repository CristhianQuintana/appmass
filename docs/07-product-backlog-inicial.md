# Backlog inicial

Fecha: 14 de octubre de 2026  
Estado: planificación. Las historias de catálogo en adelante no están listas para construirse hasta cerrar las decisiones que indican.

## Hechas en esta entrega

| ID | Historia | Prioridad | Criterio verificable |
| --- | --- | --- | --- |
| S1-01 | La aplicación arranca con una estructura por responsabilidades | P0 | `lib/main.dart` solo arranca; el resto vive en `app`, `core` y `features` |
| S1-02 | El acceso usa la paleta del mockup sin elegir rol | P0 | No hay selector de perfil en el ingreso |
| S1-06 | Un usuario puede intentar iniciar sesión y cerrarla | P0 | Pruebas de formulario, error y cierre con repositorios simulados |
| S1-07 | El perfil nace sin privilegios | P0 | La migración inserta `unassigned` e `is_active = false` |
| S1-10 | El cliente no puede cambiar su rol | P0 | No hay política de escritura y la función de provisión no es ejecutable por `authenticated` |

## Listas para el siguiente incremento

| ID | Historia | Prioridad | Dependencia |
| --- | --- | --- | --- |
| S1-LIVE | Probar login, RLS y revocación contra Supabase de desarrollo | P0 | Proyecto Supabase y cuentas ficticias |
| AND-01 | Ejecutar el flujo en Android API 27 o superior | P0 | Licencias del SDK y un emulador o dispositivo |
| GIT-01 | Primer commit, repositorio privado y CI ejecutada | P0 | Autorización para crear el remoto |

## Más adelante

| ID | Épica | Prioridad | Bloqueo |
| --- | --- | --- | --- |
| CAT | Catálogo de prueba y permisos de lectura | P0 | Confirmar que los datos son ficticios |
| PED | Registro y consulta de pedidos | P0 | Estados aprobados y fuente de precio |
| PRE | Preparación y transiciones | P0 | Política de faltantes |
| ENT | Asignación, mapa externo y resultado | P0 | Quién asigna y qué es una entrega fallida |
| ADM | Empleados, clientes y reportes básicos | P1 | Procedimiento de administración |
| CLI | Autoservicio del cliente | P2 | Fuera del MVP |

Una historia no está terminada porque el código exista. Hace falta el criterio de aceptación, la prueba ejecutada y, si toca permisos, la verificación en el servidor.
