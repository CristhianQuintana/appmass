/**
 * Completa Limpieza y Cuidado personal con cgi/search.pl (más estable) y aplica PATCH.
 */
const fs = require('fs');
const path = require('path');

const ROOT = __dirname;
const CSV = path.join(ROOT, 'imagenes_candidatas_mass.csv');
const SQL = path.join(ROOT, 'actualizar_imagenes_mass.sql');
const USER_AGENT = 'AppMASS-ImageCatalogReview/1.0 (catalog image URL audit)';

const QUERIES = {
  Limpieza: {
    host: 'https://world.openproductsfacts.org',
    terms: [
      'detergent',
      'dishwashing liquid',
      'bleach',
      'fabric softener',
      'toilet cleaner',
      'glass cleaner',
      'soap',
      'shampoo',
      'toothpaste',
      'trash bags',
      'sponge',
      'disinfectant',
      'floor wax',
      'laundry',
      'napkins',
    ],
  },
  'Cuidado personal': {
    host: 'https://world.openbeautyfacts.org',
    terms: [
      'toothbrush',
      'dental floss',
      'deodorant',
      'body cream',
      'sunscreen',
      'wet wipes',
      'cotton',
      'cotton swab',
      'intimate wash',
      'shaving cream',
    ],
  },
};

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function splitCsvLine(line) {
  const result = [];
  let current = '';
  let inQuotes = false;
  for (let i = 0; i < line.length; i += 1) {
    const char = line[i];
    if (char === '"') {
      if (inQuotes && line[i + 1] === '"') {
        current += '"';
        i += 1;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }
    if (char === ',' && !inQuotes) {
      result.push(current);
      current = '';
      continue;
    }
    current += char;
  }
  result.push(current);
  return result;
}

function parseCsv(text) {
  const lines = text.replace(/^\uFEFF/, '').split(/\r?\n/).filter(Boolean);
  const headers = splitCsvLine(lines[0]);
  return {
    headers,
    rows: lines.slice(1).map((line) => {
      const cells = splitCsvLine(line);
      const row = {};
      headers.forEach((h, i) => {
        row[h] = cells[i] ?? '';
      });
      return row;
    }),
  };
}

function toCsv(rows, columns) {
  const escape = (value) => {
    const text = String(value ?? '');
    if (/[",\n\r]/.test(text)) return `"${text.replace(/"/g, '""')}"`;
    return text;
  };
  return [
    columns.join(','),
    ...rows.map((row) => columns.map((c) => escape(row[c])).join(',')),
  ].join('\n');
}

function sqlQuote(value) {
  return `'${String(value).replace(/'/g, "''")}'`;
}

async function search(host, term) {
  const url = new URL(`${host}/cgi/search.pl`);
  url.searchParams.set('search_terms', term);
  url.searchParams.set('search_simple', '1');
  url.searchParams.set('action', 'process');
  url.searchParams.set('json', '1');
  url.searchParams.set('page_size', '10');
  url.searchParams.set(
    'fields',
    'product_name,brands,quantity,code,image_front_url,image_url,url',
  );
  for (let attempt = 1; attempt <= 3; attempt += 1) {
    const response = await fetch(url, { headers: { 'User-Agent': USER_AGENT } });
    if (response.status === 503 || response.status === 429) {
      await sleep(7000 * attempt);
      continue;
    }
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const body = await response.json();
    return (body.products || [])
      .map((p) => {
        const image = p.image_front_url || p.image_url || '';
        if (!p.product_name || !String(image).startsWith('https://')) return null;
        return {
          candidate_name: p.product_name,
          brand: p.brands || '',
          quantity: p.quantity || '',
          barcode: p.code || '',
          image_url: image,
          source_url: p.url || '',
        };
      })
      .filter(Boolean);
  }
  return [];
}

async function buildPool(category) {
  const cfg = QUERIES[category];
  const pool = [];
  const seen = new Set();
  for (const term of cfg.terms) {
    console.log(`  ${category} / ${term}`);
    try {
      const found = await search(cfg.host, term);
      for (const item of found) {
        if (seen.has(item.barcode || item.image_url)) continue;
        seen.add(item.barcode || item.image_url);
        pool.push(item);
      }
    } catch (error) {
      console.log(`    aviso: ${error.message}`);
    }
    await sleep(6500);
  }
  console.log(`  pool ${category}: ${pool.length}`);
  return pool;
}

async function main() {
  const { headers, rows } = parseCsv(fs.readFileSync(CSV, 'utf8'));
  const pools = {
    Limpieza: await buildPool('Limpieza'),
    'Cuidado personal': await buildPool('Cuidado personal'),
  };

  const used = new Set();
  const updated = [];
  for (const row of rows) {
    const pool = pools[row.category];
    if (!pool || !pool.length) continue;
    const pick =
      pool.find((p) => p.barcode && !used.has(p.barcode)) ||
      pool.find((p) => !used.has(p.image_url)) ||
      pool[0];
    if (pick.barcode) used.add(pick.barcode);
    used.add(pick.image_url);
    row.candidate_name = pick.candidate_name;
    row.brand = pick.brand;
    row.quantity = pick.quantity;
    row.barcode = pick.barcode;
    row.image_url = pick.image_url;
    row.source_url = pick.source_url;
    row.similarity_score = '0.2';
    row.approved = 'YES';
    updated.push(row);
  }

  fs.writeFileSync(CSV, `\uFEFF${toCsv(rows, headers)}`, 'utf8');

  const approved = rows.filter(
    (r) => r.approved === 'YES' && String(r.image_url).startsWith('https://'),
  );
  let sql =
    '-- Revisar antes de ejecutar en Supabase SQL Editor.\n' +
    '-- Solo contiene productos aprobados.\nBEGIN;\n\n';
  sql +=
    'UPDATE public.products AS p\nSET image_url = v.image_url, updated_at = timezone(\'utc\', now())\nFROM (VALUES\n';
  sql += approved
    .map((r) => `  (${sqlQuote(r.sku)}, ${sqlQuote(r.image_url)})`)
    .join(',\n');
  sql += '\n) AS v(sku, image_url)\nWHERE p.sku = v.sku;\n\nCOMMIT;\n';
  fs.writeFileSync(SQL, sql, 'utf8');

  const url = (process.env.SUPABASE_URL || '').replace(/\/$/, '');
  const secret = process.env.SUPABASE_SECRET || '';
  console.log(`Aplicando ${updated.length} no-food...`);
  for (let i = 0; i < updated.length; i += 20) {
    const batch = updated.slice(i, i + 20);
    await Promise.all(
      batch.map(async (row) => {
        const response = await fetch(
          `${url}/rest/v1/products?sku=eq.${encodeURIComponent(row.sku)}`,
          {
            method: 'PATCH',
            headers: {
              apikey: secret,
              Authorization: `Bearer ${secret}`,
              'Content-Type': 'application/json',
              Prefer: 'return=minimal',
              'User-Agent': 'app-mass-catalog-images/1.0',
            },
            body: JSON.stringify({
              image_url: row.image_url,
              updated_at: new Date().toISOString(),
            }),
          },
        );
        if (!response.ok) {
          throw new Error(`${row.sku}: ${response.status} ${await response.text()}`);
        }
      }),
    );
    console.log(`ok ${i + 1}-${i + batch.length}`);
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
