-- Ejecutar en Supabase → SQL Editor (permite ver el catálogo sin iniciar sesión).
create or replace function public.list_public_catalog(p_query text default '')
returns setof public.products
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_term text := replace(replace(left(btrim(coalesce(p_query, '')), 40), '%', ''), '_', '');
begin
  return query
  select *
  from public.products
  where is_active
    and (
      v_term = ''
      or name ilike '%' || v_term || '%'
      or sku ilike '%' || v_term || '%'
    )
  order by name
  limit 120;
end;
$$;

revoke all on function public.list_public_catalog(text) from public;
grant execute on function public.list_public_catalog(text) to anon, authenticated;
