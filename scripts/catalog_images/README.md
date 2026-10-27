# Imágenes del catálogo (demo PRB)

Flujo para proponer y aplicar `image_url` a productos de muestra.

## Requisitos

- Node 18+
- `products.csv` con columnas `sku,name,category`
- Para aplicar en remoto: `SUPABASE_URL` y `SUPABASE_SECRET`

## Comandos

```bash
# Buscar por categoría (Open Food / Products / Beauty Facts), generar CSV+SQL y aplicar
node actualizar_imagenes_via_api.cjs

# Solo generar CSV/SQL
node actualizar_imagenes_via_api.cjs --fetch-only

# Solo aplicar CSV ya aprobado (approved=YES)
node actualizar_imagenes_via_api.cjs --apply-only

# Completar Limpieza / Cuidado personal con búsquedas por término
node fix_nonfood_images.cjs

# Sincronizar seed SQL local con el CSV aprobado
node sync_seed_from_csv.cjs
```

Equivalente Python (si hay Python 3.10+): `proponer_imagenes_mass.py`  
Equivalente Node del script original fila-a-fila: `proponer_imagenes_mass.cjs` (respetar ≤10 búsquedas/min).

## Nota

Los nombres `PRB-*` son genéricos. Las URLs son candidatos de bases abiertas para demo, no el catálogo oficial de Tiendas MASS. Revisar `imagenes_candidatas_mass.csv` antes de usar en producción.
