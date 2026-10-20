# Modelo operativo

Los sprints 2 a 6 quedan implementados en la aplicación y en las
migraciones. El proyecto de Supabase todavía no existe: las reglas no se
han ejecutado contra una base real.

## Decisiones

- Los importes se guardan en céntimos enteros de sol (PEN).
- El catálogo `PRB-*` es ficticio. La interfaz lo indica y no lo presenta
  como lista oficial de Tiendas MASS.
- El cliente envía producto y cantidad. `create_order` lee el precio
  vigente, calcula el total y el autor con `auth.uid()`.
- La misma clave de idempotencia, para el mismo autor, devuelve el pedido
  ya creado.
- Los estados dependen de la modalidad. Un pedido presencial no se asigna
  a reparto. La reasignación solo cabe en `ready_for_dispatch` o
  `assigned`.
- El transportista solo ve el pedido de su asignación vigente. No puede
  asignarse solo.
- Una entrega exitosa queda cerrada en la misma transacción. Una entrega
  fallida exige un motivo del catálogo.
- El mapa abre solo la dirección, en un enlace externo.
- Un administrador cambia el acceso de otra cuenta con
  `admin_set_staff_access`. No puede cambiar el propio. La aplicación no
  usa `service_role`.
- Desactivar `is_active` no revoca un token de Auth ya emitido. El bloqueo
  de Auth sigue siendo necesario.
- Los productos creados desde la app quedan marcados como muestra.

## Pendiente al conectar Supabase

1. Crear el proyecto y desactivar el registro público.
2. Aplicar las migraciones en orden.
3. Crear el primer administrador con `provision_staff_profile` desde un
   canal de servicio, fuera de la aplicación.
4. Ejecutar las políticas con un administrador, un operador y un
   transportista distintos.
5. Confirmar que un token antiguo deja de operar después de un bloqueo
   de Auth.

Hasta completar esos pasos, el acceso en vivo, las políticas y el
resultado en un dispositivo Android siguen sin verificarse.
