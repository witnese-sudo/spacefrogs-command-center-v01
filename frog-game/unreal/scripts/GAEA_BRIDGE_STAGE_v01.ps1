param(
    [Parameter(Mandatory=$true)]
    [string]$SourceFolder,

    [string]$ProjectPath = "$env:USERPROFILE\Documents\Unreal Projects\SF_GenesisSwamp 5.8\SF_GenesisSwamp.uproject",

    [string]$PackageId = "GENESIS_SWAMP_v01"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $SourceFolder)) {
    Write-Host "[GAEA-BRIDGE] BLOCKED: Source folder not found: $SourceFolder"
    exit 2
}

if (-not (Test-Path $ProjectPath)) {
    Write-Host "[GAEA-BRIDGE] BLOCKED: Unreal project not found: $ProjectPath"
    exit 3
}

$projectDir = Split-Path $ProjectPath -Parent
$targetDir = Join-Path $projectDir ("GaeaBridge\Incoming\" + $PackageId)
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

$files = Get-ChildItem $SourceFolder -File -ErrorAction Stop |
    Where-Object { $_.Extension -match "^\.(r16|raw|png|tif|tiff|exr)$" }

if (-not $files -or $files.Count -eq 0) {
    Write-Host "[GAEA-BRIDGE] BLOCKED: No supported terrain files in source folder."
    exit 4
}

$staged = @()

foreach ($file in $files) {
    $dest = Join-Path $targetDir $file.Name
    Copy-Item $file.FullName $dest -Force

    $hash = Get-FileHash $dest -Algorithm SHA256
    $staged += [ordered]@{
        file_name = $file.Name
        source = $file.FullName
        staged = $dest
        sha256 = $hash.Hash
        bytes = (Get-Item $dest).Length
    }
}

$manifest = [ordered]@{
    version = "0.1"
    package_id = $PackageId
    truth_state = "GENERATED"
    source_folder = (Resolve-Path $SourceFolder).Path
    project_path = $ProjectPath
    staged_at = (Get-Date).ToString("o")
    files = $staged
}

$manifestPath = Join-Path $targetDir "gaea_terrain_package.generated.json"
$manifest | ConvertTo-Json -Depth 6 | Set-Content $manifestPath -Encoding UTF8

Write-Host "[GAEA-BRIDGE] Package staged:"
Write-Host "  $targetDir"
Write-Host "[GAEA-BRIDGE] Manifest:"
Write-Host "  $manifestPath"
Write-Host "[GAEA-BRIDGE] GENERATED. Unreal landscape has NOT been overwritten."
