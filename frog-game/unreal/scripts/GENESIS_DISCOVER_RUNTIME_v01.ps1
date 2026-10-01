param(
    [string[]]$Roots = @(
        "$env:USERPROFILE\Documents",
        "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\Downloads",
        "C:\Users\Public\Documents"
    ),
    [string]$PreferredProjectName = "FROG3D_v01"
)

$ErrorActionPreference = "Stop"
Write-Host "[GENESIS] Discovering Unreal projects..."

$projects = @()
foreach ($root in $Roots) {
    if (-not (Test-Path $root)) { continue }
    try {
        $found = Get-ChildItem -Path $root -Filter *.uproject -File -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $found) {
            $projects += $file.FullName
        }
    } catch {
        Write-Warning "[GENESIS] Scan warning for $root : $($_.Exception.Message)"
    }
}

$projects = $projects | Sort-Object -Unique
if ($projects.Count -eq 0) {
    Write-Host "[GENESIS] BLOCKED: No .uproject found in approved roots."
    exit 2
}

$preferred = $projects | Where-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) -eq $PreferredProjectName }
if ($preferred.Count -eq 1) {
    $selected = $preferred[0]
} elseif ($preferred.Count -gt 1) {
    Write-Host "[GENESIS] BLOCKED: Multiple $PreferredProjectName projects found:"
    $preferred | ForEach-Object { Write-Host " - $_" }
    exit 3
} elseif ($projects.Count -eq 1) {
    $selected = $projects[0]
} else {
    Write-Host "[GENESIS] BLOCKED: Multiple Unreal projects found. Human selection required:"
    $projects | ForEach-Object { Write-Host " - $_" }
    exit 4
}

$projectDir = Split-Path $selected -Parent
$gitDir = $projectDir
while ($gitDir -and -not (Test-Path (Join-Path $gitDir ".git"))) {
    $parent = Split-Path $gitDir -Parent
    if ($parent -eq $gitDir) { $gitDir = $null; break }
    $gitDir = $parent
}

$gitBranch = $null
$gitDirty = $null
$gitHead = $null
if ($gitDir) {
    Push-Location $gitDir
    try {
        $gitBranch = (git branch --show-current 2>$null).Trim()
        $gitHead = (git rev-parse HEAD 2>$null).Trim()
        $gitDirty = [bool](git status --porcelain 2>$null)
    } finally {
        Pop-Location
    }
}

$result = [ordered]@{
    version = "0.1"
    mode = "TAKE_CONTROL"
    truth_state = "GENERATED"
    unreal = [ordered]@{
        project_path = $selected
        project_name = [System.IO.Path]::GetFileNameWithoutExtension($selected)
        engine_version = "UNRESOLVED"
        active_map = $null
        editor_running = [bool](Get-Process UnrealEditor -ErrorAction SilentlyContinue)
    }
    git = [ordered]@{
        repository = $(if ($gitDir) { $gitDir } else { "" })
        branch = $(if ($gitBranch) { $gitBranch } else { "" })
        dirty = $(if ($null -ne $gitDirty) { $gitDirty } else { $false })
        head_sha = $(if ($gitHead) { $gitHead } else { $null })
    }
    capabilities = @(
        "project_discovery",
        "git_state_read",
        "editor_process_read"
    )
}

$out = Join-Path $projectDir "genesis_runtime_bridge.generated.json"
$result | ConvertTo-Json -Depth 6 | Set-Content -Path $out -Encoding UTF8

Write-Host "[GENESIS] Project resolved:"
Write-Host "  $selected"
Write-Host "[GENESIS] Manifest:"
Write-Host "  $out"
Write-Host "[GENESIS] Truth state: GENERATED (not runtime verified)"
