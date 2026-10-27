const fs = require('fs');
const path = require('path');
const sql = fs.readFileSync(
  path.join(__dirname, '../supabase/scripts/seed_100_products_with_images.sql'),
  'utf8',
);
const expr = `(() => {
  const sql = ${JSON.stringify(sql)};
  const monaco = window.monaco;
  const models = monaco && monaco.editor && monaco.editor.getModels
    ? monaco.editor.getModels()
    : [];
  if (!models.length) {
    return JSON.stringify({
      ok: false,
      reason: 'no-models',
      hasMonaco: !!monaco,
    });
  }
  models[0].setValue(sql);
  return JSON.stringify({ ok: true, len: sql.length });
})()`;
fs.writeFileSync(path.join(__dirname, '_cdp_expr.txt'), expr);
console.log('expr bytes', Buffer.byteLength(expr));
