-- 100 productos de prueba con image_url (HTTPS).
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
  ('PRB-001', 'Agua de mesa 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 157, true, true, 'https://picsum.photos/seed/mass-prb-001/400/400'),
  ('PRB-002', 'Gaseosa cola', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 194, true, true, 'https://picsum.photos/seed/mass-prb-002/400/400'),
  ('PRB-003', 'Gaseosa lima 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 231, true, true, 'https://picsum.photos/seed/mass-prb-003/400/400'),
  ('PRB-004', 'Jugo de naranja 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 268, true, true, 'https://picsum.photos/seed/mass-prb-004/400/400'),
  ('PRB-005', 'Jugo de manzana', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 305, true, true, 'https://picsum.photos/seed/mass-prb-005/400/400'),
  ('PRB-006', 'Rehidratante 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 342, false, true, 'https://picsum.photos/seed/mass-prb-006/400/400'),
  ('PRB-007', 'Té frío 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 379, true, true, 'https://picsum.photos/seed/mass-prb-007/400/400'),
  ('PRB-008', 'Café listo', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 416, true, true, 'https://picsum.photos/seed/mass-prb-008/400/400'),
  ('PRB-009', 'Energizante 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 453, true, true, 'https://picsum.photos/seed/mass-prb-009/400/400'),
  ('PRB-010', 'Agua con gas 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 490, true, true, 'https://picsum.photos/seed/mass-prb-010/400/400'),
  ('PRB-011', 'Néctar de durazno', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 527, true, true, 'https://picsum.photos/seed/mass-prb-011/400/400'),
  ('PRB-012', 'Bebida de soya 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 564, true, true, 'https://picsum.photos/seed/mass-prb-012/400/400'),
  ('PRB-013', 'Chicha morada 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 601, true, true, 'https://picsum.photos/seed/mass-prb-013/400/400'),
  ('PRB-014', 'Limonada', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 638, true, true, 'https://picsum.photos/seed/mass-prb-014/400/400'),
  ('PRB-015', 'Malta 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 675, true, true, 'https://picsum.photos/seed/mass-prb-015/400/400'),
  ('PRB-016', 'Pan de molde 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 712, true, true, 'https://picsum.photos/seed/mass-prb-016/400/400'),
  ('PRB-017', 'Pan francés', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 749, true, true, 'https://picsum.photos/seed/mass-prb-017/400/400'),
  ('PRB-018', 'Pan integral 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 786, true, true, 'https://picsum.photos/seed/mass-prb-018/400/400'),
  ('PRB-019', 'Croissant 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 823, true, true, 'https://picsum.photos/seed/mass-prb-019/400/400'),
  ('PRB-020', 'Bizcocho', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 860, true, true, 'https://picsum.photos/seed/mass-prb-020/400/400'),
  ('PRB-021', 'Galleta de soda 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 897, true, true, 'https://picsum.photos/seed/mass-prb-021/400/400'),
  ('PRB-022', 'Galleta dulce 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 934, true, true, 'https://picsum.photos/seed/mass-prb-022/400/400'),
  ('PRB-023', 'Tostadas', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 971, true, true, 'https://picsum.photos/seed/mass-prb-023/400/400'),
  ('PRB-024', 'Queque 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 1008, true, true, 'https://picsum.photos/seed/mass-prb-024/400/400'),
  ('PRB-025', 'Empanada dulce 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 1045, true, true, 'https://picsum.photos/seed/mass-prb-025/400/400'),
  ('PRB-026', 'Rosquitas', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 1082, true, true, 'https://picsum.photos/seed/mass-prb-026/400/400'),
  ('PRB-027', 'Pan de hamburguesa 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 1119, true, true, 'https://picsum.photos/seed/mass-prb-027/400/400'),
  ('PRB-028', 'Pan pita 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 1156, true, true, 'https://picsum.photos/seed/mass-prb-028/400/400'),
  ('PRB-029', 'Brownies', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 1193, true, true, 'https://picsum.photos/seed/mass-prb-029/400/400'),
  ('PRB-030', 'Alfajor 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 1230, true, true, 'https://picsum.photos/seed/mass-prb-030/400/400'),
  ('PRB-031', 'Leche evaporada 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1267, true, true, 'https://picsum.photos/seed/mass-prb-031/400/400'),
  ('PRB-032', 'Leche entera', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1304, true, true, 'https://picsum.photos/seed/mass-prb-032/400/400'),
  ('PRB-033', 'Leche light 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1341, true, true, 'https://picsum.photos/seed/mass-prb-033/400/400'),
  ('PRB-034', 'Yogurt natural 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1378, true, true, 'https://picsum.photos/seed/mass-prb-034/400/400'),
  ('PRB-035', 'Yogurt de fresa', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1415, true, true, 'https://picsum.photos/seed/mass-prb-035/400/400'),
  ('PRB-036', 'Queso fresco 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1452, true, true, 'https://picsum.photos/seed/mass-prb-036/400/400'),
  ('PRB-037', 'Queso edam 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1489, true, true, 'https://picsum.photos/seed/mass-prb-037/400/400'),
  ('PRB-038', 'Mantequilla', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1526, true, true, 'https://picsum.photos/seed/mass-prb-038/400/400'),
  ('PRB-039', 'Margarina 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1563, true, true, 'https://picsum.photos/seed/mass-prb-039/400/400'),
  ('PRB-040', 'Crema de leche 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1600, true, true, 'https://picsum.photos/seed/mass-prb-040/400/400'),
  ('PRB-041', 'Leche condensada', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1637, true, true, 'https://picsum.photos/seed/mass-prb-041/400/400'),
  ('PRB-042', 'Queso mozarela 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1674, true, true, 'https://picsum.photos/seed/mass-prb-042/400/400'),
  ('PRB-043', 'Yogurt griego 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1711, true, true, 'https://picsum.photos/seed/mass-prb-043/400/400'),
  ('PRB-044', 'Leche de almendras', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1748, true, true, 'https://picsum.photos/seed/mass-prb-044/400/400'),
  ('PRB-045', 'Kéfir 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1785, true, true, 'https://picsum.photos/seed/mass-prb-045/400/400'),
  ('PRB-046', 'Arroz extra 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 1822, true, true, 'https://picsum.photos/seed/mass-prb-046/400/400'),
  ('PRB-047', 'Azúcar rubia', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 1859, true, true, 'https://picsum.photos/seed/mass-prb-047/400/400'),
  ('PRB-048', 'Azúcar blanca 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 1896, true, true, 'https://picsum.photos/seed/mass-prb-048/400/400'),
  ('PRB-049', 'Fideos spaguetti 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 133, true, true, 'https://picsum.photos/seed/mass-prb-049/400/400'),
  ('PRB-050', 'Fideos cabello', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 170, true, true, 'https://picsum.photos/seed/mass-prb-050/400/400'),
  ('PRB-051', 'Avena 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 207, true, true, 'https://picsum.photos/seed/mass-prb-051/400/400'),
  ('PRB-052', 'Lentejas 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 244, true, true, 'https://picsum.photos/seed/mass-prb-052/400/400'),
  ('PRB-053', 'Frejoles', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 281, true, true, 'https://picsum.photos/seed/mass-prb-053/400/400'),
  ('PRB-054', 'Garbanzos 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 318, true, true, 'https://picsum.photos/seed/mass-prb-054/400/400'),
  ('PRB-055', 'Maíz morado 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 355, true, true, 'https://picsum.photos/seed/mass-prb-055/400/400'),
  ('PRB-056', 'Harina de trigo', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 392, true, true, 'https://picsum.photos/seed/mass-prb-056/400/400'),
  ('PRB-057', 'Sal de mesa 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 429, true, true, 'https://picsum.photos/seed/mass-prb-057/400/400'),
  ('PRB-058', 'Ají panca 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 466, true, true, 'https://picsum.photos/seed/mass-prb-058/400/400'),
  ('PRB-059', 'Vinagre', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 503, true, true, 'https://picsum.photos/seed/mass-prb-059/400/400'),
  ('PRB-060', 'Salsa de soya 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 540, true, true, 'https://picsum.photos/seed/mass-prb-060/400/400'),
  ('PRB-061', 'Atún en lata 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 577, true, true, 'https://picsum.photos/seed/mass-prb-061/400/400'),
  ('PRB-062', 'Sardinas', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 614, true, true, 'https://picsum.photos/seed/mass-prb-062/400/400'),
  ('PRB-063', 'Mayonesa 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 651, true, true, 'https://picsum.photos/seed/mass-prb-063/400/400'),
  ('PRB-064', 'Kétchup 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 688, true, true, 'https://picsum.photos/seed/mass-prb-064/400/400'),
  ('PRB-065', 'Mostaza', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 725, true, true, 'https://picsum.photos/seed/mass-prb-065/400/400'),
  ('PRB-066', 'Detergente 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 762, true, true, 'https://picsum.photos/seed/mass-prb-066/400/400'),
  ('PRB-067', 'Jabón líquido 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 799, true, true, 'https://picsum.photos/seed/mass-prb-067/400/400'),
  ('PRB-068', 'Lavavajillas', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 836, true, true, 'https://picsum.photos/seed/mass-prb-068/400/400'),
  ('PRB-069', 'Lejía 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 873, true, true, 'https://picsum.photos/seed/mass-prb-069/400/400'),
  ('PRB-070', 'Suavizante 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 910, true, true, 'https://picsum.photos/seed/mass-prb-070/400/400'),
  ('PRB-071', 'Esponja', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 947, true, true, 'https://picsum.photos/seed/mass-prb-071/400/400'),
  ('PRB-072', 'Bolsas de basura 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 984, true, true, 'https://picsum.photos/seed/mass-prb-072/400/400'),
  ('PRB-073', 'Papel higiénico 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 1021, true, true, 'https://picsum.photos/seed/mass-prb-073/400/400'),
  ('PRB-074', 'Servilletas', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 1058, true, true, 'https://picsum.photos/seed/mass-prb-074/400/400'),
  ('PRB-075', 'Limpiavidrios 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 1095, true, true, 'https://picsum.photos/seed/mass-prb-075/400/400'),
  ('PRB-076', 'Desinfectante 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 1132, true, true, 'https://picsum.photos/seed/mass-prb-076/400/400'),
  ('PRB-077', 'Cera para piso', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 1169, true, true, 'https://picsum.photos/seed/mass-prb-077/400/400'),
  ('PRB-078', 'Jabón de tocador 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 1206, true, true, 'https://picsum.photos/seed/mass-prb-078/400/400'),
  ('PRB-079', 'Shampoo 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 1243, true, true, 'https://picsum.photos/seed/mass-prb-079/400/400'),
  ('PRB-080', 'Pasta dental', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 1280, true, true, 'https://picsum.photos/seed/mass-prb-080/400/400'),
  ('PRB-081', 'Papas fritas 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1317, true, true, 'https://picsum.photos/seed/mass-prb-081/400/400'),
  ('PRB-082', 'Chifles 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1354, true, true, 'https://picsum.photos/seed/mass-prb-082/400/400'),
  ('PRB-083', 'Maní salado', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1391, true, true, 'https://picsum.photos/seed/mass-prb-083/400/400'),
  ('PRB-084', 'Galletas rellenas 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1428, true, true, 'https://picsum.photos/seed/mass-prb-084/400/400'),
  ('PRB-085', 'Chocolate de leche 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1465, true, true, 'https://picsum.photos/seed/mass-prb-085/400/400'),
  ('PRB-086', 'Caramelos', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1502, true, true, 'https://picsum.photos/seed/mass-prb-086/400/400'),
  ('PRB-087', 'Chicles 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1539, true, true, 'https://picsum.photos/seed/mass-prb-087/400/400'),
  ('PRB-088', 'Barra de cereal 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1576, true, true, 'https://picsum.photos/seed/mass-prb-088/400/400'),
  ('PRB-089', 'Tortillas de maíz', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1613, true, true, 'https://picsum.photos/seed/mass-prb-089/400/400'),
  ('PRB-090', 'Mix de frutos secos 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1650, true, true, 'https://picsum.photos/seed/mass-prb-090/400/400'),
  ('PRB-091', 'Cepillo dental 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 1687, true, true, 'https://picsum.photos/seed/mass-prb-091/400/400'),
  ('PRB-092', 'Hilo dental', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 1724, true, true, 'https://picsum.photos/seed/mass-prb-092/400/400'),
  ('PRB-093', 'Desodorante 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 1761, true, true, 'https://picsum.photos/seed/mass-prb-093/400/400'),
  ('PRB-094', 'Crema corporal 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 1798, true, true, 'https://picsum.photos/seed/mass-prb-094/400/400'),
  ('PRB-095', 'Protector solar', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 1835, true, true, 'https://picsum.photos/seed/mass-prb-095/400/400'),
  ('PRB-096', 'Toallitas húmedas 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 1872, true, true, 'https://picsum.photos/seed/mass-prb-096/400/400'),
  ('PRB-097', 'Algodón 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 1909, true, true, 'https://picsum.photos/seed/mass-prb-097/400/400'),
  ('PRB-098', 'Hisopos', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 146, true, true, 'https://picsum.photos/seed/mass-prb-098/400/400'),
  ('PRB-099', 'Jabón íntimo 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 183, true, true, 'https://picsum.photos/seed/mass-prb-099/400/400'),
  ('PRB-100', 'Crema de afeitar 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 220, true, true, 'https://picsum.photos/seed/mass-prb-100/400/400')
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
