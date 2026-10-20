create extension if not exists pgcrypto;

-- Operación de pedidos. Los importes viven en céntimos de sol.
-- El cliente no envía precios, totales, autor ni estado.
-- Los datos de productos de ejemplo se cargan en la migración siguiente.

create table public.products (
  id uuid primary key default gen_random_uuid(),
  sku text not null,
  name text not null,
  description text not null default '',
  category text not null default 'General',
  unit_label text not null default 'unidad',
  price_cents integer not null,
  is_active boolean not null default true,
  is_sample boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint products_sku_unique unique (sku),
  constraint products_sku_len check (char_length(btrim(sku)) between 1 and 40),
  constraint products_name_len check (char_length(btrim(name)) between 1 and 120),
  constraint products_description_len check (char_length(description) <= 400),
  constraint products_category_len check (char_length(category) between 1 and 40),
  constraint products_price_range check (price_cents between 0 and 100000000)
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  public_code text not null unique,
  idempotency_key uuid not null,
  modality text not null,
  status text not null,
  customer_name text not null,
  customer_phone text not null default '',
  address_line text not null default '',
  address_reference text not null default '',
  notes text not null default '',
  created_by uuid not null references public.profiles (id),
  total_cents integer not null,
  version integer not null default 1,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint orders_modality_check check (modality in ('in_store', 'delivery')),
  constraint orders_status_check check (
    status in (
      'submitted', 'preparing', 'ready_for_pickup', 'ready_for_dispatch',
      'assigned', 'in_delivery', 'delivered', 'completed', 'cancelled',
      'delivery_failed'
    )
  ),
  constraint orders_customer_name_len check (char_length(btrim(customer_name)) between 1 and 120),
  constraint orders_phone_len check (char_length(customer_phone) <= 20),
  constraint orders_address_len check (char_length(address_line) <= 200),
  constraint orders_reference_len check (char_length(address_reference) <= 200),
  constraint orders_notes_len check (char_length(notes) <= 400),
  constraint orders_total_nonnegative check (total_cents >= 0),
  constraint orders_version_positive check (version > 0),
  constraint orders_delivery_requirements check (
    modality <> 'delivery'
    or (
      char_length(btrim(address_line)) >= 8
      and char_length(btrim(customer_phone)) >= 6
    )
  ),
  constraint orders_idempotency_unique unique (created_by, idempotency_key)
);

create index orders_status_created_idx on public.orders (status, created_at desc);

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_id uuid not null references public.products (id),
  product_name text not null,
  quantity integer not null,
  unit_price_cents integer not null,
  line_total_cents integer not null,
  constraint order_items_quantity_range check (quantity between 1 and 99),
  constraint order_items_price_nonnegative check (unit_price_cents >= 0),
  constraint order_items_line_total check (line_total_cents = quantity * unit_price_cents),
  constraint order_items_product_once unique (order_id, product_id)
);

create table public.order_events (
  id bigint generated always as identity primary key,
  order_id uuid not null references public.orders (id) on delete cascade,
  actor_id uuid not null,
  from_status text,
  to_status text not null,
  action text not null,
  note text not null default '',
  created_at timestamptz not null default timezone('utc', now()),
  constraint order_events_note_len check (char_length(note) <= 400)
);

create index order_events_order_idx on public.order_events (order_id, created_at);

create table public.delivery_assignments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  courier_id uuid not null references public.profiles (id),
  assigned_by uuid not null,
  is_current boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  released_at timestamptz
);

create unique index delivery_assignments_one_current
  on public.delivery_assignments (order_id)
  where is_current;

create table public.delivery_incidents (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  reason_code text not null,
  note text not null default '',
  recorded_by uuid not null,
  created_at timestamptz not null default timezone('utc', now()),
  constraint delivery_incidents_reason check (
    reason_code in (
      'customer_absent', 'wrong_address', 'rejected', 'unreachable', 'other'
    )
  ),
  constraint delivery_incidents_note_len check (char_length(note) <= 400)
);

