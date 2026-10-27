const fs = require('fs');
const path = require('path');

const categories = [
  [
    'Bebidas',
    'botella',
    [
      'Agua de mesa',
      'Gaseosa cola',
      'Gaseosa lima',
      'Jugo de naranja',
      'Jugo de manzana',
      'Rehidratante',
      'Té frío',
      'Café listo',
      'Energizante',
      'Agua con gas',
      'Néctar de durazno',
      'Bebida de soya',
      'Chicha morada',
      'Limonada',
      'Malta',
    ],
  ],
  [
    'Panadería',
    'unidad',
    [
      'Pan de molde',
      'Pan francés',
      'Pan integral',
      'Croissant',
      'Bizcocho',
      'Galleta de soda',
      'Galleta dulce',
      'Tostadas',
      'Queque',
      'Empanada dulce',
      'Rosquitas',
      'Pan de hamburguesa',
      'Pan pita',
      'Brownies',
      'Alfajor',
    ],
  ],
  [
    'Lácteos',
    'unidad',
    [
      'Leche evaporada',
      'Leche entera',
      'Leche light',
      'Yogurt natural',
      'Yogurt de fresa',
      'Queso fresco',
      'Queso edam',
      'Mantequilla',
      'Margarina',
      'Crema de leche',
      'Leche condensada',
      'Queso mozarela',
      'Yogurt griego',
      'Leche de almendras',
      'Kéfir',
    ],
  ],
  [
    'Abarrotes',
    'bolsa',
    [
      'Arroz extra',
      'Azúcar rubia',
      'Azúcar blanca',
      'Fideos spaguetti',
      'Fideos cabello',
      'Avena',
      'Lentejas',
      'Frejoles',
      'Garbanzos',
      'Maíz morado',
      'Harina de trigo',
      'Sal de mesa',
      'Ají panca',
      'Vinagre',
      'Salsa de soya',
      'Atún en lata',
      'Sardinas',
      'Mayonesa',
      'Kétchup',
      'Mostaza',
    ],
  ],
  [
    'Limpieza',
    'unidad',
    [
      'Detergente',
      'Jabón líquido',
      'Lavavajillas',
      'Lejía',
      'Suavizante',
      'Esponja',
      'Bolsas de basura',
      'Papel higiénico',
      'Servilletas',
      'Limpiavidrios',
      'Desinfectante',
      'Cera para piso',
      'Jabón de tocador',
      'Shampoo',
      'Pasta dental',
    ],
  ],
  [
    'Snacks',
    'paquete',
    [
      'Papas fritas',
      'Chifles',
      'Maní salado',
      'Galletas rellenas',
      'Chocolate de leche',
      'Caramelos',
      'Chicles',
      'Barra de cereal',
      'Tortillas de maíz',
      'Mix de frutos secos',
    ],
  ],
  [
    'Cuidado personal',
    'unidad',
    [
      'Cepillo dental',
      'Hilo dental',
      'Desodorante',
      'Crema corporal',
      'Protector solar',
      'Toallitas húmedas',
      'Algodón',
      'Hisopos',
      'Jabón íntimo',
      'Crema de afeitar',
    ],
  ],
];

const pool = [];
for (const [cat, unit, names] of categories) {
  for (const name of names) {
    pool.push({ cat, unit, name });
  }
}
while (pool.length < 100) {
  const base = pool[pool.length % 50];
  pool.push({ ...base, name: `${base.name} familiar` });
}

