# MASS Operaciones

Aplicación Flutter para el ciclo operativo de pedidos de un minimarket: registro, preparación, asignación y entrega. Incluye un apartado de cliente en demostración y, con Supabase configurado, contra la base real.

Estado al 22 de octubre de 2026: el código y las migraciones SQL están el flujo de personal, el catálogo de prueba, pedidos, entregas y el carrito del comprador. El repositorio remoto es [CristhianQuintana/appmass](https://github.com/CristhianQuintana/appmass). El proyecto Supabase de desarrollo es `kwygymkrlwthddjijdyr`. Hasta aplicar el SQL remoto, las tablas no existen en esa instancia.

## Qué hace hoy

- Inicio y cierre de sesión contra Supabase Auth, cuando `env/dev.json` está configurado.
- El rol no se elige en la pantalla de acceso. Sale del perfil en PostgreSQL.
- Catálogo, pedidos, preparación, asignación, mapa externo, entrega, resumen y personal.
- Apartado de cliente: categorías, catálogo, carrito (local y sincronizado por RPC) y seguimiento de pedidos propios.
- Demostración local sin servidor, solo si no hay configuración pública.

## Requisitos

- Flutter 3.47.4 (`D:\Flutter`)
- Proyecto Supabase de desarrollo
- Clave pública (`sb_publishable_` o JWT `anon`). Nunca la `sb_secret_` en la app

## Ejecutar contra Supabase

```powershell
copy env\dev.json.example env\dev.json
# Completa SUPABASE_URL y SUPABASE_ANON_KEY
D:\Flutter\bin\flutter.bat run -d chrome --release --web-port 7357 --dart-define-from-file=env/dev.json
```

Guía completa del esquema, RLS y provisión de usuarios: `docs/18-supabase-remoto.md`.

## Aplicar la base (resumen)

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_bootstrap_sql.ps1
# Pega supabase/remote_bootstrap.sql en el SQL Editor del proyecto
# o:
$env:SUPABASE_DB_PASSWORD = "<Database Settings>"
node scripts\apply_migrations.cjs
$env:SUPABASE_SECRET = "<sb_secret_>"
node scripts\provision_users.cjs
```

## Verificaciones

```powershell
D:\Flutter\bin\flutter.bat analyze --no-pub
D:\Flutter\bin\flutter.bat test
```

## Documentación

- Producto y roadmap: `Document/`
- Decisiones técnicas: `docs/`
- Migraciones: `supabase/migrations/`
