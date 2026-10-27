/**
 * Obtiene candidatos de imagen por categoría (pocas búsquedas, respeta rate limit OFF),
 * genera CSV/SQL de revisión y actualiza public.products vía REST (sb_secret).
 *
 * Uso:
 *   node actualizar_imagenes_via_api.cjs              # fetch + aprobar + aplicar
 *   node actualizar_imagenes_via_api.cjs --fetch-only  # solo CSV/SQL
 *   node actualizar_imagenes_via_api.cjs --apply-only  # aplica SQL/CSV ya aprobado
 */
const fs = require('fs');
const path = require('path');

const ROOT = __dirname;
const INPUT_CSV = path.join(ROOT, 'products.csv');
const OUTPUT_REVIEW_CSV = path.join(ROOT, 'imagenes_candidatas_mass.csv');
const OUTPUT_SQL = path.join(ROOT, 'actualizar_imagenes_mass.sql');

const USER_AGENT = 'AppMASS-ImageCatalogReview/1.0 (catalog image URL audit)';

const CATEGORY_SOURCES = {
  Bebidas: {
    host: 'https://world.openfoodfacts.org',
    params: { categories_tags_en: 'beverages' },
  },
  Panadería: {
    host: 'https://world.openfoodfacts.org',
    params: { categories_tags_en: 'breads' },
  },
  Lácteos: {
    host: 'https://world.openfoodfacts.org',
    params: { categories_tags_en: 'dairies' },
  },
  Abarrotes: {
    host: 'https://world.openfoodfacts.org',
    params: { categories_tags_en: 'groceries' },
  },
  Snacks: {
    host: 'https://world.openfoodfacts.org',
    params: { categories_tags_en: 'snacks' },
  },
  Limpieza: {
    host: 'https://world.openproductsfacts.org',
    params: { categories_tags_en: 'detergents' },
  },
  'Cuidado personal': {
    host: 'https://world.openbeautyfacts.org',
    params: { categories_tags_en: 'body' },
  },
};

const FALLBACK_POOLS = {
  Bebidas: [
    'https://images.openfoodfacts.org/images/products/544/900/000/0996/front_en.633.400.jpg',
    'https://images.openfoodfacts.org/images/products/301/762/042/2003/front_en.54.400.jpg',
    'https://images.openfoodfacts.org/images/products/500/011/258/6004/front_en.148.400.jpg',
  ],
  Panadería: [
    'https://images.openfoodfacts.org/images/products/762/221/044/9283/front_en.439.400.jpg',
    'https://images.openfoodfacts.org/images/products/301/762/042/5035/front_fr.176.400.jpg',
  ],
  Lácteos: [
    'https://images.openfoodfacts.org/images/products/301/762/042/2003/front_en.54.400.jpg',
    'https://images.openfoodfacts.org/images/products/848/000/010/6173/front_es.21.400.jpg',
  ],
  Abarrotes: [
    'https://images.openfoodfacts.org/images/products/807/680/951/3388/front_en.195.400.jpg',
    'https://images.openfoodfacts.org/images/products/301/762/042/9484/front_en.43.400.jpg',
  ],
  Snacks: [
    'https://images.openfoodfacts.org/images/products/841/007/647/2405/front_es.29.400.jpg',
    'https://images.openfoodfacts.org/images/products/762/221/044/9283/front_en.439.400.jpg',
  ],
  Limpieza: [
    'https://images.openproductsfacts.org/images/products/800/109/089/6663/front_es.4.400.jpg',
    'https://images.openproductsfacts.org/images/products/400/590/049/6878/front_de.4.400.jpg',
  ],
  'Cuidado personal': [
    'https://images.openbeautyfacts.org/images/products/360/054/192/6387/front_fr.4.400.jpg',
    'https://images.openbeautyfacts.org/images/products/301/426/028/0497/front_fr.4.400.jpg',
  ],
};

function parseArgs(argv) {
  return {
    fetchOnly: argv.includes('--fetch-only'),
    applyOnly: argv.includes('--apply-only'),
  };
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
  return lines.slice(1).map((line) => {
    const cells = splitCsvLine(line);
    const row = {};
    headers.forEach((header, index) => {
      row[header] = cells[index] ?? '';
    });
    return row;
  });
}

