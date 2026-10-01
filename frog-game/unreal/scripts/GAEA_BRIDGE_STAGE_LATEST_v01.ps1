param(
    [string]$BuildRoot = "$env:USERPROFILE\Documents\Gaea\Builds\GEN_SWAMP_P0",
    [string]$ProjectPath = "$env:USERPROFILE\Documents\Unreal Projects\SF_GenesisSwamp 5.8\SF_GenesisSwamp.uproject"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $BuildRoot)) {
    Write-Host "[GAEA-BRIDGE] BLOCKED: Build root not found:"
    Write-Host "  $BuildRoot"
    exit 2
}

$stageScript = Join-Path $PSScriptRoot "GAEA_BRIDGE_STAGE_v01.ps1"
if (-not (Test-Path $stageScript)) {
    Write-Host "[GAEA-BRIDGE] BLOCKED: Stage script not found:"
    Write-Host "  $stageScript"
    exit 3
}

$supported = "^\.(r16|raw|png|tif|tiff|exr)$"

$candidates = Get-ChildItem $BuildRoot -Directory -ErrorAction Stop |
    ForEach-Object {
        $files = Get-ChildItem $_.FullName -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -match $supported }

        if ($files -and $files.Count -gt 0) {
            [pscustomobject]@{
                Directory = $_
                Files = $files
                NumericName = if ($_.Name -match "^\d+$") { [int]$_.Name } else { -1 }
                LastWriteTime = $_.LastWriteTime
            }
        }
    } |
    Where-Object { $_ -ne $null }

if (-not $candidates -or $candidates.Count -eq 0) {
    Write-Host "[GAEA-BRIDGE] BLOCKED: No build subfolder with supported terrain files was found."
    exit 4
}

$latest = $candidates |
    Sort-Object -Property @{Expression={ if ($_.NumericName -ge 0) { 1 } else { 0 } }; Descending=$true}, @{Expression={$_.NumericName}; Descending=$true}, @{Expression={$_.LastWriteTime}; Descending=$true} |
    Select-Object -First 1

$packageId = "GEN_SWAMP_P0_" + $latest.Directory.Name

Write-Host "[GAEA-BRIDGE] Selected latest build:"
Write-Host "  $($latest.Directory.FullName)"
Write-Host "[GAEA-BRIDGE] Package ID:"
Write-Host "  $packageId"
Write-Host "[GAEA-BRIDGE] Files found:"
$latest.Files | Select-Object Name, Length | Format-Table -AutoSize

& $stageScript -SourceFolder $latest.Directory.FullName -ProjectPath $ProjectPath -PackageId $packageId

exit $LASTEXITCODE
