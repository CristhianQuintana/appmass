# Administración de usuarios internos

Fecha: 14 de octubre de 2026  
Estado: procedimiento de desarrollo. No es el procedimiento de producción y no se ejecutó, porque el proyecto Supabase no existe.

## Quién autoriza una cuenta

Una persona responsable del proyecto pide la cuenta y define el rol: administrador, operador o transportista. La aplicación no recoge esa elección. En producción, esta acción tendrá que quedar auditada con el actor real. Hoy el evento guarda el rol de base de datos que ejecutó la función, normalmente `service_role`.

## Alta en desarrollo

1. En el proyecto de desarrollo, Authentication, crear el usuario con un correo ficticio. No enviar la contraseña por el repositorio, por un chat persistente ni por un log.
2. Confirmar que el disparador creó `profiles` con rol `unassigned` e `is_active = false`.
3. Desde el editor SQL, con una conexión privilegiada y nunca desde Flutter, ejecutar:

```sql
select public.provision_staff_profile(
  '<uuid-del-usuario>'::uuid,
  'Nombre de prueba',
  'operator',
  true
);
```

Los roles válidos son `administrator`, `operator`, `courier` y `unassigned`.

4. Entrar en la app con ese correo. La pantalla inicial debe corresponder al rol.
5. Repetir con un segundo usuario y comprobar que cada uno solo lee su perfil.

## Baja

1. Poner `target_active` en `false` con la misma función, o deshabilitar al usuario en Authentication.
2. La app debe llevarlo a "Acceso no habilitado" si el perfil queda inactivo.
3. Deshabilitarlo en Authentication es lo que impide nuevas sesiones. El flag `is_active` solo no revoca un token ya emitido. Esa revocación no está probada.

No se borran perfiles con historial operativo futuro. En este sprint no hay pedidos que conservar.

## Separación

Las contraseñas de prueba se rotan si se comparten. Las de producción no se crean con este procedimiento informal. La clave `service_role` no se copia a la máquina de quien solo usa la app.
