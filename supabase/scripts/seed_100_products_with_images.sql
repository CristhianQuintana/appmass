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
  ('PRB-001', 'Agua de mesa 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 157, true, true, 'https://images.openfoodfacts.org/images/products/326/884/000/1008/front_fr.422.400.jpg'),
  ('PRB-002', 'Gaseosa cola', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 194, true, true, 'https://images.openfoodfacts.org/images/products/544/900/021/4911/front_fr.335.400.jpg'),
  ('PRB-003', 'Gaseosa lima 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 231, true, true, 'https://images.openfoodfacts.org/images/products/611/103/500/0430/front_en.104.400.jpg'),
  ('PRB-004', 'Jugo de naranja 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 268, true, true, 'https://images.openfoodfacts.org/images/products/611/103/500/0058/front_en.134.400.jpg'),
  ('PRB-005', 'Jugo de manzana', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 305, true, true, 'https://images.openfoodfacts.org/images/products/611/103/500/2175/front_ar.128.400.jpg'),
  ('PRB-006', 'Rehidratante 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 342, false, true, 'https://images.openfoodfacts.org/images/products/327/408/000/5003/front_en.797.400.jpg'),
  ('PRB-007', 'Té frío 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 379, true, true, 'https://images.openfoodfacts.org/images/products/611/112/800/0071/front_fr.62.400.jpg'),
  ('PRB-008', 'Café listo', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 416, true, true, 'https://images.openfoodfacts.org/images/products/303/371/007/3467/front_en.330.400.jpg'),
  ('PRB-009', 'Energizante 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 453, true, true, 'https://images.openfoodfacts.org/images/products/611/125/242/1568/front_en.72.400.jpg'),
  ('PRB-010', 'Agua con gas 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 490, true, true, 'https://images.openfoodfacts.org/images/products/611/103/500/0027/front_en.59.400.jpg'),
  ('PRB-011', 'Néctar de durazno', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 527, true, true, 'https://images.openfoodfacts.org/images/products/611/103/550/2828/front_fr.3.400.jpg'),
  ('PRB-012', 'Bebida de soya 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 564, true, true, 'https://images.openfoodfacts.org/images/products/544/900/005/4227/front_en.563.400.jpg'),
  ('PRB-013', 'Chicha morada 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 601, true, true, 'https://images.openfoodfacts.org/images/products/611/125/242/1582/front_ar.34.400.jpg'),
  ('PRB-014', 'Limonada', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 638, true, true, 'https://images.openfoodfacts.org/images/products/611/103/500/3035/front_en.61.400.jpg'),
  ('PRB-015', 'Malta 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Bebidas', 'botella', 675, true, true, 'https://images.openfoodfacts.org/images/products/544/900/014/7417/front_en.140.400.jpg'),
  ('PRB-016', 'Pan de molde 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 712, true, true, 'https://images.openfoodfacts.org/images/products/376/004/979/1006/front_fr.144.400.jpg'),
  ('PRB-017', 'Pan francés', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 749, true, true, 'https://images.openfoodfacts.org/images/products/376/004/979/0214/front_en.262.400.jpg'),
  ('PRB-018', 'Pan integral 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 786, true, true, 'https://images.openfoodfacts.org/images/products/376/004/979/8609/front_en.140.400.jpg'),
  ('PRB-019', 'Croissant 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 823, true, true, 'https://images.openfoodfacts.org/images/products/322/885/700/2344/front_fr.129.400.jpg'),
  ('PRB-020', 'Bizcocho', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 860, true, true, 'https://images.openfoodfacts.org/images/products/731/107/003/2611/front_en.91.400.jpg'),
  ('PRB-021', 'Galleta de soda 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 897, true, true, 'https://images.openfoodfacts.org/images/products/322/885/700/0852/front_en.160.400.jpg'),
  ('PRB-022', 'Galleta dulce 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 934, true, true, 'https://images.openfoodfacts.org/images/products/302/933/002/2428/front_fr.311.400.jpg'),
  ('PRB-023', 'Tostadas', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 971, true, true, 'https://images.openfoodfacts.org/images/products/376/004/979/4298/front_fr.212.400.jpg'),
  ('PRB-024', 'Queque 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 1008, true, true, 'https://images.openfoodfacts.org/images/products/730/040/048/1595/front_fr.271.400.jpg'),
  ('PRB-025', 'Empanada dulce 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 1045, true, true, 'https://images.openfoodfacts.org/images/products/730/040/048/1588/front_en.269.400.jpg'),
  ('PRB-026', 'Rosquitas', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 1082, true, true, 'https://images.openfoodfacts.org/images/products/322/885/700/0166/front_fr.1875.400.jpg'),
  ('PRB-027', 'Pan de hamburguesa 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 1119, true, true, 'https://images.openfoodfacts.org/images/products/302/933/000/4240/front_fr.54.400.jpg'),
  ('PRB-028', 'Pan pita 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 1156, true, true, 'https://images.openfoodfacts.org/images/products/328/423/001/1884/front_fr.161.400.jpg'),
  ('PRB-029', 'Brownies', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 1193, true, true, 'https://images.openfoodfacts.org/images/products/730/040/048/1571/front_fr.1746.400.jpg'),
  ('PRB-030', 'Alfajor 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Panadería', 'unidad', 1230, true, true, 'https://images.openfoodfacts.org/images/products/405/648/900/7180/front_en.115.400.jpg'),
  ('PRB-031', 'Leche evaporada 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1267, true, true, 'https://images.openfoodfacts.org/images/products/611/124/672/1261/front_fr.118.400.jpg'),
  ('PRB-032', 'Leche entera', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1304, true, true, 'https://images.openfoodfacts.org/images/products/611/124/210/0992/front_en.216.400.jpg'),
  ('PRB-033', 'Leche light 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1341, true, true, 'https://images.openfoodfacts.org/images/products/348/034/100/0674/front_en.133.400.jpg'),
  ('PRB-034', 'Yogurt natural 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1378, true, true, 'https://images.openfoodfacts.org/images/products/611/126/696/2187/front_fr.56.400.jpg'),
  ('PRB-035', 'Yogurt de fresa', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1415, true, true, 'https://images.openfoodfacts.org/images/products/611/124/210/6949/front_fr.77.400.jpg'),
  ('PRB-036', 'Queso fresco 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1452, true, true, 'https://images.openfoodfacts.org/images/products/611/124/210/1180/front_fr.89.400.jpg'),
  ('PRB-037', 'Queso edam 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1489, true, true, 'https://images.openfoodfacts.org/images/products/611/124/672/1278/front_en.4.400.jpg'),
  ('PRB-038', 'Mantequilla', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1526, true, true, 'https://images.openfoodfacts.org/images/products/611/109/900/5495/front_ar.7.400.jpg'),
  ('PRB-039', 'Margarina 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1563, true, true, 'https://images.openfoodfacts.org/images/products/332/977/007/7003/front_en.164.400.jpg'),
  ('PRB-040', 'Crema de leche 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1600, true, true, 'https://images.openfoodfacts.org/images/products/611/124/210/0206/front_en.38.400.jpg'),
  ('PRB-041', 'Leche condensada', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1637, true, true, 'https://images.openfoodfacts.org/images/products/611/120/300/6653/front_ar.14.400.jpg'),
  ('PRB-042', 'Queso mozarela 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1674, true, true, 'https://images.openfoodfacts.org/images/products/611/125/909/2495/front_fr.8.400.jpg'),
  ('PRB-043', 'Yogurt griego 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1711, true, true, 'https://images.openfoodfacts.org/images/products/611/124/210/0817/front_en.36.400.jpg'),
  ('PRB-044', 'Leche de almendras', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1748, true, true, 'https://images.openfoodfacts.org/images/products/611/124/672/2107/front_fr.3.400.jpg'),
  ('PRB-045', 'Kéfir 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Lácteos', 'unidad', 1785, true, true, 'https://images.openfoodfacts.org/images/products/842/075/601/0320/front_fr.27.400.jpg'),
  ('PRB-046', 'Arroz extra 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 1822, true, true, 'https://images.openfoodfacts.org/images/products/611/118/400/0619/front_fr.19.400.jpg'),
  ('PRB-047', 'Azúcar rubia', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 1859, true, true, 'https://images.openfoodfacts.org/images/products/807/680/954/5396/front_de.353.400.jpg'),
  ('PRB-048', 'Azúcar blanca 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 1896, true, true, 'https://images.openfoodfacts.org/images/products/871/210/073/1822/front_fr.184.400.jpg'),
  ('PRB-049', 'Fideos spaguetti 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 133, true, true, 'https://images.openfoodfacts.org/images/products/000/008/715/7635/front_fr.37.400.jpg'),
  ('PRB-050', 'Fideos cabello', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 170, true, true, 'https://images.openfoodfacts.org/images/products/325/054/192/0139/front_fr.432.400.jpg'),
  ('PRB-051', 'Avena 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 207, true, true, 'https://images.openfoodfacts.org/images/products/871/210/044/1639/front_fr.141.400.jpg'),
  ('PRB-052', 'Lentejas 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 244, true, true, 'https://images.openfoodfacts.org/images/products/871/052/292/0725/front_fr.147.400.jpg'),
  ('PRB-053', 'Frejoles', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 281, true, true, 'https://images.openfoodfacts.org/images/products/871/120/054/8033/front_fr.163.400.jpg'),
  ('PRB-054', 'Garbanzos 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 318, true, true, 'https://images.openfoodfacts.org/images/products/761/303/368/7884/front_fr.301.400.jpg'),
  ('PRB-055', 'Maíz morado 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 355, true, true, 'https://images.openfoodfacts.org/images/products/871/256/624/6496/front_fr.151.400.jpg'),
  ('PRB-056', 'Harina de trigo', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 392, true, true, 'https://images.openfoodfacts.org/images/products/327/019/012/1909/front_fr.79.400.jpg'),
  ('PRB-057', 'Sal de mesa 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 429, true, true, 'https://images.openfoodfacts.org/images/products/318/328/000/0544/front_fr.89.400.jpg'),
  ('PRB-058', 'Ají panca 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 466, true, true, 'https://images.openfoodfacts.org/images/products/761/303/675/0011/front_en.88.400.jpg'),
  ('PRB-059', 'Vinagre', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 503, true, true, 'https://images.openfoodfacts.org/images/products/871/570/042/1957/front_en.56.400.jpg'),
  ('PRB-060', 'Salsa de soya 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 540, true, true, 'https://images.openfoodfacts.org/images/products/356/470/708/2549/front_fr.68.400.jpg'),
  ('PRB-061', 'Atún en lata 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 577, true, true, 'https://images.openfoodfacts.org/images/products/858/500/248/4079/front_fr.346.400.jpg'),
  ('PRB-062', 'Sardinas', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 614, true, true, 'https://images.openfoodfacts.org/images/products/316/544/000/7808/front_fr.113.400.jpg'),
  ('PRB-063', 'Mayonesa 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 651, true, true, 'https://images.openfoodfacts.org/images/products/611/125/047/4641/front_fr.11.400.jpg'),
  ('PRB-064', 'Kétchup 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 688, true, true, 'https://images.openfoodfacts.org/images/products/325/237/800/1319/front_fr.119.400.jpg'),
  ('PRB-065', 'Mostaza', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Abarrotes', 'bolsa', 725, true, true, 'https://images.openfoodfacts.org/images/products/347/882/002/3641/front_fr.48.400.jpg'),
  ('PRB-066', 'Detergente 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 762, true, true, 'https://images.openproductsfacts.org/images/products/345/060/104/6995/front_fr.8.400.jpg'),
  ('PRB-067', 'Jabón líquido 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 799, true, true, 'https://images.openproductsfacts.org/images/products/345/060/104/6339/front_fr.6.400.jpg'),
  ('PRB-068', 'Lavavajillas', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 836, true, true, 'https://images.openproductsfacts.org/images/products/800/109/039/3074/front_fr.13.400.jpg'),
  ('PRB-069', 'Lejía 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 873, true, true, 'https://images.openproductsfacts.org/images/products/317/804/136/3853/front_en.6.400.jpg'),
  ('PRB-070', 'Suavizante 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 910, true, true, 'https://images.openproductsfacts.org/images/products/356/007/119/7292/front_fr.11.400.jpg'),
  ('PRB-071', 'Esponja', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 947, true, true, 'https://images.openproductsfacts.org/images/products/871/895/147/8848/front_fr.4.400.jpg'),
  ('PRB-072', 'Bolsas de basura 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 984, true, true, 'https://images.openproductsfacts.org/images/products/000/002/075/3603/front_fr.16.400.jpg'),
  ('PRB-073', 'Papel higiénico 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 1021, true, true, 'https://images.openproductsfacts.org/images/products/405/648/973/8435/front_fr.3.400.jpg'),
  ('PRB-074', 'Servilletas', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 1058, true, true, 'https://images.openproductsfacts.org/images/products/842/142/706/5021/front_es.4.400.jpg'),
  ('PRB-075', 'Limpiavidrios 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 1095, true, true, 'https://images.openproductsfacts.org/images/products/931/724/130/0181/front_en.3.400.jpg'),
  ('PRB-076', 'Desinfectante 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 1132, true, true, 'https://images.openproductsfacts.org/images/products/062/623/283/1290/front_en.3.400.jpg'),
  ('PRB-077', 'Cera para piso', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 1169, true, true, 'https://images.openproductsfacts.org/images/products/006/382/704/8037/front_en.3.400.jpg'),
  ('PRB-078', 'Jabón de tocador 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 1206, true, true, 'https://images.openproductsfacts.org/images/products/885/000/694/4363/front_en.3.400.jpg'),
  ('PRB-079', 'Shampoo 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 1243, true, true, 'https://images.openproductsfacts.org/images/products/408/870/011/1000/front_en.3.400.jpg'),
  ('PRB-080', 'Pasta dental', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Limpieza', 'unidad', 1280, true, true, 'https://images.openproductsfacts.org/images/products/005/908/011/0024/front_en.3.400.jpg'),
  ('PRB-081', 'Papas fritas 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1317, true, true, 'https://images.openfoodfacts.org/images/products/762/221/044/9283/front_en.605.400.jpg'),
  ('PRB-082', 'Chifles 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1354, true, true, 'https://images.openfoodfacts.org/images/products/304/692/002/9759/front_en.544.400.jpg'),
  ('PRB-083', 'Maní salado', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1391, true, true, 'https://images.openfoodfacts.org/images/products/000/000/617/5700/front_fr.90.400.jpg'),
  ('PRB-084', 'Galletas rellenas 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1428, true, true, 'https://images.openfoodfacts.org/images/products/317/568/001/1480/front_fr.325.400.jpg'),
  ('PRB-085', 'Chocolate de leche 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1465, true, true, 'https://images.openfoodfacts.org/images/products/842/519/771/2024/front_en.60.400.jpg'),
  ('PRB-086', 'Caramelos', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1502, true, true, 'https://images.openfoodfacts.org/images/products/304/692/002/2651/front_en.159.400.jpg'),
  ('PRB-087', 'Chicles 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1539, true, true, 'https://images.openfoodfacts.org/images/products/304/692/002/2606/front_en.102.400.jpg'),
  ('PRB-088', 'Barra de cereal 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1576, true, true, 'https://images.openfoodfacts.org/images/products/322/885/700/1378/front_fr.130.400.jpg'),
  ('PRB-089', 'Tortillas de maíz', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1613, true, true, 'https://images.openfoodfacts.org/images/products/325/149/030/7002/front_fr.130.400.jpg'),
  ('PRB-090', 'Mix de frutos secos 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Snacks', 'paquete', 1650, true, true, 'https://images.openfoodfacts.org/images/products/333/697/180/5021/front_en.203.400.jpg'),
  ('PRB-091', 'Cepillo dental 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 1687, true, true, 'https://images.openbeautyfacts.org/images/products/735/007/569/0105/front_es.7.400.jpg'),
  ('PRB-092', 'Hilo dental', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 1724, true, true, 'https://images.openbeautyfacts.org/images/products/885/193/235/1881/front_en.5.400.jpg'),
  ('PRB-093', 'Desodorante 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 1761, true, true, 'https://images.openbeautyfacts.org/images/products/871/478/973/2244/front_en.3.400.jpg'),
  ('PRB-094', 'Crema corporal 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 1798, true, true, 'https://images.openbeautyfacts.org/images/products/890/131/430/5527/front_en.3.400.jpg'),
  ('PRB-095', 'Protector solar', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 1835, true, true, 'https://images.openbeautyfacts.org/images/products/498/717/613/0051/front_en.3.400.jpg'),
  ('PRB-096', 'Toallitas húmedas 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 1872, true, true, 'https://images.openbeautyfacts.org/images/products/498/717/623/9952/front_en.3.400.jpg'),
  ('PRB-097', 'Algodón 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 1909, true, true, 'https://images.openbeautyfacts.org/images/products/000/008/046/6468/front_fr.29.400.jpg'),
  ('PRB-098', 'Hisopos', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 146, true, true, 'https://images.openbeautyfacts.org/images/products/848/000/046/7942/front_es.15.400.jpg'),
  ('PRB-099', 'Jabón íntimo 1 kg', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 183, true, true, 'https://images.openbeautyfacts.org/images/products/360/055/114/6065/front_fr.20.400.jpg'),
  ('PRB-100', 'Crema de afeitar 500 ml', 'Producto de prueba. No es un artículo oficial de Tiendas MASS.', 'Cuidado personal', 'unidad', 220, true, true, 'https://images.openbeautyfacts.org/images/products/871/895/125/4183/front_en.22.400.jpg')
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
