# Configuración de Supabase

Fecha: 22 de octubre de 2026  
Estado: hay un proyecto de desarrollo (`kwygymkrlwthddjijdyr`). Las claves reales viven solo en `env/dev.json` (gitignored) y en el panel. Ver también `docs/18-supabase-remoto.md`.

## Entornos

Habrá un proyecto para desarrollo y, más adelante, otro para producción. No se reutilizan claves entre ellos. La app solo recibe la URL HTTPS y la clave pública del entorno que corresponda.

La clave `service_role` y las claves `sb_secret_` se usan solo en el panel de Supabase o en un equipo de administración. No entran en Flutter, en `dart-define`, en logs ni en el repositorio.

## Crear el proyecto de desarrollo

1. Crear un proyecto Supabase nuevo, vacío, en la región que se vaya a operar. No cargar datos personales reales.
2. Anotar la URL y la clave pública.
3. Copiar `env/dev.json.example` a `env/dev.json` y completar esos dos valores.
4. En Authentication, desactivar el registro público.
5. Definir la longitud mínima de contraseña y, si el plan lo permite, el rechazo de contraseñas comprometidas.
6. Dejar vacía o restringida la lista de URL de redirección. No agregar dominios comodín.
7. Aplicar la migración:

```powershell
supabase db push
```

También puede pegarse `supabase/migrations/20261014120000_profiles.sql` en el editor SQL del proyecto de desarrollo. No ejecutarla sobre un proyecto con datos reales sin revisión.

8. Arrancar la app:

```powershell
flutter run --dart-define-from-file=env/dev.json
```

## Qué hace la migración

- Crea `profiles`, relacionado con `auth.users`.
- Al crearse una identidad, el perfil nace `unassigned` e inactivo. Ignora cualquier rol enviado en la metadata.
- RLS obliga a que un usuario autenticado solo lea su fila.
- No hay políticas de inserción, actualización ni borrado para `anon` ni `authenticated`.
- Un disparador rechaza cambios de rol, activación o identificador hechos con el rol JWT `authenticated` o `anon`.
- `provision_staff_profile` actualiza el perfil y escribe `profile_role_events`. Solo `service_role` puede ejecutarla.
- La tabla de eventos tiene RLS sin políticas de lectura para el cliente.

## Comprobaciones que faltan

Estas pruebas no se ejecutaron porque no hay proyecto:

- Un usuario anónimo no lee `profiles`.
- Un usuario autenticado lee solo su fila.
- Ese usuario no lee ni actualiza la fila de otro.
- Una actualización directa de `role` o `is_active` falla.
- `provision_staff_profile` llamada con la clave pública falla.
- La misma función, con `service_role` fuera de la app, cambia el rol y deja un evento.

## Coste y respaldos

Región, límites y copias de seguridad se confirman al crear el proyecto. No se eligió un plan de pago.
