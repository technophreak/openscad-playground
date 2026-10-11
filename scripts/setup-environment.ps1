# Apply OpensCAD workspace tooling: extensions + OpenSCAD Nightly/min version.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

# Development builds use YYYY.MM.DD — minimum for this project.
$MinVersion = [version]"2025.1.1"
$NightlyWingetId = "OpenSCAD.OpenSCAD.Nightly"

function Get-OpenScadVersion([string]$Binary) {
  $out = & $Binary --version 2>&1 | Out-String
  if ($out -match "(\d{4})\.(\d{1,2})\.(\d{1,2})") {
    return [version]::new([int]$Matches[1], [int]$Matches[2], [int]$Matches[3])
  }
  if ($out -match "(?i)version\s+(\d{4})\.(\d{1,2})\b") {
    # e.g. legacy "2021.01"
    return [version]::new([int]$Matches[1], [int]$Matches[2], 0)
  }
  return $null
}

function Find-OpenScadBinary {
  $candidates = @(
    "C:\Program Files\OpenSCAD (Nightly)\openscad.com",
    "C:\Program Files\OpenSCAD (Nightly)\openscad.exe",
    "C:\Program Files\OpenSCAD\openscad.com",
    "C:\Program Files\OpenSCAD\openscad.exe"
  )
  foreach ($c in $candidates) {
    if (Test-Path $c) { return $c }
  }
  $cmd = Get-Command openscad -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  return $null
}

function Build-OpenScadCliShim {
  $cs = Join-Path $root "scripts\openscad-cli.cs"
  $exe = Join-Path $root "scripts\openscad-cli.exe"
  if (-not (Test-Path $cs)) { return $null }
  $csc = Join-Path $env:WINDIR "Microsoft.NET\Framework64\v4.0.30319\csc.exe"
  if (-not (Test-Path $csc)) {
    $csc = Join-Path $env:WINDIR "Microsoft.NET\Framework\v4.0.30319\csc.exe"
  }
  if (-not (Test-Path $csc)) {
    Write-Host "WARN: csc.exe not found; cannot build openscad-cli.exe color shim"
    return $null
  }
  Write-Host "== Building scripts/openscad-cli.exe (3MF color shim for Cursor preview) =="
  & $csc /nologo /optimize+ /out:$exe $cs | Out-Host
  if (-not (Test-Path $exe)) { throw "Failed to build $exe" }
  return $exe
}

function Update-ExecutablePathSetting([string]$Binary) {
  $settingsPath = Join-Path $root ".vscode\settings.json"
  if (-not (Test-Path $settingsPath)) {
    throw "Missing .vscode/settings.json — restore from docs/setup-environment.md"
  }
  $exePath = $Binary
  if ($exePath -like "*.com") {
    $exeSibling = [IO.Path]::ChangeExtension($exePath, ".exe")
    if (Test-Path $exeSibling) { $exePath = $exeSibling }
  }
  # Preview must use an .exe shim (Cursor spawn cannot run .cmd). The shim injects
  # 3MF color flags — plain OpenSCAD basematerial export uses alpha 00 (all one color).
  $shim = Build-OpenScadCliShim
  $previewExe = if ($shim) { $shim } else { $exePath }
  $raw = Get-Content $settingsPath -Raw
  $previewEsc = ($previewExe -replace '\\', '\\')
  if ($raw -match '"openscad\.executablePath"\s*:\s*"[^"]*"') {
    $raw = $raw -replace '"openscad\.executablePath"\s*:\s*"[^"]*"', "`"openscad.executablePath`": `"$previewEsc`""
  } else {
    throw "openscad.executablePath key missing in .vscode/settings.json"
  }
  # 3MF preview keeps Blueprint object colors; STL preview is monochrome.
  if ($raw -match '"openscad\.previewFormat"\s*:\s*"[^"]*"') {
    $raw = $raw -replace '"openscad\.previewFormat"\s*:\s*"[^"]*"', '"openscad.previewFormat": "3mf"'
  } else {
    $raw = $raw -replace '\}\s*$', "  ,`"openscad.previewFormat`": `"3mf`"`r`n}"
  }
  if ($raw -match '"openscad\.enableLazyUnion"\s*:\s*(true|false)') {
    $raw = $raw -replace '"openscad\.enableLazyUnion"\s*:\s*(true|false)', '"openscad.enableLazyUnion": true'
  } elseif ($raw -match '\}\s*$') {
    $raw = $raw -replace '\}\s*$', "  ,`"openscad.enableLazyUnion`": true`r`n}"
  }
  Set-Content -Path $settingsPath -Value $raw -Encoding utf8
  Write-Host "Updated openscad.executablePath -> $previewExe"
  Write-Host "Real OpenSCAD binary: $exePath"
  Write-Host "Set openscad.previewFormat -> 3mf + enableLazyUnion (required for object colors)"
}

$extensions = @(
  "thijsdaniels.vscode-openscad-preview",
  "leathong.openscad-language-support",
  "AssetToolLabs.mesh-viewer-vscode"
)

Write-Host "== Installing Cursor extensions =="
foreach ($ext in $extensions) {
  Write-Host "  $ext"
  & cursor --install-extension $ext | Out-Host
}

Write-Host "== Checking OpenSCAD CLI (minimum $MinVersion) =="
$found = Find-OpenScadBinary
$ver = $null
if ($found) {
  $ver = Get-OpenScadVersion $found
  Write-Host "Found: $found"
  Write-Host "Version: $ver"
}

$needsInstall = (-not $found) -or (-not $ver) -or ($ver -lt $MinVersion)
if ($needsInstall) {
  if (-not $found) {
    Write-Host "OpenSCAD not installed — installing Nightly (required for new installs)."
  } else {
    Write-Host "OpenSCAD $ver is below minimum $MinVersion — installing Nightly."
  }

  $winget = Get-Command winget -ErrorAction SilentlyContinue
  if (-not $winget) {
    Write-Host "winget not available. Install OpenSCAD Nightly from:"
    Write-Host "  https://openscad.org/downloads.html#snapshots"
    exit 1
  }

  & winget install --id $NightlyWingetId --accept-package-agreements --accept-source-agreements | Out-Host
  $found = Find-OpenScadBinary
  if (-not $found) {
    Write-Host "Nightly install finished but binary not found. Check Program Files\\OpenSCAD*."
    exit 1
  }
  $ver = Get-OpenScadVersion $found
  Write-Host "Using: $found ($ver)"
  if (-not $ver -or $ver -lt $MinVersion) {
    Write-Host "ERROR: installed OpenSCAD still below minimum $MinVersion"
    exit 1
  }
} else {
  Write-Host "Existing OpenSCAD meets minimum — keeping $found ($ver)"
}

& $found --version 2>&1 | Out-Host
Update-ExecutablePathSetting $found

Write-Host "Done. Reload Cursor window, open a .scad file, use Ctrl+Shift+V for preview."
