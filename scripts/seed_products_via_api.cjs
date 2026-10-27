/**
 * Inserta/actualiza 100 productos con image_url usando sb_secret_.
 * Requiere que la columna image_url ya exista.
 */
const fs = require('fs');
const path = require('path');

const url = (process.env.SUPABASE_URL || '').replace(/\/$/, '');
const secret = process.env.SUPABASE_SECRET || '';
if (!url || !secret) {
  console.error('Faltan SUPABASE_URL o SUPABASE_SECRET');
  process.exit(1);
}

const sql = fs.readFileSync(
  path.join(__dirname, '../supabase/scripts/seed_100_products_with_images.sql'),
  'utf8',
);
const match = sql.match(
  /insert into public\.products \([\s\S]*?\) values\n([\s\S]*?)\non conflict/i,
);
if (!match) {
  console.error('No se encontraron valores en el SQL');
  process.exit(1);
}

const rows = [];
const re =
  /\('([^']+)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', (\d+), (true|false), true, '([^']+)'\)/g;
let m;
while ((m = re.exec(match[1]))) {
  rows.push({
    sku: m[1],
    name: m[2].replace(/''/g, "'"),
    description: m[3].replace(/''/g, "'"),
    category: m[4].replace(/''/g, "'"),
    unit_label: m[5].replace(/''/g, "'"),
    price_cents: Number(m[6]),
    is_active: m[7] === 'true',
    is_sample: true,
    image_url: m[8],
  });
}

async function upsertBatch(batch) {
  const response = await fetch(`${url}/rest/v1/products?on_conflict=sku`, {
    method: 'POST',
    headers: {
      apikey: secret,
      Authorization: `Bearer ${secret}`,
      'Content-Type': 'application/json',
      Prefer: 'resolution=merge-duplicates,return=minimal',
      'User-Agent': 'app-mass-seed/1.0',
    },
    body: JSON.stringify(batch),
  });
  if (!response.ok) {
    throw new Error(`${response.status} ${await response.text()}`);
  }
}

async function main() {
  console.log(`Filas parseadas: ${rows.length}`);
  for (let i = 0; i < rows.length; i += 20) {
    const batch = rows.slice(i, i + 20);
    await upsertBatch(batch);
    console.log(`ok ${i + 1}-${i + batch.length}`);
  }
  const count = await fetch(
    `${url}/rest/v1/products?select=sku&is_sample=eq.true`,
    {
      headers: {
        apikey: secret,
        Authorization: `Bearer ${secret}`,
        'User-Agent': 'app-mass-seed/1.0',
        Prefer: 'count=exact',
      },
    },
  );
  console.log('count-header', count.headers.get('content-range'));
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
