param(
    [Parameter(Mandatory = $true)][string]$EditorPath
)

$ErrorActionPreference = "Stop"
$mutex = New-Object System.Threading.Mutex($false, "Local\SpaceFrogsGenesisAutostartV01")
$locked = $false
$transcribing = $false
$resultPath = $null
$rc = 1
try {
    $locked = $mutex.WaitOne(0)
    if (-not $locked) { exit 5 }
    $logDir = Join-Path $env:LOCALAPPDATA "SpaceFrogs\GenesisAutostart"
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    Start-Transcript -Path (Join-Path $logDir ("startup-" + [guid]::NewGuid() + ".log")) | Out-Null
    $transcribing = $true
    Write-Host "[GENESIS] GENERATED / NOT YET LOCAL-RUNTIME-VERIFIED"
    if (-not (Test-Path -LiteralPath $EditorPath -PathType Leaf) -or
        [IO.Path]::GetFileName($EditorPath) -ne "UnrealEditor.exe") {
        throw "BLOCKED: Explicit UnrealEditor.exe path is missing or invalid."
    }
    if (Get-Process UnrealEditor -ErrorAction SilentlyContinue) {
        throw "BLOCKED: An Unreal editor is already running; no duplicate or project switch."
    }
    $resultPath = Join-Path $logDir ([guid]::NewGuid().ToString() + ".json")
    # Child process preserves discovery's exit 2/3/4 hard stops.
    & (Join-Path $PSHOME "powershell.exe") -NoProfile -NonInteractive -File (Join-Path $PSScriptRoot "GENESIS_DISCOVER_RUNTIME_v01.ps1") -ResultPath $resultPath
    $rc = $LASTEXITCODE
    if ($rc -eq 0) {
        $result = Get-Content -LiteralPath $resultPath -Raw | ConvertFrom-Json
        $project = $result.unreal.project_path
        if (-not $project -or -not (Test-Path -LiteralPath $project -PathType Leaf) -or
            [IO.Path]::GetExtension($project) -ne ".uproject") {
            throw "BLOCKED: Fresh discovery result is invalid."
        }
        Start-Process -FilePath $EditorPath -ArgumentList ('"' + $project + '"') -WorkingDirectory (Split-Path $project -Parent) | Out-Null
        Write-Host "[GENESIS] Launch requested for $project. Runtime proof still pending."
    } else {
        Write-Host "[GENESIS] BLOCKED: Discovery exit $rc. No editor launched."
    }
} catch {
    $rc = 1
    Write-Host "[GENESIS] $($_.Exception.Message)"
} finally {
    if ($resultPath -and (Test-Path -LiteralPath $resultPath)) { Remove-Item -LiteralPath $resultPath }
    if ($transcribing) { Stop-Transcript | Out-Null }
    if ($locked) { $mutex.ReleaseMutex() }
    $mutex.Dispose()
}
exit $rc