alter table public.products enable row level security;
alter table public.products force row level security;
alter table public.orders enable row level security;
alter table public.orders force row level security;
alter table public.order_items enable row level security;
alter table public.order_items force row level security;
alter table public.order_events enable row level security;
alter table public.order_events force row level security;
alter table public.delivery_assignments enable row level security;
alter table public.delivery_assignments force row level security;
alter table public.delivery_incidents enable row level security;
alter table public.delivery_incidents force row level security;

revoke all on table public.products from public, anon, authenticated;
revoke all on table public.orders from public, anon, authenticated;
revoke all on table public.order_items from public, anon, authenticated;
revoke all on table public.order_events from public, anon, authenticated;
revoke all on table public.delivery_assignments from public, anon, authenticated;
revoke all on table public.delivery_incidents from public, anon, authenticated;

grant select on table public.products to authenticated;
grant select on table public.orders to authenticated;
grant select on table public.order_items to authenticated;
grant select on table public.order_events to authenticated;
grant select on table public.delivery_assignments to authenticated;
grant select on table public.delivery_incidents to authenticated;

create or replace function public.protect_profile_privileges()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if tg_op = 'UPDATE' then
    if current_setting('mass.allow_profile_admin', true) is distinct from 'on'
      and (
        new.id is distinct from old.id
        or new.role is distinct from old.role
        or new.is_active is distinct from old.is_active
        or new.created_at is distinct from old.created_at
      )
      and coalesce(auth.role(), '') in ('authenticated', 'anon')
    then
      raise exception 'profile privilege change denied'
        using errcode = '42501';
    end if;
    new.updated_at = timezone('utc', now());
  end if;
  return new;
end;
$$;

create or replace function public.is_active_role(p_roles text[])
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and is_active
      and role = any (p_roles)
  );
$$;

create policy products_select_staff
  on public.products
  for select
  to authenticated
  using (public.is_active_role(array['administrator', 'operator']));

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
  );

create policy order_items_select_visible
  on public.order_items
  for select
  to authenticated
  using (
    exists (
      select 1 from public.orders
      where orders.id = order_items.order_id
    )
  );

create policy order_events_select_visible
  on public.order_events
  for select
  to authenticated
  using (
    exists (
      select 1 from public.orders
      where orders.id = order_events.order_id
    )
  );

create policy delivery_assignments_select_scoped
  on public.delivery_assignments
  for select
  to authenticated
  using (
    public.is_active_role(array['administrator', 'operator'])
    or courier_id = auth.uid()
  );

create policy delivery_incidents_select_visible
  on public.delivery_incidents
  for select
  to authenticated
  using (
    exists (
      select 1 from public.orders
      where orders.id = delivery_incidents.order_id
    )
  );

create or replace function public.search_products(p_query text)
returns setof public.products
language sql
stable
security invoker
set search_path = public
as $$
  select *
  from public.products
  where is_active
    and (
      p_query is null
      or btrim(p_query) = ''
      or name ilike '%' || replace(replace(left(btrim(p_query), 40), '%', ''), '_', '') || '%'
      or sku ilike '%' || replace(replace(left(btrim(p_query), 40), '%', ''), '_', '') || '%'
    )
  order by name
  limit 50;
$$;

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
  if v_actor is null or not public.is_active_role(array['administrator', 'operator']) then
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

