-- Catálogo ficticio para desarrollo. No representa precios ni productos de Tiendas MASS.

insert into public.products (sku, name, description, category, unit_label, price_cents, is_active, is_sample)
values
  ('PRB-001', 'Agua de mesa 625 ml', 'Dato de prueba', 'Bebidas', 'botella', 150, true, true),
  ('PRB-002', 'Pan de molde', 'Dato de prueba', 'Panadería', 'bolsa', 750, true, true),
  ('PRB-003', 'Leche evaporada', 'Dato de prueba', 'Lácteos', 'tarro', 420, true, true),
  ('PRB-004', 'Arroz extra 1 kg', 'Dato de prueba', 'Abarrotes', 'bolsa', 450, true, true),
  ('PRB-005', 'Aceite vegetal 1 L', 'Dato de prueba', 'Abarrotes', 'botella', 890, true, true),
  ('PRB-006', 'Gaseosa cola 500 ml', 'Producto inactivo de prueba', 'Bebidas', 'botella', 250, false, true),
  ('PRB-007', 'Detergente 400 g', 'Dato de prueba', 'Limpieza', 'bolsa', 320, true, true),
  ('PRB-008', 'Huevos x 10', 'Dato de prueba', 'Abarrotes', 'maple', 800, true, true);
