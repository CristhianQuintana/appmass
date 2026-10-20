# Matriz preliminar de roles y permisos

Fecha: 14 de octubre de 2026  
Estado: propuesta. No está aprobada por un responsable de negocio. La denegación por defecto se aplica a todo lo que no aparece como permitido.

El rol vive en `public.profiles` y solo puede cambiarlo la función `provision_staff_profile`, ejecutable por `service_role`. La aplicación no envía el rol.

## Roles

| Rol técnico | Nombre en la interfaz | Uso |
| --- | --- | --- |
| `administrator` | Administrador | Supervisión y gestión de personal |
| `operator` | Operador | Registro y preparación |
| `courier` | Transportista | Entregas asignadas a su cuenta |
| `unassigned` | Sin rol operativo | Cuenta creada y todavía no habilitada |

No hay rol de cliente en el MVP.

## Acciones

| Acción | Administrador | Operador | Transportista |
| --- | --- | --- | --- |
| Iniciar y cerrar sesión | Sí | Sí | Sí |
| Consultar el propio perfil | Sí | Sí | Sí |
| Consultar perfiles ajenos | No en Sprint 1 | No | No |
| Cambiar el propio rol o activarse | No | No | No |
| Crear o desactivar cuentas | Previsto, solo por un procedimiento de servidor | No | No |
| Consultar pedidos del ámbito | Previsto | Previsto | No |
| Crear un pedido | Previsto | Previsto | No |
| Preparar un pedido | Supervisión prevista | Previsto | No |
| Asignar transportista | Previsto | Previsto si se confirma | No |
| Ver entregas de otros | Previsto para supervisión | No | No |
| Ver la propia entrega | Sí, cuando exista | Según operación | Sí |
| Confirmar entrega o incidencia | No en el flujo normal | Solo atención presencial, por definir | Sí, sobre la asignación propia |
| Consultar auditoría | Previsto, limitado | No | No |

## Datos personales

- Operador: nombre, teléfono y, si el pedido es a domicilio, dirección y referencia.
- Transportista: solo los datos necesarios para entregar un pedido asignado a él.
- Administrador: el mínimo necesario para supervisar. No ve contraseñas ni tokens.
- No se pide DNI ni fecha de nacimiento.

## Pendiente de aprobación

- Si el operador puede asignar transportistas o solo el administrador.
- Si el operador cierra la atención presencial.
- Si el transportista puede rechazar una asignación.
- Qué evidencia de entrega se exige.
- Quién puede cancelar y hasta qué estado.
