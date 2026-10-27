/**
 * Reescribe image_url en seed_100_products_with_images.sql a partir del CSV aprobado.
 */
const fs = require('fs');
const path = require('path');

const ROOT = __dirname;
const csvPath = path.join(ROOT, 'imagenes_candidatas_mass.csv');
const seedPath = path.join(
  ROOT,
  '../../supabase/scripts/seed_100_products_with_images.sql',
);

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

const lines = fs.readFileSync(csvPath, 'utf8').replace(/^\uFEFF/, '').trim().split(/\r?\n/);
const headers = splitCsvLine(lines[0]);
const skuIdx = headers.indexOf('sku');
const imgIdx = headers.indexOf('image_url');
const approvedIdx = headers.indexOf('approved');
const map = new Map();
for (const line of lines.slice(1)) {
  const cells = splitCsvLine(line);
  if (String(cells[approvedIdx] || '').toUpperCase() !== 'YES') continue;
  const sku = cells[skuIdx];
  const image = cells[imgIdx];
  if (sku && image?.startsWith('https://')) map.set(sku, image);
}

let seed = fs.readFileSync(seedPath, 'utf8');
let updated = 0;
for (const [sku, image] of map) {
  const re = new RegExp(
    `(\\('${sku.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}',[\\s\\S]*?, true, )'[^']*'(\\))`,
  );
  const next = seed.replace(re, `$1'${image.replace(/'/g, "''")}'$2`);
  if (next !== seed) {
    seed = next;
    updated += 1;
  }
}
fs.writeFileSync(seedPath, seed, 'utf8');
console.log(`seed actualizado: ${updated}/${map.size}`);