function esc(value) {
  return String(value).replace(/'/g, "''");
}

const products = pool.slice(0, 100).map((item, index) => {
  const n = index + 1;
  const sku = `PRB-${String(n).padStart(3, '0')}`;
  const price = 120 + ((n * 37) % 1800);
  const active = n !== 6;
  const sizeHint = n % 3 === 0 ? ' 1 kg' : n % 3 === 1 ? ' 500 ml' : '';
  const name = `${item.name}${sizeHint}`.slice(0, 120);
  const image = `https://picsum.photos/seed/mass-${sku.toLowerCase()}/400/400`;
  return {
    sku,
    name,
    cat: item.cat,
    unit: item.unit,
    price,
    active,
    image,
    desc: 'Producto de prueba. No es un artículo oficial de Tiendas MASS.',
  };
});

const values = products
  .map(
    (p) =>
      `  ('${p.sku}', '${esc(p.name)}', '${esc(p.desc)}', '${esc(p.cat)}', '${esc(p.unit)}', ${p.price}, ${p.active}, true, '${p.image}')`,
  )
  .join(',\n');

const sql = `-- 100 productos de prueba con image_url (HTTPS).
-- Ejecutar en SQL Editor de Supabase. Idempotente por SKU.
-- Las imágenes son placeholders públicos, no fotos oficiales de MASS.

alter table public.products
  add column if not exists image_url text not null default '';

alter table public.products
  drop constraint if exists products_image_url_len;

alter table public.products
  add constraint products_image_url_len check (char_length(image_url) <= 500);

alter table public.products
  drop constraint if exists products_image_url_https;

alter table public.products
  add constraint products_image_url_https check (
    image_url = ''
    or image_url ~* '^https://'
  );

create or replace function public.list_catalog(
  p_query text,
  p_include_inactive boolean
)
returns setof public.products
language plpgsql
stable
security invoker
set search_path = public
as $$
declare
  v_term text := replace(replace(left(btrim(coalesce(p_query, '')), 40), '%', ''), '_', '');
begin
  if p_include_inactive and not public.is_active_role(array['administrator']) then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  return query
  select *
  from public.products
  where (p_include_inactive or is_active)
    and (
      v_term = ''
      or name ilike '%' || v_term || '%'
      or sku ilike '%' || v_term || '%'
    )
  order by name
  limit 120;
end;
$$;

create or replace function public.upsert_product(
  p_id uuid,
  p_sku text,
  p_name text,
  p_description text,
  p_category text,
  p_unit_label text,
  p_price_cents integer,
  p_active boolean,
  p_image_url text default ''
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
  v_image text := coalesce(btrim(p_image_url), '');
begin
  if not public.is_active_role(array['administrator']) then
    raise exception 'not authorized' using errcode = '42501';
  end if;
  if p_sku is null or char_length(btrim(p_sku)) not between 1 and 40
     or p_name is null or char_length(btrim(p_name)) not between 1 and 120
     or coalesce(char_length(p_description), 0) > 400
     or p_category is null or char_length(btrim(p_category)) not between 1 and 40
     or p_unit_label is null or char_length(btrim(p_unit_label)) not between 1 and 40
     or p_price_cents is null or p_price_cents < 0 or p_price_cents > 100000000
     or p_active is null
     or char_length(v_image) > 500
     or (v_image <> '' and v_image !~* '^https://') then
    raise exception 'invalid product' using errcode = '22023';
  end if;

  if p_id is null then
    insert into public.products (
      sku, name, description, category, unit_label, price_cents, is_active, is_sample, image_url
    ) values (
      btrim(p_sku), btrim(p_name), coalesce(btrim(p_description), ''),
      btrim(p_category), btrim(p_unit_label), p_price_cents, p_active, true, v_image
    )
    returning id into v_id;
    return v_id;
  end if;

  update public.products
  set sku = btrim(p_sku),
      name = btrim(p_name),
      description = coalesce(btrim(p_description), ''),
      category = btrim(p_category),
      unit_label = btrim(p_unit_label),
      price_cents = p_price_cents,
      is_active = p_active,
      image_url = v_image,
      updated_at = timezone('utc', now())
  where id = p_id
  returning id into v_id;

  if v_id is null then
    raise exception 'product not found' using errcode = 'P0002';
  end if;
  return v_id;
end;
$$;

revoke all on function public.upsert_product(uuid, text, text, text, text, text, integer, boolean) from public, anon, authenticated;
revoke all on function public.upsert_product(uuid, text, text, text, text, text, integer, boolean, text) from public, anon;
grant execute on function public.upsert_product(uuid, text, text, text, text, text, integer, boolean, text) to authenticated;

create or replace function public.list_cart_items()
returns table (
  product_id uuid,
  sku text,
  name text,
  category text,
  unit_label text,
  price_cents integer,
  quantity integer,
  image_url text
)
language sql
stable
security definer
set search_path = public
as $$
  select
    products.id,
    products.sku,
    products.name,
    products.category,
    products.unit_label,
    products.price_cents,
    cart_items.quantity,
    products.image_url
  from public.carts
  join public.cart_items on cart_items.cart_id = carts.id
  join public.products on products.id = cart_items.product_id
  where carts.user_id = auth.uid()
    and public.is_active_role(array['customer'])
    and products.is_active
  order by products.name;
$$;

insert into public.products (
  sku, name, description, category, unit_label, price_cents, is_active, is_sample, image_url
) values
${values}
on conflict (sku) do update set
  name = excluded.name,
  description = excluded.description,
  category = excluded.category,
  unit_label = excluded.unit_label,
  price_cents = excluded.price_cents,
  is_active = excluded.is_active,
  is_sample = true,
  image_url = excluded.image_url,
  updated_at = timezone('utc', now());

notify pgrst, 'reload schema';
`;

const root = path.resolve(__dirname, '..');
const migrationPath = path.join(
  root,
  'supabase',
  'migrations',
  '20261024120000_product_images_catalog100.sql',
);
const scriptPath = path.join(
  root,
  'supabase',
  'scripts',
  'seed_100_products_with_images.sql',
);
fs.mkdirSync(path.dirname(scriptPath), { recursive: true });
fs.writeFileSync(migrationPath, sql);
fs.writeFileSync(scriptPath, sql);
console.log(`OK ${products.length} productos ->`);
console.log(scriptPath);
