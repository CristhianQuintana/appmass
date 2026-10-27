/**
 * Equivalente de proponer_imagenes_mass.py (Node), porque Python no está en PATH.
 * Consulta Open Food Facts, genera CSV de revisión y SQL solo para filas approved=YES.
 */
const fs = require('fs');
const path = require('path');

const ROOT = __dirname;
const INPUT_CSV = path.join(ROOT, 'products.csv');
const OUTPUT_REVIEW_CSV = path.join(ROOT, 'imagenes_candidatas_mass.csv');
const OUTPUT_SQL = path.join(ROOT, 'actualizar_imagenes_mass.sql');
const API_URL = 'https://world.openfoodfacts.org/cgi/search.pl';
const USER_AGENT = 'AppMASS-ImageCatalogReview/1.0 (catalog image URL audit)';

function parseArgs(argv) {
  const args = { fromReview: false, minScore: null };
  for (let i = 0; i < argv.length; i += 1) {
    if (argv[i] === '--from-review') args.fromReview = true;
    if (argv[i] === '--auto-approve-min-score') {
      args.minScore = Number(argv[i + 1]);
      i += 1;
    }
  }
  return args;
}

function normalize(value) {
  return String(value || '')
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9áéíóúüñ ]+/gi, ' ')
    .replace(/\s+/g, ' ');
}

function parseCsv(text) {
  const lines = text.replace(/^\uFEFF/, '').split(/\r?\n/).filter(Boolean);
  if (!lines.length) return [];
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

function emptyCandidate() {
  return {
    candidate_name: '',
    brand: '',
    quantity: '',
    barcode: '',
    image_url: '',
    source_url: '',
    similarity_score: 0,
  };
}

async function searchCandidate(name, category) {
  const terms = [name, category].filter(Boolean).join(' ');
  const url = new URL(API_URL);
  url.searchParams.set('search_terms', terms);
  url.searchParams.set('search_simple', '1');
  url.searchParams.set('action', 'process');
  url.searchParams.set('json', '1');
  url.searchParams.set('page_size', '10');
  url.searchParams.set(
    'fields',
    'product_name,brands,quantity,code,image_front_url,image_url,url',
  );

  const response = await fetch(url, {
    headers: { 'User-Agent': USER_AGENT },
  });
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  const body = await response.json();
  const products = body.products || [];
  const wanted = normalize(name);
  const wantedTokens = new Set(wanted.split(' ').filter(Boolean));
  let best = null;
  let bestScore = -1;

  for (const product of products) {
    const productName = product.product_name || '';
    const imageUrl = product.image_front_url || product.image_url || '';
    if (!productName || !String(imageUrl).startsWith('https://')) continue;

    const candidateTokens = new Set(
      normalize(productName)
        .split(' ')
        .filter(Boolean),
    );
    const union = new Set([...wantedTokens, ...candidateTokens]);
    let score = 0;
    if (union.size) {
      let inter = 0;
      for (const token of wantedTokens) {
        if (candidateTokens.has(token)) inter += 1;
      }
      score = inter / union.size;
    }
    if (normalize(productName) === wanted) score += 1.0;
    if (score > bestScore) {
      bestScore = score;
      best = {
        candidate_name: productName,
        brand: product.brands || '',
        quantity: product.quantity || '',
        barcode: product.code || '',
        image_url: imageUrl,
        source_url: product.url || '',
        similarity_score: Number(score.toFixed(3)),
      };
    }
  }
  return best || emptyCandidate();
}

function writeSql(rows) {
  const approved = rows.filter(
    (row) =>
      String(row.approved || '')
        .trim()
        .toUpperCase() === 'YES' &&
      String(row.image_url || '').startsWith('https://'),
  );
  let body = '-- Revisar antes de ejecutar en Supabase SQL Editor.\n';
  body += '-- Solo contiene productos aprobados manualmente.\n';
  body += 'BEGIN;\n\n';
  if (approved.length) {
    body +=
      'UPDATE public.products AS p\n' +
      'SET image_url = v.image_url, updated_at = timezone(\'utc\', now())\n' +
      'FROM (VALUES\n';
    body += approved
      .map((row) => `  (${sqlQuote(row.sku)}, ${sqlQuote(row.image_url)})`)
      .join(',\n');
    body += '\n) AS v(sku, image_url)\nWHERE p.sku = v.sku;\n\n';
  } else {
    body += '-- No hay imágenes aprobadas. No se modificó ninguna fila.\n\n';
  }
  body += 'COMMIT;\n';
  fs.writeFileSync(OUTPUT_SQL, body, 'utf8');
  return approved.length;
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function propose() {
  if (!fs.existsSync(INPUT_CSV)) {
    throw new Error('No existe products.csv');
  }
  const rows = parseCsv(fs.readFileSync(INPUT_CSV, 'utf8'));
  const reviewed = [];
  for (let index = 0; index < rows.length; index += 1) {
    const row = rows[index];
    const sku = (row.sku || '').trim();
    const name = (row.name || '').trim();
    const category = (row.category || '').trim();
    if (!sku || !name) continue;

    let candidate;
    try {
      candidate = await searchCandidate(name, category);
    } catch (error) {
      candidate = emptyCandidate();
      console.log(`Aviso: no se pudo consultar ${sku}: ${error.message}`);
    }

    reviewed.push({
      sku,
      catalog_name: name,
      category,
      ...candidate,
      approved: 'NO',
    });
    console.log(
      `[${index + 1}/${rows.length}] ${sku}: ${
        candidate.candidate_name || 'sin resultado'
      } (score=${candidate.similarity_score})`,
    );
    await sleep(1000);
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
  const count = writeSql(reviewed);
  console.log(`\nCandidatos: ${OUTPUT_REVIEW_CSV}`);
  console.log(`SQL: ${OUTPUT_SQL} (${count} aprobados)`);
}

function fromReview(minScore) {
  if (!fs.existsSync(OUTPUT_REVIEW_CSV)) {
    throw new Error(`No existe ${OUTPUT_REVIEW_CSV}`);
  }
  const rows = parseCsv(fs.readFileSync(OUTPUT_REVIEW_CSV, 'utf8'));
  if (minScore != null && !Number.isNaN(minScore)) {
    for (const row of rows) {
      const score = Number(row.similarity_score || 0);
      const image = String(row.image_url || '').trim();
      if (score >= minScore && image.startsWith('https://')) {
        row.approved = 'YES';
      }
    }
    const columns = Object.keys(rows[0] || {});
    fs.writeFileSync(OUTPUT_REVIEW_CSV, `\uFEFF${toCsv(rows, columns)}`, 'utf8');
  }
  const count = writeSql(rows);
  console.log(`SQL: ${OUTPUT_SQL} (${count} aprobados)`);
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.fromReview) {
    fromReview(args.minScore);
  } else {
    await propose();
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
