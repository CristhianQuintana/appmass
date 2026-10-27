# Supabase remoto — App MASS

Fecha: 22 de octubre de 2026  
Proyecto: `kwygymkrlwthddjijdyr`  
URL: `https://kwygymkrlwthddjijdyr.supabase.co`

## Estado

Al 24 de octubre de 2026 el SQL remoto ya está aplicado (opción A). Hay 8 productos `PRB-*` y cuatro cuentas de prueba activas. `env/dev.json` apunta al proyecto `kwygymkrlwthddjijdyr` con la clave pública.

La app Flutter usa solo la URL y la clave pública (`sb_publishable_` o JWT `anon`). La clave `sb_secret_` / `service_role` no entra en Flutter.

Pendiente manual en el panel: apagar **Allow new users to sign up** en Authentication → Providers → Email. La app no tiene pantalla de registro, pero conviene cerrarlo igual.

## Catálogo de 100 productos con imagen

Script idempotente (columna `image_url` + 100 SKU `PRB-001`…`PRB-100`):

- `supabase/scripts/seed_100_products_with_images.sql`
- Migración: `supabase/migrations/20261024120000_product_images_catalog100.sql`
- Generador: `node scripts/generate_100_products.cjs`
- Carga por API (si la columna ya existe): `node scripts/seed_products_via_api.cjs`

Las URLs usan `https://picsum.photos/seed/mass-prb-xxx/400/400` (placeholders, no fotos oficiales de MASS). La app muestra la imagen en catálogo, carrito y detalle.

## 1. Configurar Flutter

```powershell
copy env\dev.json.example env\dev.json
```

Contenido de `env/dev.json` (ya gitignored):

```json
{
  "SUPABASE_URL": "https://kwygymkrlwthddjijdyr.supabase.co",
  "SUPABASE_ANON_KEY": "<sb_publishable_ o anon JWT>"
}
```

```powershell
D:\Flutter\bin\flutter.bat run -d chrome --release --web-port 7357 --dart-define-from-file=env/dev.json
```

Sin ese archivo la app sigue ofreciendo la demostración local. Con él, el ingreso usa Auth real.

## 2. Aplicar el esquema (elige una vía)

### A. Editor SQL del panel (sin CLI)

1. Abre [SQL Editor](https://supabase.com/dashboard/project/kwygymkrlwthddjijdyr/sql/new).
2. Genera el archivo único:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_bootstrap_sql.ps1
```

3. Pega el contenido de `supabase/remote_bootstrap.sql` y ejecuta **Run**.
4. Desactiva altas públicas: **Authentication → Sign In / Providers → Email**.
   Busca el interruptor **Allow new users to sign up** (o **Enable sign ups**) y apágalo.
   No aparece como “cancelar registro público”; ese es el nombre correcto en el panel actual.
   Si no lo ves, abre [Providers](https://supabase.com/dashboard/project/kwygymkrlwthddjijdyr/auth/providers).

### B. CLI / Node con contraseña de base

La contraseña está en Project Settings → Database (no es `sb_secret_`).

```powershell
$env:SUPABASE_URL = "https://kwygymkrlwthddjijdyr.supabase.co"
$env:SUPABASE_SECRET = "<sb_secret_ del panel>"
$env:SUPABASE_DB_PASSWORD = "<database password>"
$env:SUPABASE_PROJECT_REF = "kwygymkrlwthddjijdyr"
$env:SUPABASE_REGION = "us-east-1"

npm install pg --no-save
node scripts\apply_migrations.cjs
```

Equivalente con CLI:

```powershell
npx supabase link --project-ref kwygymkrlwthddjijdyr
npx supabase db push
```

### Orden de las migraciones

1. `20261014120000_profiles.sql` — perfiles, RLS, `provision_staff_profile`
2. `20261014200000_operations.sql` — productos, pedidos, entregas, RPCs
3. `20261014201000_sample_products.sql` — catálogo `PRB-*` de prueba
4. `20261022120000_customer_cart.sql` — rol `customer`, carrito, permisos de compra

## 3. Crear usuarios de prueba

Después del esquema:

```powershell
$env:SUPABASE_URL = "https://kwygymkrlwthddjijdyr.supabase.co"
$env:SUPABASE_SECRET = "<sb_secret_>"
node scripts\provision_users.cjs
```

Cuentas (contraseña `Demostracion1`):

| Correo | Rol |
| --- | --- |
| marco.admin@mass.local | administrator |
| ana.operadora@mass.local | operator |
| luis.reparto@mass.local | courier |
| rosa.cliente@mass.local | customer |

## 4. Comprobaciones rápidas

```powershell
# Anónimo no lee perfiles
# Autenticado lee solo su fila
# Operador crea pedido; transportista no lee catálogo
# Cliente lee productos activos y solo sus pedidos
D:\Flutter\bin\flutter.bat test
D:\Flutter\bin\flutter.bat analyze --no-pub
```

## Seguridad

- No subir `env/dev.json`, `sb_secret_` ni la contraseña de Postgres.
- El cliente no envía precios ni totales: `create_order` los calcula en el servidor.
- `admin_set_staff_access` no puede asignar el rol `customer` (sigue limitado al personal).
- `provision_staff_profile` solo la ejecuta `service_role`.
