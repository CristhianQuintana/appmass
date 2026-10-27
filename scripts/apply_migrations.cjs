/**
 * Aplica las migraciones versionadas al Postgres remoto.
 *
 * Uso:
 *   $env:SUPABASE_DB_PASSWORD = '<password del panel Database Settings>'
 *   node scripts/apply_migrations.cjs
 */
const fs = require('fs');
const path = require('path');
const pg = require('pg');

const root = path.resolve(__dirname, '..');
const migrationsDir = path.join(root, 'supabase', 'migrations');
const files = [
  '20261014120000_profiles.sql',
  '20261014200000_operations.sql',
  '20261014201000_sample_products.sql',
  '20261022120000_customer_cart.sql',
];

function readPasswordFile() {
  const file = path.join(root, 'env', 'db.password');
  if (!fs.existsSync(file)) return '';
  return fs
    .readFileSync(file, 'utf8')
    .split(/\r?\n/)
    .map((line) => line.trim())
    .find((line) => line && !line.startsWith('#') && !line.includes('YOUR_')) || '';
}

function connectionString() {
  if (process.env.DATABASE_URL) return process.env.DATABASE_URL;
  const password = process.env.SUPABASE_DB_PASSWORD || readPasswordFile();
  const ref = process.env.SUPABASE_PROJECT_REF || 'kwygymkrlwthddjijdyr';
  const region = process.env.SUPABASE_REGION || 'us-east-1';
  if (!password) {
    throw new Error(
      'Define SUPABASE_DB_PASSWORD, env/db.password o DATABASE_URL. La contraseña está en Project Settings → Database (no es sb_secret_).',
    );
  }
  const encoded = encodeURIComponent(password);
  return `postgresql://postgres.${ref}:${encoded}@aws-0-${region}.pooler.supabase.com:6543/postgres`;
}

async function main() {
  const client = new pg.Client({
    connectionString: connectionString(),
    ssl: { rejectUnauthorized: false },
  });
  await client.connect();
  await client.query(`
    create table if not exists public.schema_migrations (
      version text primary key,
      applied_at timestamptz not null default timezone('utc', now())
    );
  `);

  for (const file of files) {
    const version = file.replace(/\.sql$/, '');
    const already = await client.query(
      'select 1 from public.schema_migrations where version = $1',
      [version],
    );
    if (already.rowCount > 0) {
      console.log(`omitida ${file}`);
      continue;
    }
    const sql = fs.readFileSync(path.join(migrationsDir, file), 'utf8');
    console.log(`aplicando ${file}...`);
    try {
      await client.query('begin');
      await client.query(sql);
      await client.query(
        'insert into public.schema_migrations(version) values ($1)',
        [version],
      );
      await client.query('commit');
      console.log(`ok ${file}`);
    } catch (error) {
      await client.query('rollback');
      throw error;
    }
  }

  await client.end();
  console.log('Migraciones aplicadas.');
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