function toCsv(rows, columns) {
  const escape = (value) => {
    const text = String(value ?? '');
    if (/[",\n\r]/.test(text)) return `"${text.replace(/"/g, '""')}"`;
    return text;
  };
  return [
    columns.join(','),
    ...rows.map((row) => columns.map((column) => escape(row[column])).join(',')),
  ].join('\n');
}

function sqlQuote(value) {
  return `'${String(value).replace(/'/g, "''")}'`;
}

function normalize(value) {
  return String(value || '')
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9áéíóúüñ ]+/gi, ' ')
    .replace(/\s+/g, ' ');
}

function scoreName(wanted, candidate) {
  const wantedTokens = new Set(normalize(wanted).split(' ').filter(Boolean));
  const candidateTokens = new Set(normalize(candidate).split(' ').filter(Boolean));
  const union = new Set([...wantedTokens, ...candidateTokens]);
  if (!union.size) return 0;
  let inter = 0;
  for (const token of wantedTokens) {
    if (candidateTokens.has(token)) inter += 1;
  }
  let score = inter / union.size;
  if (normalize(wanted) === normalize(candidate)) score += 1;
  return Number(score.toFixed(3));
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function fetchCategoryPool(category) {
  const source = CATEGORY_SOURCES[category];
  if (!source) return [];

  const url = new URL(`${source.host}/api/v2/search`);
  Object.entries(source.params).forEach(([key, value]) => {
    url.searchParams.set(key, value);
  });
  url.searchParams.set('fields', 'code,product_name,brands,quantity,image_front_url,image_url,url');
  url.searchParams.set('page_size', '50');
  url.searchParams.set('sort_by', 'unique_scans_n');

  for (let attempt = 1; attempt <= 4; attempt += 1) {
    const response = await fetch(url, { headers: { 'User-Agent': USER_AGENT } });
    if (response.status === 503 || response.status === 429) {
      const wait = 8000 * attempt;
      console.log(`  rate-limit ${category}: HTTP ${response.status}, reintento en ${wait}ms`);
      await sleep(wait);
      continue;
    }
    if (!response.ok) {
      throw new Error(`HTTP ${response.status} en ${category}`);
    }
    const body = await response.json();
    const products = (body.products || [])
      .map((product) => {
        const imageUrl = product.image_front_url || product.image_url || '';
        if (!product.product_name || !String(imageUrl).startsWith('https://')) return null;
        return {
          candidate_name: product.product_name,
          brand: product.brands || '',
          quantity: product.quantity || '',
          barcode: product.code || '',
          image_url: imageUrl,
          source_url: product.url || `${source.host}/product/${product.code}`,
        };
      })
      .filter(Boolean);
    console.log(`  ${category}: ${products.length} candidatos`);
    return products;
  }
  console.log(`  ${category}: sin candidatos tras reintentos`);
  return [];
}

function pickBest(pool, name, usedBarcodes) {
  let best = null;
  let bestScore = -1;
  for (const candidate of pool) {
    if (usedBarcodes.has(candidate.barcode)) continue;
    const score = scoreName(name, candidate.candidate_name);
    // Prefer unused + any score; boost unused uniqueness later by barcode.
    const adjusted = score + (usedBarcodes.has(candidate.barcode) ? 0 : 0.01);
    if (adjusted > bestScore) {
      bestScore = adjusted;
      best = { ...candidate, similarity_score: score };
    }
  }
  if (!best && pool.length) {
    const fallback = pool.find((item) => !usedBarcodes.has(item.barcode)) || pool[0];
    best = { ...fallback, similarity_score: scoreName(name, fallback.candidate_name) };
  }
  return best;
}

function writeSql(rows) {
  const approved = rows.filter(
    (row) =>
      String(row.approved || '').trim().toUpperCase() === 'YES' &&
      String(row.image_url || '').startsWith('https://'),
  );
  let body = '-- Revisar antes de ejecutar en Supabase SQL Editor.\n';
  body += '-- Solo contiene productos aprobados (demo PRB: auto-aprobados tras match por categoría).\n';
  body += 'BEGIN;\n\n';
  if (approved.length) {
    body +=
      'UPDATE public.products AS p\n' +
      "SET image_url = v.image_url, updated_at = timezone('utc', now())\n" +
      'FROM (VALUES\n';
    body += approved
      .map((row) => `  (${sqlQuote(row.sku)}, ${sqlQuote(row.image_url)})`)
      .join(',\n');
    body += '\n) AS v(sku, image_url)\nWHERE p.sku = v.sku;\n\n';
  } else {
    body += '-- No hay imágenes aprobadas.\n\n';
  }
  body += 'COMMIT;\n';
  fs.writeFileSync(OUTPUT_SQL, body, 'utf8');
  return approved;
}

async function fetchAndBuildReview() {
  if (!fs.existsSync(INPUT_CSV)) {
    throw new Error('Falta products.csv');
  }
  const rows = parseCsv(fs.readFileSync(INPUT_CSV, 'utf8'));
  const categories = [...new Set(rows.map((row) => (row.category || '').trim()).filter(Boolean))];
  const pools = {};

  for (let i = 0; i < categories.length; i += 1) {
    const category = categories[i];
    console.log(`[${i + 1}/${categories.length}] Buscando categoría ${category}...`);
    try {
      pools[category] = await fetchCategoryPool(category);
    } catch (error) {
      console.log(`  aviso ${category}: ${error.message}`);
      pools[category] = [];
    }
    if (i < categories.length - 1) {
      await sleep(7000); // < 10 search/min
    }
  }

  const usedBarcodes = new Set();
  const fallbackCounters = {};
  const reviewed = [];

  for (const row of rows) {
    const sku = (row.sku || '').trim();
    const name = (row.name || '').trim();
    const category = (row.category || '').trim();
    if (!sku || !name) continue;

    let candidate = pickBest(pools[category] || [], name, usedBarcodes);
    if (candidate?.barcode) usedBarcodes.add(candidate.barcode);

    if (!candidate || !String(candidate.image_url || '').startsWith('https://')) {
      const pool = FALLBACK_POOLS[category] || FALLBACK_POOLS.Abarrotes;
      const index = fallbackCounters[category] || 0;
      fallbackCounters[category] = index + 1;
      candidate = {
        candidate_name: `${name} (fallback categoría)`,
        brand: '',
        quantity: '',
        barcode: '',
        image_url: pool[index % pool.length],
        source_url: '',
        similarity_score: 0,
      };
    }

    reviewed.push({
      sku,
      catalog_name: name,
      category,
      candidate_name: candidate.candidate_name,
      brand: candidate.brand || '',
      quantity: candidate.quantity || '',
      barcode: candidate.barcode || '',
      image_url: candidate.image_url,
      source_url: candidate.source_url || '',
      similarity_score: candidate.similarity_score ?? 0,
      // Demo PRB genérico: se aprueba para poder probar la app; no es catálogo oficial MASS.
      approved: 'YES',
    });
  }

  const columns = [
    'sku',
    'catalog_name',
    'category',
    'candidate_name',
    'brand',
    'quantity',
    'barcode',
    'image_url',
    'source_url',
    'similarity_score',
    'approved',
  ];
  fs.writeFileSync(OUTPUT_REVIEW_CSV, `\uFEFF${toCsv(reviewed, columns)}`, 'utf8');
  const approved = writeSql(reviewed);
  console.log(`CSV: ${OUTPUT_REVIEW_CSV}`);
  console.log(`SQL: ${OUTPUT_SQL} (${approved.length} aprobados)`);
  return approved;
}

async function applyUpdates(approved) {
  const url = (process.env.SUPABASE_URL || '').replace(/\/$/, '');
  const secret = process.env.SUPABASE_SECRET || '';
  if (!url || !secret) {
    throw new Error('Faltan SUPABASE_URL o SUPABASE_SECRET');
  }

  let rows = approved;
  if (!rows) {
    if (!fs.existsSync(OUTPUT_REVIEW_CSV)) {
      throw new Error('No hay CSV de revisión para aplicar');
    }
    rows = parseCsv(fs.readFileSync(OUTPUT_REVIEW_CSV, 'utf8')).filter(
      (row) =>
        String(row.approved || '').trim().toUpperCase() === 'YES' &&
        String(row.image_url || '').startsWith('https://'),
    );
  }

  console.log(`Aplicando ${rows.length} image_url en Supabase...`);
  for (let i = 0; i < rows.length; i += 20) {
    const batch = rows.slice(i, i + 20);
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

  const verify = await fetch(
    `${url}/rest/v1/products?select=sku,name,image_url&sku=like.PRB-*&order=sku.asc&limit=5`,
    {
      headers: {
        apikey: secret,
        Authorization: `Bearer ${secret}`,
        'User-Agent': 'app-mass-catalog-images/1.0',
      },
    },
  );
  const sample = await verify.json();
  console.log('muestra:', JSON.stringify(sample, null, 2));
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.applyOnly) {
    await applyUpdates(null);
    return;
  }
  const approved = await fetchAndBuildReview();
  if (!args.fetchOnly) {
    await applyUpdates(approved);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
