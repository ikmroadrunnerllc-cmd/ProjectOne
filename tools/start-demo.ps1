param(
    [string]$Device,
    [switch]$Fresh,
    [switch]$BuildApk
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
$flutterPath = if ($flutterCommand) { $flutterCommand.Source } else {
    Join-Path $env:USERPROFILE 'flutter\bin\flutter.bat'
}
if (-not (Test-Path -LiteralPath $flutterPath)) {
    throw 'Flutter was not found. Add flutter/bin to PATH and try again.'
}
$flutterArguments = @(if ($BuildApk) { 'build', 'apk', '--debug' } else { 'run' })
$flutterArguments += '--dart-define=DEMO_MODE=true'
if ($Fresh) {
    $token = [Guid]::NewGuid().ToString('N')
    $flutterArguments += "--dart-define=DEMO_RESET=$token"
    Write-Host 'Starting a fresh demo take. Normal app data is preserved.'
} else {
    Write-Host 'Opening the existing demo take. Use -Fresh to reset demo records and settings.'
}
if ($Device -and -not $BuildApk) { $flutterArguments += @('-d', $Device) }
Push-Location $projectRoot
try {
    & $flutterPath @flutterArguments
    if ($LASTEXITCODE -ne 0) { throw "Flutter exited with code $LASTEXITCODE" }
} finally {
    Pop-Location
}
