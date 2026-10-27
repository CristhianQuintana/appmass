# Lanza la app siempre con la configuración de Supabase.
Set-Location $PSScriptRoot\..
$device = if ($args.Count -gt 0) { $args[0] } else { 'emulator-5554' }
& D:\Flutter\bin\flutter.bat run -d $device --dart-define-from-file=env/dev.json
