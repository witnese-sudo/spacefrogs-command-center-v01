param(
    [string]$PackageDir = "$env:USERPROFILE\Documents\Unreal Projects\SF_GenesisSwamp 5.8\GaeaBridge\Incoming\GEN_SWAMP_P0_004"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $PackageDir)) {
    Write-Host "[GAEA-BRIDGE] BLOCKED: Package directory not found:"
    Write-Host "  $PackageDir"
    exit 2
}

$manifestPath = Join-Path $PackageDir "gaea_terrain_package.generated.json"
if (-not (Test-Path $manifestPath)) {
    Write-Host "[GAEA-BRIDGE] BLOCKED: Manifest missing:"
    Write-Host "  $manifestPath"
    exit 3
}

Write-Host "[GAEA-BRIDGE] Verifying staged package..."
Write-Host "  $PackageDir"

$files = Get-ChildItem $PackageDir -File |
    Where-Object { $_.Extension -match "^\.(png|r16|raw|tif|tiff|exr)$" }

if (-not $files -or $files.Count -eq 0) {
    Write-Host "[GAEA-BRIDGE] BLOCKED: No supported terrain files found in staged package."
    exit 4
}

$result = @()

foreach ($file in $files) {
    $hash = (Get-FileHash $file.FullName -Algorithm SHA256).Hash
    $role = "UNKNOWN"

    if ($file.Name -match "(?i)out|height|terrain|elevation") {
        $role = "HEIGHT_CANDIDATE"
    }
    elseif ($file.Name -match "(?i)flow") {
        $role = "FLOW_MASK"
    }
    elseif ($file.Name -match "(?i)wear") {
        $role = "WEAR_MASK"
    }
    elseif ($file.Name -match "(?i)deposit") {
        $role = "DEPOSIT_MASK"
    }

    $result += [pscustomobject]@{
        Role = $role
        Name = $file.Name
        Bytes = $file.Length
        SHA256 = $hash
    }
}

$result | Sort-Object Role, Name | Format-Table -AutoSize

$heightCandidates = @($result | Where-Object { $_.Role -eq "HEIGHT_CANDIDATE" })

Write-Host ""
if ($heightCandidates.Count -eq 1) {
    Write-Host "[GAEA-BRIDGE] Single height candidate:"
    Write-Host "  $($heightCandidates[0].Name)"
}
elseif ($heightCandidates.Count -gt 1) {
    Write-Host "[GAEA-BRIDGE] REVIEW REQUIRED: Multiple height candidates:"
    $heightCandidates | Select-Object Name, Bytes | Format-Table -AutoSize
}
else {
    Write-Host "[GAEA-BRIDGE] REVIEW REQUIRED: No height candidate identified by filename."
}

Write-Host ""
Write-Host "[GAEA-BRIDGE] Package verification complete."
Write-Host "[GAEA-BRIDGE] Truth state: TESTED / HUMAN HEIGHTMAP CONFIRMATION REQUIRED"
Write-Host "[GAEA-BRIDGE] No Unreal landscape was modified."
