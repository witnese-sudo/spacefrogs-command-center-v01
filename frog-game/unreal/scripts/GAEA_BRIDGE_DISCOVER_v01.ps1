param(
    [string[]]$Roots = @(
        "$env:USERPROFILE\Documents",
        "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\Downloads"
    ),
    [string]$ProjectPath = "$env:USERPROFILE\Documents\Unreal Projects\SF_GenesisSwamp 5.8\SF_GenesisSwamp.uproject"
)

$ErrorActionPreference = "Stop"

Write-Host "[GAEA-BRIDGE] Searching for recent GAEA export candidates..."

$extensions = @("*.r16","*.raw","*.png","*.tif","*.tiff","*.exr")
$candidates = @()

foreach ($root in $Roots) {
    if (-not (Test-Path $root)) { continue }

    foreach ($pattern in $extensions) {
        $candidates += Get-ChildItem $root -Recurse -File -Filter $pattern -ErrorAction SilentlyContinue |
            Where-Object {
                $_.FullName -match "gaea|height|terrain|swamp|genesis|mask|slope|flow|erosion"
            }
    }
}

$candidates = $candidates |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 50

if (-not $candidates -or $candidates.Count -eq 0) {
    Write-Host "[GAEA-BRIDGE] BLOCKED: No likely GAEA export files found."
    exit 2
}

Write-Host ""
Write-Host "[GAEA-BRIDGE] Recent candidates:"
$candidates | Select-Object LastWriteTime, Length, FullName | Format-Table -AutoSize

if (-not (Test-Path $ProjectPath)) {
    Write-Host "[GAEA-BRIDGE] BLOCKED: Unreal project not found:"
    Write-Host "  $ProjectPath"
    exit 3
}

$projectDir = Split-Path $ProjectPath -Parent
$stagingDir = Join-Path $projectDir "GaeaBridge\Incoming"
New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null

$manifest = [ordered]@{
    version = "0.1"
    truth_state = "GENERATED"
    project_path = $ProjectPath
    staging_dir = $stagingDir
    discovered_at = (Get-Date).ToString("o")
    candidates = @(
        $candidates | ForEach-Object {
            [ordered]@{
                full_name = $_.FullName
                file_name = $_.Name
                extension = $_.Extension
                bytes = $_.Length
                modified = $_.LastWriteTime.ToString("o")
            }
        }
    )
}

$manifestPath = Join-Path $stagingDir "gaea_bridge_discovery.generated.json"
$manifest | ConvertTo-Json -Depth 5 | Set-Content $manifestPath -Encoding UTF8

Write-Host ""
Write-Host "[GAEA-BRIDGE] Discovery manifest written:"
Write-Host "  $manifestPath"
Write-Host "[GAEA-BRIDGE] No Unreal landscape was modified."