create or replace function public.transition_order(
  p_order_id uuid,
  p_expected_version integer,
  p_target_status text,
  p_note text default ''
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor uuid := auth.uid();
  v_order public.orders%rowtype;
  v_allowed boolean := false;
begin
  if v_actor is null or not public.is_active_role(array['administrator', 'operator']) then
    raise exception 'not authorized' using errcode = '42501';
  end if;
  if coalesce(char_length(p_note), 0) > 400 then
    raise exception 'invalid note' using errcode = '22023';
  end if;

  select * into v_order from public.orders where id = p_order_id for update;
  if not found then
    raise exception 'not found' using errcode = 'P0002';
  end if;
  if v_order.version <> p_expected_version then
    raise exception 'version conflict' using errcode = '40001';
  end if;

  v_allowed := (
    v_order.modality = 'in_store' and v_order.status = 'submitted' and p_target_status = 'preparing'
  ) or (
    v_order.modality = 'in_store' and v_order.status = 'preparing' and p_target_status = 'ready_for_pickup'
  ) or (
    v_order.modality = 'in_store' and v_order.status = 'ready_for_pickup' and p_target_status = 'completed'
  ) or (
    v_order.modality = 'delivery' and v_order.status = 'submitted' and p_target_status = 'preparing'
  ) or (
    v_order.modality = 'delivery' and v_order.status = 'preparing' and p_target_status = 'ready_for_dispatch'
  ) or (
    v_order.status in ('submitted', 'preparing') and p_target_status = 'cancelled'
  );

  if not v_allowed then
    raise exception 'invalid transition' using errcode = '22023';
  end if;
  if p_target_status = 'cancelled' and char_length(btrim(coalesce(p_note, ''))) < 3 then
    raise exception 'cancel reason required' using errcode = '22023';
  end if;

  update public.orders
  set status = p_target_status,
      version = version + 1,
      updated_at = timezone('utc', now())
  where id = p_order_id;

  insert into public.order_events (order_id, actor_id, from_status, to_status, action, note)
  values (p_order_id, v_actor, v_order.status, p_target_status, 'transition', coalesce(btrim(p_note), ''));
end;
$$;

create or replace function public.list_couriers()
returns table (id uuid, full_name text)
language sql
stable
security definer
set search_path = public
as $$
  select profiles.id, profiles.full_name
  from public.profiles
  where public.is_active_role(array['administrator', 'operator'])
    and profiles.role = 'courier'
    and profiles.is_active
  order by profiles.full_name;
$$;

create or replace function public.assign_courier(
  p_order_id uuid,
  p_expected_version integer,
  p_courier_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor uuid := auth.uid();
  v_order public.orders%rowtype;
begin
  if v_actor is null or not public.is_active_role(array['administrator', 'operator']) then
    raise exception 'not authorized' using errcode = '42501';
  end if;
  if not exists (
    select 1 from public.profiles
    where id = p_courier_id and role = 'courier' and is_active
  ) then
    raise exception 'courier unavailable' using errcode = '22023';
  end if;

  select * into v_order from public.orders where id = p_order_id for update;
  if not found then
    raise exception 'not found' using errcode = 'P0002';
  end if;
  if v_order.version <> p_expected_version then
    raise exception 'version conflict' using errcode = '40001';
  end if;
  if v_order.modality <> 'delivery'
     or v_order.status not in ('ready_for_dispatch', 'assigned') then
    raise exception 'not assignable' using errcode = '22023';
  end if;

  update public.delivery_assignments
  set is_current = false, released_at = timezone('utc', now())
  where order_id = p_order_id and is_current;

  insert into public.delivery_assignments (order_id, courier_id, assigned_by)
  values (p_order_id, p_courier_id, v_actor);

  update public.orders
  set status = 'assigned', version = version + 1, updated_at = timezone('utc', now())
  where id = p_order_id;

  insert into public.order_events (order_id, actor_id, from_status, to_status, action)
  values (p_order_id, v_actor, v_order.status, 'assigned', 'assign');
end;
$$;

create or replace function public.start_delivery(
  p_order_id uuid,
  p_expected_version integer
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor uuid := auth.uid();
  v_order public.orders%rowtype;
begin
  if v_actor is null or not public.is_active_role(array['courier']) then
    raise exception 'not authorized' using errcode = '42501';
  end if;
  select * into v_order from public.orders where id = p_order_id for update;
  if not found then
    raise exception 'not found' using errcode = 'P0002';
  end if;
  if v_order.status = 'in_delivery' then
    return;
  end if;
  if v_order.version <> p_expected_version then
    raise exception 'version conflict' using errcode = '40001';
  end if;
  if v_order.status <> 'assigned' or not exists (
    select 1 from public.delivery_assignments
    where order_id = p_order_id and courier_id = v_actor and is_current
  ) then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  update public.orders
  set status = 'in_delivery', version = version + 1, updated_at = timezone('utc', now())
  where id = p_order_id;
  insert into public.order_events (order_id, actor_id, from_status, to_status, action)
  values (p_order_id, v_actor, 'assigned', 'in_delivery', 'start_delivery');
end;
$$;

create or replace function public.record_delivery_result(
  p_order_id uuid,
  p_expected_version integer,
  p_outcome text,
  p_reason text default '',
  p_note text default ''
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor uuid := auth.uid();
  v_order public.orders%rowtype;
begin
  if v_actor is null or not exists (
    select 1 from public.delivery_assignments
    where order_id = p_order_id and courier_id = v_actor and is_current
  ) then
    raise exception 'not authorized' using errcode = '42501';
  end if;
  if coalesce(char_length(p_note), 0) > 400 then
    raise exception 'invalid note' using errcode = '22023';
  end if;

  select * into v_order from public.orders where id = p_order_id for update;
  if not found then
    raise exception 'not found' using errcode = 'P0002';
  end if;
  if p_outcome = 'delivered' and v_order.status = 'completed' then
    return;
  end if;
  if p_outcome = 'failed' and v_order.status = 'delivery_failed' then
    return;
  end if;
  if v_order.version <> p_expected_version then
    raise exception 'version conflict' using errcode = '40001';
  end if;
  if v_order.status <> 'in_delivery' then
    raise exception 'invalid transition' using errcode = '22023';
  end if;

  if p_outcome = 'delivered' then
    update public.orders
    set status = 'completed', version = version + 1, updated_at = timezone('utc', now())
    where id = p_order_id;
    insert into public.order_events (order_id, actor_id, from_status, to_status, action)
    values
      (p_order_id, v_actor, 'in_delivery', 'delivered', 'deliver'),
      (p_order_id, v_actor, 'delivered', 'completed', 'complete');
    return;
  end if;

  if p_outcome <> 'failed'
     or p_reason not in ('customer_absent', 'wrong_address', 'rejected', 'unreachable', 'other') then
    raise exception 'invalid reason' using errcode = '22023';
  end if;

  update public.orders
  set status = 'delivery_failed', version = version + 1, updated_at = timezone('utc', now())
  where id = p_order_id;
  insert into public.delivery_incidents (order_id, reason_code, note, recorded_by)
  values (p_order_id, p_reason, coalesce(btrim(p_note), ''), v_actor);
  insert into public.order_events (order_id, actor_id, from_status, to_status, action, note)
  values (p_order_id, v_actor, 'in_delivery', 'delivery_failed', 'delivery_failed', p_reason);
end;
$$;

create or replace function public.operational_summary()
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  if not public.is_active_role(array['administrator']) then
    raise exception 'not authorized' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'total', (select count(*) from public.orders),
    'counts', (
      select coalesce(jsonb_object_agg(status, total), '{}'::jsonb)
      from (
        select status, count(*) as total
        from public.orders
        group by status
      ) grouped
    )
  );
end;
$$;

create or replace function public.list_staff()
returns table (id uuid, full_name text, role text, is_active boolean)
language sql
stable
security definer
set search_path = public
as $$
  select profiles.id, profiles.full_name, profiles.role, profiles.is_active
  from public.profiles
  where public.is_active_role(array['administrator'])
  order by profiles.full_name;
$$;

create or replace function public.admin_set_staff_access(
  p_user_id uuid,
  p_full_name text,
  p_role text,
  p_active boolean
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor uuid := auth.uid();
  v_previous public.profiles%rowtype;
begin
  if v_actor is null or not public.is_active_role(array['administrator']) then
    raise exception 'not authorized' using errcode = '42501';
  end if;
  if p_user_id = v_actor then
    raise exception 'cannot change own access' using errcode = '42501';
  end if;
  if p_role not in ('administrator', 'operator', 'courier', 'unassigned') then
    raise exception 'invalid role' using errcode = '22023';
  end if;
  if p_full_name is null or char_length(btrim(p_full_name)) not between 1 and 120 then
    raise exception 'invalid name' using errcode = '22023';
  end if;

  select * into v_previous from public.profiles where id = p_user_id for update;
  if not found then
    raise exception 'profile not found' using errcode = 'P0002';
  end if;

  perform set_config('mass.allow_profile_admin', 'on', true);
  update public.profiles
  set full_name = btrim(p_full_name), role = p_role, is_active = p_active
  where id = p_user_id;

  insert into public.profile_role_events (
    target_user_id, actor_role, previous_role, new_role, previous_active, new_active
  ) values (
    p_user_id, 'administrator', v_previous.role, p_role, v_previous.is_active, p_active
  );
end;
$$;

create or replace function public.list_order_contacts()
returns table (customer_name text, customer_phone text, order_count bigint)
language sql
stable
security definer
set search_path = public
as $$
  select customer_name, customer_phone, count(*) as order_count
  from public.orders
  where public.is_active_role(array['administrator'])
  group by customer_name, customer_phone
  order by customer_name
  limit 100;
$$;

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
  limit 50;
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
  p_active boolean
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
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
     or p_active is null then
    raise exception 'invalid product' using errcode = '22023';
  end if;

  if p_id is null then
    insert into public.products (
      sku, name, description, category, unit_label, price_cents, is_active, is_sample
    ) values (
      btrim(p_sku), btrim(p_name), coalesce(btrim(p_description), ''),
      btrim(p_category), btrim(p_unit_label), p_price_cents, p_active, true
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
      updated_at = timezone('utc', now())
  where id = p_id
  returning id into v_id;

  if v_id is null then
    raise exception 'product not found' using errcode = 'P0002';
  end if;
  return v_id;
end;
$$;

revoke all on function public.is_active_role(text[]) from public, anon;
revoke all on function public.search_products(text) from public, anon;
revoke all on function public.create_order(uuid, text, text, text, text, text, text, jsonb) from public, anon;
revoke all on function public.transition_order(uuid, integer, text, text) from public, anon;
revoke all on function public.list_couriers() from public, anon;
revoke all on function public.assign_courier(uuid, integer, uuid) from public, anon;
revoke all on function public.start_delivery(uuid, integer) from public, anon;
revoke all on function public.record_delivery_result(uuid, integer, text, text, text) from public, anon;
revoke all on function public.operational_summary() from public, anon;
revoke all on function public.list_staff() from public, anon;
revoke all on function public.admin_set_staff_access(uuid, text, text, boolean) from public, anon;
revoke all on function public.list_order_contacts() from public, anon;
revoke all on function public.list_catalog(text, boolean) from public, anon;
revoke all on function public.upsert_product(uuid, text, text, text, text, text, integer, boolean) from public, anon;

grant execute on function public.is_active_role(text[]) to authenticated;
grant execute on function public.search_products(text) to authenticated;
grant execute on function public.create_order(uuid, text, text, text, text, text, text, jsonb) to authenticated;
grant execute on function public.transition_order(uuid, integer, text, text) to authenticated;
grant execute on function public.list_couriers() to authenticated;
grant execute on function public.assign_courier(uuid, integer, uuid) to authenticated;
grant execute on function public.start_delivery(uuid, integer) to authenticated;
grant execute on function public.record_delivery_result(uuid, integer, text, text, text) to authenticated;
grant execute on function public.operational_summary() to authenticated;
grant execute on function public.list_staff() to authenticated;
grant execute on function public.admin_set_staff_access(uuid, text, text, boolean) to authenticated;
grant execute on function public.list_order_contacts() to authenticated;
grant execute on function public.list_catalog(text, boolean) to authenticated;
grant execute on function public.upsert_product(uuid, text, text, text, text, text, integer, boolean) to authenticated;
