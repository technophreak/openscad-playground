# Export one mesh file per Blueprint object under samples/ or designs/.
# Usage:
#   powershell -File scripts/export-meshes.ps1
#   powershell -File scripts/export-meshes.ps1 -Part samples/pen/pen
#   powershell -File scripts/export-meshes.ps1 -Part samples/pen/pen -Object barrel
#   powershell -File scripts/export-meshes.ps1 -Format 3MF
#   powershell -File scripts/export-meshes.ps1 -OpenSCAD "C:/Program Files/OpenSCAD/openscad.exe"

param(
    [string]$Part = "",
    [string]$Object = "",
    [string]$Format = "",
    [string]$OpenSCAD = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

function Find-OpenSCAD {
    param([string]$Preferred)
    if ($Preferred -and (Test-Path $Preferred)) { return $Preferred }
    # Prefer .exe over .com on Windows — the .com shim can crash on heavy models.
    $candidates = @(
        "${env:ProgramFiles}\OpenSCAD (Nightly)\openscad.exe",
        "${env:ProgramFiles}\OpenSCAD\openscad.exe",
        "${env:ProgramFiles(x86)}\OpenSCAD\openscad.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { return $c }
    }
    $cmd = Get-Command openscad -ErrorAction SilentlyContinue
    if ($cmd) {
        $path = $cmd.Source
        if ($path -match '\.com$') {
            $exe = [System.IO.Path]::ChangeExtension($path, ".exe")
            if (Test-Path $exe) { return $exe }
        }
        return $path
    }
    throw "OpenSCAD CLI not found. Pass -OpenSCAD path or install Nightly."
}

function Get-BlueprintObjects {
    param([string]$BlueprintPath)
    if (-not (Test-Path $BlueprintPath)) {
        throw "Missing Blueprint: $BlueprintPath"
    }
    $objects = @()
    Get-Content $BlueprintPath | ForEach-Object {
        if ($_ -match '^###\s+([A-Za-z0-9_]+)\s*$') {
            $objects += $Matches[1]
        }
    }
    if ($objects.Count -eq 0) {
        throw "No ### object headings in $BlueprintPath"
    }
    return $objects
}

function Get-ExportFormat {
    param([string]$ScadPath, [string]$Override)
    if ($Override) {
        $f = $Override.ToUpperInvariant()
        if ($f -ne "STL" -and $f -ne "3MF") { throw "FORMAT must be STL or 3MF" }
        return $f
    }
    $line = Select-String -Path $ScadPath -Pattern '^\s*export_format\s*=\s*"?(STL|3MF)"?' | Select-Object -First 1
    if ($line -and $line.Matches.Groups[1].Value) {
        return $line.Matches.Groups[1].Value.ToUpperInvariant()
    }
    return "STL"
}

function Get-ShowFlags {
    param([string]$ScadPath)
    $flags = @()
    Select-String -Path $ScadPath -Pattern '^\s*(show_[A-Za-z0-9_]+)\s*=' | ForEach-Object {
        $flags += $_.Matches.Groups[1].Value
    }
    return $flags
}

function Export-Design {
    param(
        [string]$ScadRelative,
        [string]$OnlyObject,
        [string]$FormatOverride,
        [string]$Cli
    )

    $scadPath = Join-Path $Root ($ScadRelative + ".scad")
    if (-not (Test-Path $scadPath)) {
        throw "Missing design: $scadPath"
    }
    $designDir = Split-Path $scadPath -Parent
    $designName = [System.IO.Path]::GetFileNameWithoutExtension($scadPath)
    $blueprint = Join-Path $designDir "BLUEPRINT.md"
    $objects = Get-BlueprintObjects $blueprint
    if ($OnlyObject) {
        if ($objects -notcontains $OnlyObject) {
            throw "Object '$OnlyObject' not in $blueprint (have: $($objects -join ', '))"
        }
        $objects = @($OnlyObject)
    }

    $format = Get-ExportFormat -ScadPath $scadPath -Override $FormatOverride
    $ext = $format.ToLowerInvariant()
    $relDir = $ScadRelative -replace '/', '\'
    $outDir = Join-Path $Root (Join-Path "exports" (Split-Path $relDir -Parent))
    if (-not (Test-Path $outDir)) {
        New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    }

    $allShow = Get-ShowFlags $scadPath

    foreach ($obj in $objects) {
        $showName = "show_$obj"
        if ($allShow -notcontains $showName) {
            throw "Blueprint object '$obj' has no $showName in $scadPath"
        }
        $defines = @()
        foreach ($flag in $allShow) {
            $val = if ($flag -eq $showName) { "true" } else { "false" }
            $defines += "-D"
            $defines += "$flag=$val"
        }
        $outFile = Join-Path $outDir "${designName}_${obj}.$ext"
        Write-Host "Rendering $ScadRelative -> $outFile ($showName only)"
        if (Test-Path $outFile) { Remove-Item -Force $outFile }
        # OpenSCAD prints progress on stderr; do not treat that as terminating,
        # and do not pipe its streams (piping can crash heavy CGAL exports on Windows).
        $prevEap = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"
        & $Cli @defines -o $outFile $scadPath | Out-Null
        $code = $LASTEXITCODE
        $ErrorActionPreference = $prevEap
        $okFile = (Test-Path $outFile) -and ((Get-Item $outFile).Length -gt 0)
        # Some Windows OpenSCAD builds leave LASTEXITCODE empty on success.
        if (($null -ne $code -and $code -ne 0) -or -not $okFile) {
            throw "OpenSCAD failed for $outFile (exit $code)"
        }
    }
}

function Get-AllDesigns {
    $list = @()
    foreach ($rootName in @("samples", "designs")) {
        $rootPath = Join-Path $Root $rootName
        if (-not (Test-Path $rootPath)) { continue }
        Get-ChildItem -Path $rootPath -Directory | ForEach-Object {
            Get-ChildItem -Path $_.FullName -Filter "*.scad" -File | ForEach-Object {
                $rel = $_.FullName.Substring($Root.Length + 1) -replace '\\', '/'
                $list += ($rel -replace '\.scad$', '')
            }
        }
    }
    return $list
}

$cli = Find-OpenSCAD -Preferred $OpenSCAD
Write-Host "Using OpenSCAD: $cli"

if ($Part) {
    $partNorm = $Part -replace '\\', '/' -replace '\.scad$', ''
    Export-Design -ScadRelative $partNorm -OnlyObject $Object -FormatOverride $Format -Cli $cli
} else {
    $designs = Get-AllDesigns
    if ($designs.Count -eq 0) {
        Write-Host "No designs found under samples/ or designs/."
        exit 0
    }
    foreach ($d in $designs) {
        Export-Design -ScadRelative $d -OnlyObject $Object -FormatOverride $Format -Cli $cli
    }
}

Write-Host "Done."
