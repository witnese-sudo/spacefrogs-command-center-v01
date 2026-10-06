[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateSet("Install", "Remove")][string]$Action = "Install",
    [string]$EditorPath
)

$ErrorActionPreference = "Stop"
$linkPath = Join-Path ([Environment]::GetFolderPath("Startup")) "SpaceFrogs Genesis v01.lnk"
$owner = "SpaceFrogs Genesis autostart v0.1 (GENERATED)"
$shell = New-Object -ComObject WScript.Shell
if (Test-Path -LiteralPath $linkPath) {
    $existing = $shell.CreateShortcut($linkPath)
    if ($existing.Description -ne $owner) { throw "BLOCKED: Startup shortcut is not owned by this installer." }
}
if ($Action -eq "Remove") {
    if ((Test-Path -LiteralPath $linkPath) -and $PSCmdlet.ShouldProcess($linkPath, "Remove Genesis startup hook")) {
        Remove-Item -LiteralPath $linkPath
    }
    return
}
if (-not $EditorPath -or -not [IO.Path]::IsPathRooted($EditorPath) -or
    -not (Test-Path -LiteralPath $EditorPath -PathType Leaf) -or
    [IO.Path]::GetFileName($EditorPath) -ne "UnrealEditor.exe") {
    throw "BLOCKED: Supply the absolute path to the intended UnrealEditor.exe. No engine guessing."
}
$runner = Join-Path $PSScriptRoot "GENESIS_AUTOSTART_v01.ps1"
$discovery = Join-Path $PSScriptRoot "GENESIS_DISCOVER_RUNTIME_v01.ps1"
if (-not (Test-Path -LiteralPath $runner) -or -not (Test-Path -LiteralPath $discovery)) {
    throw "BLOCKED: Runtime scripts are missing."
}
if ($PSCmdlet.ShouldProcess($linkPath, "Install current-user Genesis hook at login")) {
    $link = $shell.CreateShortcut($linkPath)
    $link.TargetPath = Join-Path $env:SystemRoot "System32\WindowsPowerShell\v1.0\powershell.exe"
    $link.Arguments = '-NoProfile -NonInteractive -File "' + $runner + '" -EditorPath "' + $EditorPath + '"'
    $link.WorkingDirectory = $PSScriptRoot
    $link.Description = $owner
    $link.Save()
    Write-Host "[GENESIS] Installed at login: $linkPath"
    Write-Host "[GENESIS] GENERATED / NOT YET LOCAL-RUNTIME-VERIFIED"
}
