$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$out = Join-Path $root 'supabase\remote_bootstrap.sql'
$files = @(
  '20261014120000_profiles.sql',
  '20261014200000_operations.sql',
  '20261014201000_sample_products.sql',
  '20261022120000_customer_cart.sql'
) | ForEach-Object { Join-Path $root "supabase\migrations\$_" }

$parts = foreach ($file in $files) {
  "-- >>> $(Split-Path $file -Leaf)"
  Get-Content -Raw -Path $file
  ""
}
Set-Content -Path $out -Value ($parts -join "`n") -Encoding utf8
Write-Host "Generado: $out"
