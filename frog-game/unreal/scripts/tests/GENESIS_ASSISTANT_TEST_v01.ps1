$ErrorActionPreference = 'Stop'
$temp = Join-Path ([IO.Path]::GetTempPath()) ('genesis-assistant-test-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $temp | Out-Null
try {
    foreach ($relative in @('scripts\with-app-env.mjs','src\field\luxaLive.ts','node_modules\vite\bin\vite.js')) {
        $file = Join-Path $temp $relative
        New-Item -ItemType Directory -Path (Split-Path $file -Parent) -Force | Out-Null
        Set-Content -LiteralPath $file -Value 'fixture'
    }
    $packageFile = Join-Path $temp 'package.json'
    @{scripts=@{dev='node scripts/with-app-env.mjs vite dev --host 0.0.0.0 --port 8080'}} | ConvertTo-Json | Set-Content -LiteralPath $packageFile
    $global:GenesisAssistantTestCommand = 'node "' + (Join-Path $temp 'node_modules\vite\bin\vite.js') + '"'
    $global:GenesisAssistantTestOpened = 0
    function Get-NetTCPConnection { [pscustomobject]@{OwningProcess=123} }
    function Get-CimInstance { [pscustomobject]@{Name='node.exe'; CommandLine=$global:GenesisAssistantTestCommand} }
    function Invoke-WebRequest { [pscustomobject]@{StatusCode=200;Content='<title>SPACEFROGS: FIRST SIGNAL</title>'} }
    function Start-Process { $global:GenesisAssistantTestOpened++ }
    $scriptPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'GENESIS_ASSISTANT_START_v01.ps1'
    & $scriptPath -AssistantRoot $temp
    if ($global:GenesisAssistantTestOpened -ne 1) { throw 'Owned ready assistant must open once' }
    $global:GenesisAssistantTestCommand = 'node C:\foreign\node_modules\vite\bin\vite.js'
    $blocked = $false
    try { & $scriptPath -AssistantRoot $temp } catch { $blocked = $true }
    if (-not $blocked -or $global:GenesisAssistantTestOpened -ne 1) { throw 'Foreign port owner must block' }
    @{scripts=@{dev='changed command'}} | ConvertTo-Json | Set-Content -LiteralPath $packageFile
    $blocked = $false
    try { & $scriptPath -AssistantRoot $temp } catch { $blocked = $true }
    if (-not $blocked -or $global:GenesisAssistantTestOpened -ne 1) { throw 'Changed command must block' }
    Write-Host 'PASS: assistant ready/owned, foreign listener and changed command scenarios. Browser launch intercepted.'
} finally {
    Remove-Item Function:Get-NetTCPConnection,Function:Get-CimInstance,Function:Invoke-WebRequest,Function:Start-Process -ErrorAction SilentlyContinue
    Remove-Variable GenesisAssistantTestCommand,GenesisAssistantTestOpened -Scope Global -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $temp -Recurse -Force
}
exit 0
