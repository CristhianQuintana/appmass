# APK de revisión para jefatura: embebida la conexión a Supabase (clave pública).
# Requiere env/dev.json (no se publica en git).
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot\..

$envFile = Join-Path (Get-Location) 'env\dev.json'
if (-not (Test-Path $envFile)) {
  Write-Error "Falta env/dev.json. Cópialo desde env/dev.json.example y completa SUPABASE_URL y SUPABASE_ANON_KEY."
}

$flutter = if (Test-Path 'D:\Flutter\bin\flutter.bat') {
  'D:\Flutter\bin\flutter.bat'
} else {
  'flutter'
}

Write-Host 'Compilando APK de revisión (release + Supabase)...'
& $flutter build apk --release --dart-define-from-file=env/dev.json
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

$built = Join-Path (Get-Location) 'build\app\outputs\flutter-apk\app-release.apk'
if (-not (Test-Path $built)) {
  Write-Error "No se generó $built"
}

$dist = Join-Path (Get-Location) 'dist'
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmm'
$dest = Join-Path $dist "MASS-revision-$stamp.apk"
Copy-Item -Force $built $dest
$stable = Join-Path $dist 'MASS-revision.apk'
Copy-Item -Force $built $stable

Write-Host ''
Write-Host "APK listo para instalar en el teléfono:"
Write-Host "  $stable"
Write-Host "  $dest"
Write-Host ''
Write-Host 'Instalación: copia el APK al dispositivo y ábrelo (permitir orígenes desconocidos).'
Write-Host 'La app conecta a Supabase y muestra el catálogo sin sesión.'
