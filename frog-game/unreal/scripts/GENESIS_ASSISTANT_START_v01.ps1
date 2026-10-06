param([Parameter(Mandatory = $true)][string]$AssistantRoot)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $AssistantRoot).ProviderPath.TrimEnd('\')
foreach ($relative in @('package.json', 'scripts\with-app-env.mjs', 'src\field\luxaLive.ts', 'node_modules\vite\bin\vite.js')) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $relative) -PathType Leaf)) {
        throw "BLOCKED: Assistant prerequisite missing: $relative"
    }
}
$package = Get-Content -LiteralPath (Join-Path $root 'package.json') -Raw | ConvertFrom-Json
if ($package.scripts.dev -ne 'node scripts/with-app-env.mjs vite dev --host 0.0.0.0 --port 8080') {
    throw 'BLOCKED: Assistant dev command changed; review required.'
}
function Get-OwnedListener {
    $listeners = @(Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue)
    foreach ($listener in $listeners) {
        $process = Get-CimInstance Win32_Process -Filter ("ProcessId=" + $listener.OwningProcess)
        # Normalize repeated separators in legacy command lines, without shell evaluation.
        $command = ($process.CommandLine -replace '\\+', '\')
        if ($process.Name -ne 'node.exe' -or
            $command.IndexOf((Join-Path $root 'node_modules\vite\bin\vite.js'), [StringComparison]::OrdinalIgnoreCase) -lt 0) {
            throw 'BLOCKED: Port 8080 belongs to another or unidentified process.'
        }
    }
    return ($listeners.Count -gt 0)
}
if (-not (Get-OwnedListener)) {
    $npm = (Get-Command npm.cmd -ErrorAction Stop).Source
    $logs = Join-Path $env:LOCALAPPDATA 'SpaceFrogs\GenesisAutostart'
    New-Item -ItemType Directory -Path $logs -Force | Out-Null
    $run = [guid]::NewGuid().ToString()
    Start-Process -FilePath $env:ComSpec -ArgumentList ('/d /s /c ""' + $npm + '" run dev"') -WorkingDirectory $root -WindowStyle Hidden -RedirectStandardOutput (Join-Path $logs "assistant-$run.out.log") -RedirectStandardError (Join-Path $logs "assistant-$run.err.log") | Out-Null
    Write-Host '[GENESIS] Assistant server start requested using npm run dev.'
}
$ready = $false
for ($i = 0; $i -lt 30; $i++) {
    if (Get-OwnedListener) {
        try {
            $response = Invoke-WebRequest 'http://127.0.0.1:8080/' -UseBasicParsing -TimeoutSec 2
            if ($response.StatusCode -eq 200 -and $response.Content -match '<title>SPACEFROGS: FIRST SIGNAL</title>') {
                $ready = $true
                break
            }
        } catch { Write-Host '[GENESIS] Waiting for assistant page.' }
    }
    Start-Sleep -Milliseconds 500
}
if (-not $ready) { throw 'BLOCKED: Assistant page did not become ready; see assistant logs.' }
Start-Process 'http://127.0.0.1:8080/' | Out-Null
Write-Host '[GENESIS] Assistant page opened. Conversation/audio and login proof remain separate.'
