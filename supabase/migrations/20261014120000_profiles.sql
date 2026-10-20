-- Perfiles internos vinculados a Supabase Auth.
-- El cliente autenticado solo puede leer su propia fila.
-- No puede insertar, cambiar su rol ni activar su cuenta.
-- La provisión de roles queda reservada a service_role.

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null default '',
  role text not null default 'unassigned',
  is_active boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint profiles_role_check check (
    role in ('administrator', 'operator', 'courier', 'unassigned')
  ),
  constraint profiles_full_name_length check (char_length(full_name) <= 120)
);

comment on table public.profiles is
  'Perfil operativo. El rol no se toma de la metadata enviada por el cliente.';

alter table public.profiles enable row level security;
alter table public.profiles force row level security;

revoke all on table public.profiles from public;
revoke all on table public.profiles from anon;
revoke all on table public.profiles from authenticated;
grant select on table public.profiles to authenticated;

create policy profiles_select_own
  on public.profiles
  for select
  to authenticated
  using (id = (select auth.uid()));

create table public.profile_role_events (
  id bigint generated always as identity primary key,
  target_user_id uuid not null references public.profiles (id) on delete cascade,
  actor_role text not null,
  previous_role text,
  new_role text not null,
  previous_active boolean,
  new_active boolean not null,
  created_at timestamptz not null default timezone('utc', now()),
  constraint profile_role_events_role_check check (
    new_role in ('administrator', 'operator', 'courier', 'unassigned')
  )
);

comment on table public.profile_role_events is
  'Historial de asignación de rol. No es consultable por la app cliente.';

alter table public.profile_role_events enable row level security;
alter table public.profile_role_events force row level security;

revoke all on table public.profile_role_events from public;
revoke all on table public.profile_role_events from anon;
revoke all on table public.profile_role_events from authenticated;

create or replace function public.protect_profile_privileges()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if tg_op = 'UPDATE' then
    if new.id is distinct from old.id
      or new.role is distinct from old.role
      or new.is_active is distinct from old.is_active
      or new.created_at is distinct from old.created_at
    then
      if coalesce(auth.role(), '') in ('authenticated', 'anon') then
        raise exception 'profile privilege change denied'
          using errcode = '42501';
      end if;
    end if;
    new.updated_at = timezone('utc', now());
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_protect_privileges on public.profiles;
create trigger profiles_protect_privileges
  before update on public.profiles
  for each row
  execute function public.protect_profile_privileges();

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, role, is_active)
  values (
    new.id,
    left(coalesce(new.raw_user_meta_data ->> 'full_name', ''), 120),
    'unassigned',
    false
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_auth_user();

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
  if target_role not in ('administrator', 'operator', 'courier', 'unassigned') then
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

revoke all on function public.handle_new_auth_user() from anon, authenticated;
revoke all on function public.protect_profile_privileges() from anon, authenticated;
revoke all on function public.provision_staff_profile(uuid, text, text, boolean)
  from public, anon, authenticated;
grant execute on function public.provision_staff_profile(uuid, text, text, boolean)
  to service_role;
