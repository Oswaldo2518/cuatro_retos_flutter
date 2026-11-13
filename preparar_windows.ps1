# Genera los archivos de plataforma que Flutter necesita y configura Internet en Android.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw 'No se encontró Flutter. Instala Flutter, agrégalo al PATH y abre otra terminal.'
}

Write-Host 'Creando archivos nativos de Flutter...' -ForegroundColor Cyan
flutter create . --project-name cuatro_retos_flutter --platforms android,web,windows
if ($LASTEXITCODE -ne 0) { throw 'No se pudo generar el proyecto Flutter.' }

$manifestPath = Join-Path $PSScriptRoot 'android\app\src\main\AndroidManifest.xml'
if (Test-Path $manifestPath) {
  $contents = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8
  if ($contents -notmatch 'android\.permission\.INTERNET') {
    $match = [regex]::Match($contents, '<manifest\b[^>]*>')
    if (-not $match.Success) { throw 'No se pudo leer AndroidManifest.xml.' }
    $permission = "`r`n    <uses-permission android:name=`"android.permission.INTERNET`" />"
    $contents = $contents.Insert($match.Index + $match.Length, $permission)
    Set-Content -LiteralPath $manifestPath -Value $contents -Encoding UTF8
  }
}

Write-Host 'Descargando dependencias...' -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'Falló flutter pub get.' }
Write-Host 'Proyecto preparado. Ejecuta: flutter devices; flutter run' -ForegroundColor Green
