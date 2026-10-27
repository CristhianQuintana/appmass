-- Extiende el esquema operativo para el comprador autenticado y el carrito.
-- No inventa tarifa de envío ni pago. El total sigue siendo la suma de líneas.

alter table public.profiles
  drop constraint if exists profiles_role_check;

alter table public.profiles
  add constraint profiles_role_check check (
    role in ('administrator', 'operator', 'courier', 'customer', 'unassigned')
  );

alter table public.profile_role_events
  drop constraint if exists profile_role_events_role_check;

alter table public.profile_role_events
  add constraint profile_role_events_role_check check (
    new_role in ('administrator', 'operator', 'courier', 'customer', 'unassigned')
  );

create or replace function public.provision_staff_profile(
  target_user_id uuid,
  target_full_name text,
  target_role text,
  target_active boolean
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  previous public.profiles%rowtype;
begin
  if target_role not in (
    'administrator', 'operator', 'courier', 'customer', 'unassigned'
  ) then
    raise exception 'invalid role' using errcode = '22023';
  end if;

  if target_full_name is null
    or char_length(btrim(target_full_name)) = 0
    or char_length(target_full_name) > 120
  then
    raise exception 'invalid name' using errcode = '22023';
  end if;

  select *
  into previous
  from public.profiles
  where id = target_user_id
  for update;

  if not found then
    raise exception 'profile not found' using errcode = 'P0002';
  end if;

  update public.profiles
  set
    full_name = btrim(target_full_name),
    role = target_role,
    is_active = target_active
  where id = target_user_id;

  insert into public.profile_role_events (
    target_user_id,
    actor_role,
    previous_role,
    new_role,
    previous_active,
    new_active
  )
  values (
    target_user_id,
    coalesce(auth.role(), current_user),
    previous.role,
    target_role,
    previous.is_active,
    target_active
  );
end;
$$;

revoke all on function public.provision_staff_profile(uuid, text, text, boolean)
  from public, anon, authenticated;
grant execute on function public.provision_staff_profile(uuid, text, text, boolean)
  to service_role;

create policy products_select_customer
  on public.products
  for select
  to authenticated
  using (
    is_active
    and public.is_active_role(array['customer'])
  );

drop policy if exists orders_select_scoped on public.orders;
create policy orders_select_scoped
  on public.orders
  for select
  to authenticated
  using (
    public.is_active_role(array['administrator', 'operator'])
    or (
      public.is_active_role(array['courier'])
      and exists (
        select 1
        from public.delivery_assignments assignment
        where assignment.order_id = orders.id
          and assignment.courier_id = auth.uid()
          and assignment.is_current
      )
    )
    or (
      public.is_active_role(array['customer'])
      and created_by = auth.uid()
    )
  );

create or replace function public.create_order(
  p_idempotency_key uuid,
  p_modality text,
  p_customer_name text,
  p_customer_phone text,
  p_address text,
  p_reference text,
  p_notes text,
  p_items jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor uuid := auth.uid();
  v_existing uuid;
  v_order uuid;
  v_item jsonb;
  v_product_id uuid;
  v_quantity integer;
  v_name text;
  v_price integer;
  v_active boolean;
  v_lines jsonb := '{}'::jsonb;
  v_previous integer;
  v_total integer := 0;
  v_code text;
begin
  if v_actor is null
    or not public.is_active_role(array['administrator', 'operator', 'customer'])
  then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  select id into v_existing
  from public.orders
  where created_by = v_actor and idempotency_key = p_idempotency_key;
  if v_existing is not null then
    return v_existing;
  end if;

  if p_modality not in ('in_store', 'delivery') then
    raise exception 'invalid modality' using errcode = '22023';
  end if;
  if p_customer_name is null or char_length(btrim(p_customer_name)) not between 1 and 120 then
    raise exception 'invalid customer' using errcode = '22023';
  end if;
  if coalesce(char_length(p_notes), 0) > 400 then
    raise exception 'invalid notes' using errcode = '22023';
  end if;
  if p_modality = 'delivery' then
    if p_customer_phone is null or char_length(btrim(p_customer_phone)) not between 6 and 20 then
      raise exception 'invalid phone' using errcode = '22023';
    end if;
    if p_address is null or char_length(btrim(p_address)) not between 8 and 200 then
      raise exception 'invalid address' using errcode = '22023';
    end if;
  end if;
  if p_items is null or jsonb_typeof(p_items) <> 'array'
     or jsonb_array_length(p_items) not between 1 and 30 then
    raise exception 'invalid items' using errcode = '22023';
  end if;

  for v_item in select value from jsonb_array_elements(p_items)
  loop
    if jsonb_typeof(v_item) <> 'object'
       or coalesce(v_item->>'product_id', '') !~* '^[0-9a-f-]{36}$'
       or coalesce(v_item->>'quantity', '') !~ '^[0-9]+$' then
      raise exception 'invalid item' using errcode = '22023';
    end if;
    v_product_id := (v_item->>'product_id')::uuid;
    v_quantity := (v_item->>'quantity')::integer;
    if v_quantity < 1 or v_quantity > 99 then
      raise exception 'invalid quantity' using errcode = '22023';
    end if;

    select name, price_cents, is_active
      into v_name, v_price, v_active
    from public.products
    where id = v_product_id;
    if not found or v_active is not true then
      raise exception 'product unavailable' using errcode = '22023';
    end if;

    if v_lines ? v_product_id::text then
      v_previous := (v_lines -> v_product_id::text ->> 'quantity')::integer;
      if v_previous + v_quantity > 99 then
        raise exception 'invalid quantity' using errcode = '22023';
      end if;
      v_lines := jsonb_set(
        v_lines,
        array[v_product_id::text, 'quantity'],
        to_jsonb(v_previous + v_quantity)
      );
    else
      v_lines := v_lines || jsonb_build_object(
        v_product_id::text,
        jsonb_build_object('quantity', v_quantity, 'name', v_name, 'price', v_price)
      );
    end if;
  end loop;

  select coalesce(sum((value ->> 'quantity')::integer * (value ->> 'price')::integer), 0)
    into v_total
  from jsonb_each(v_lines);
  if v_total < 0 then
    raise exception 'invalid total' using errcode = '22023';
  end if;

  v_code := 'PED-' || to_char(timezone('America/Lima', now()), 'YYMMDD')
    || '-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 6));

  insert into public.orders (
    public_code, idempotency_key, modality, status, customer_name,
    customer_phone, address_line, address_reference, notes, created_by, total_cents
  ) values (
    v_code, p_idempotency_key, p_modality, 'submitted', btrim(p_customer_name),
    coalesce(btrim(p_customer_phone), ''), coalesce(btrim(p_address), ''),
    coalesce(btrim(p_reference), ''), coalesce(btrim(p_notes), ''), v_actor, v_total
  )
  returning id into v_order;

  insert into public.order_items (
    order_id, product_id, product_name, quantity, unit_price_cents, line_total_cents
  )
  select
    v_order,
    key::uuid,
    value ->> 'name',
    (value ->> 'quantity')::integer,
    (value ->> 'price')::integer,
    (value ->> 'quantity')::integer * (value ->> 'price')::integer
  from jsonb_each(v_lines);

  insert into public.order_events (order_id, actor_id, from_status, to_status, action)
  values (v_order, v_actor, null, 'submitted', 'create');

  return v_order;
exception
  when unique_violation then
    select id into v_existing
    from public.orders
    where created_by = v_actor and idempotency_key = p_idempotency_key;
    if v_existing is not null then
      return v_existing;
    end if;
    raise;
end;
$$;

create table if not exists public.carts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles (id) on delete cascade,
  updated_at timestamptz not null default timezone('utc', now())
);

comment on table public.carts is
  'Carrito del comprador autenticado. Una fila por usuario.';

create table if not exists public.cart_items (
  id bigint generated always as identity primary key,
  cart_id uuid not null references public.carts (id) on delete cascade,
  product_id uuid not null references public.products (id),
  quantity integer not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint cart_items_quantity_check check (quantity between 1 and 99),
  constraint cart_items_unique_product unique (cart_id, product_id)
);

create index if not exists cart_items_cart_id_idx on public.cart_items (cart_id);

alter table public.carts enable row level security;
alter table public.carts force row level security;
alter table public.cart_items enable row level security;
alter table public.cart_items force row level security;

revoke all on table public.carts from public, anon;
revoke all on table public.cart_items from public, anon;
grant select, insert, update, delete on table public.carts to authenticated;
grant select, insert, update, delete on table public.cart_items to authenticated;
grant usage, select on sequence public.cart_items_id_seq to authenticated;

create policy carts_owner_all
  on public.carts
  for all
  to authenticated
  using (
    user_id = auth.uid()
    and public.is_active_role(array['customer'])
  )
  with check (
    user_id = auth.uid()
    and public.is_active_role(array['customer'])
  );

create policy cart_items_owner_all
  on public.cart_items
  for all
  to authenticated
  using (
    exists (
      select 1
      from public.carts
      where carts.id = cart_items.cart_id
        and carts.user_id = auth.uid()
        and public.is_active_role(array['customer'])
    )
  )
  with check (
    exists (
      select 1
      from public.carts
      where carts.id = cart_items.cart_id
        and carts.user_id = auth.uid()
        and public.is_active_role(array['customer'])
    )
  );

create or replace function public.get_or_create_cart()
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cart uuid;
begin
  if auth.uid() is null or not public.is_active_role(array['customer']) then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  select id into v_cart from public.carts where user_id = auth.uid();
  if v_cart is not null then
    return v_cart;
  end if;

  insert into public.carts (user_id) values (auth.uid())
  returning id into v_cart;
  return v_cart;
end;
$$;

create or replace function public.upsert_cart_item(
  p_product_id uuid,
  p_quantity integer
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cart uuid;
  v_active boolean;
begin
  if auth.uid() is null or not public.is_active_role(array['customer']) then
    raise exception 'not authorized' using errcode = '42501';
  end if;
  if p_quantity is null or p_quantity < 0 or p_quantity > 99 then
    raise exception 'invalid quantity' using errcode = '22023';
  end if;

  select is_active into v_active from public.products where id = p_product_id;
  if not found or not v_active then
    raise exception 'product unavailable' using errcode = '22023';
  end if;

  v_cart := public.get_or_create_cart();

  if p_quantity = 0 then
    delete from public.cart_items
    where cart_id = v_cart and product_id = p_product_id;
  else
    insert into public.cart_items (cart_id, product_id, quantity)
    values (v_cart, p_product_id, p_quantity)
    on conflict (cart_id, product_id)
    do update set
      quantity = excluded.quantity,
      updated_at = timezone('utc', now());
  end if;

  update public.carts
  set updated_at = timezone('utc', now())
  where id = v_cart;
end;
$$;

create or replace function public.clear_cart()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cart uuid;
begin
  if auth.uid() is null or not public.is_active_role(array['customer']) then
    raise exception 'not authorized' using errcode = '42501';
  end if;
  select id into v_cart from public.carts where user_id = auth.uid();
  if v_cart is null then
    return;
  end if;
  delete from public.cart_items where cart_id = v_cart;
  update public.carts set updated_at = timezone('utc', now()) where id = v_cart;
end;
$$;

create or replace function public.list_cart_items()
returns table (
  product_id uuid,
  sku text,
  name text,
  category text,
  unit_label text,
  price_cents integer,
  quantity integer
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
    cart_items.quantity
  from public.carts
  join public.cart_items on cart_items.cart_id = carts.id
  join public.products on products.id = cart_items.product_id
  where carts.user_id = auth.uid()
    and public.is_active_role(array['customer'])
    and products.is_active
  order by products.name;
$$;

revoke all on function public.get_or_create_cart() from public, anon;
revoke all on function public.upsert_cart_item(uuid, integer) from public, anon;
revoke all on function public.clear_cart() from public, anon;
revoke all on function public.list_cart_items() from public, anon;
grant execute on function public.get_or_create_cart() to authenticated;
grant execute on function public.upsert_cart_item(uuid, integer) to authenticated;
grant execute on function public.clear_cart() to authenticated;
grant execute on function public.list_cart_items() to authenticated;
