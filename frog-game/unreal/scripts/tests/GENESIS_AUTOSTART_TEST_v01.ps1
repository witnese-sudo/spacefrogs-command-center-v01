$ErrorActionPreference = "Stop"
$scripts = Split-Path $PSScriptRoot -Parent
$hostExe = Join-Path $PSHOME "powershell.exe"
if (-not (Test-Path -LiteralPath $hostExe)) { $hostExe = Join-Path $PSHOME "pwsh" }
$temp = Join-Path ([IO.Path]::GetTempPath()) ("genesis-tests-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $temp | Out-Null
$passed = 0
function Assert($condition, $message) {
    if (-not $condition) { throw $message }
}
function Test-Discovery($name, $paths, $expectedCode, $expectedPath) {
    $root = Join-Path $temp $name
    New-Item -ItemType Directory -Path $root | Out-Null
    foreach ($path in $paths) {
        $file = Join-Path $root $path
        New-Item -ItemType Directory -Path (Split-Path $file -Parent) -Force | Out-Null
        Set-Content -LiteralPath $file -Value '{}'
    }
    $result = Join-Path $root "result.json"
    & $hostExe -NoProfile -File (Join-Path $scripts "GENESIS_DISCOVER_RUNTIME_v01.ps1") -Roots $root -ResultPath $result
    Assert ($LASTEXITCODE -eq $expectedCode) "$name exit code"
    if ($expectedCode -eq 0) {
        $data = Get-Content -LiteralPath $result -Raw | ConvertFrom-Json
        Assert ($data.unreal.project_path -eq (Join-Path $root $expectedPath)) "$name selected path"
        Assert ($data.truth_state -eq "GENERATED") "$name truth state"
    } else {
        Assert (-not (Test-Path -LiteralPath $result)) "$name must not publish result"
        Assert (@(Get-ChildItem -LiteralPath $root -Recurse -Filter genesis_runtime_bridge.generated.json).Count -eq 0) "$name must not write manifest"
    }
    $script:passed++
}
try {
    foreach ($file in Get-ChildItem -LiteralPath $scripts -Filter '*GENESIS*.ps1') {
        $tokens = $null; $errors = $null
        [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors) | Out-Null
        Assert ($errors.Count -eq 0) "Parse failure: $($file.Name)"
    }
    Test-Discovery "zero" @() 2 $null
    Test-Discovery "single preferred with spaces" @('folder space/FROG3D_v01.uproject') 0 'folder space/FROG3D_v01.uproject'
    Test-Discovery "single fallback" @('Other.uproject') 0 'Other.uproject'
    Test-Discovery "preferred among others" @('a/FROG3D_v01.uproject', 'b/Other.uproject') 0 'a/FROG3D_v01.uproject'
    Test-Discovery "duplicate preferred" @('a/FROG3D_v01.uproject', 'b/FROG3D_v01.uproject') 3 $null
    Test-Discovery "ambiguous" @('a/One.uproject', 'b/Two.uproject') 4 $null
    # Windows runner tests intercept launch; no real Unreal executable is run.
    if ($env:OS -eq 'Windows_NT') {
        $oldProfile = $env:USERPROFILE; $oldLocal = $env:LOCALAPPDATA
        try {
            $env:USERPROFILE = Join-Path $temp 'runner-profile'
            $env:LOCALAPPDATA = Join-Path $temp 'runner-logs'
            $docs = Join-Path $env:USERPROFILE 'Documents'
            New-Item -ItemType Directory -Path $docs -Force | Out-Null
            $editor = Join-Path $temp 'UnrealEditor.exe'
            Set-Content -LiteralPath $editor -Value 'fixture, never executed'
            $global:GenesisTestLaunches = @(); $global:GenesisTestRunning = $false
            function Get-Process { if ($global:GenesisTestRunning) { [pscustomobject]@{ Name = 'UnrealEditor' } } }
            function Start-Process {
                param($FilePath, $ArgumentList, $WorkingDirectory)
                $global:GenesisTestLaunches += [pscustomobject]@{ Editor = $FilePath; Args = $ArgumentList; Dir = $WorkingDirectory }
            }
            $runner = Join-Path $scripts 'GENESIS_AUTOSTART_v01.ps1'
            & $runner -EditorPath $editor
            Assert ($LASTEXITCODE -eq 2 -and $global:GenesisTestLaunches.Count -eq 0) 'Runner empty must not launch'
            $project = Join-Path $docs 'FROG3D_v01.uproject'
            Set-Content -LiteralPath $project -Value '{}'
            & $runner -EditorPath $editor
            Assert ($LASTEXITCODE -eq 0 -and $global:GenesisTestLaunches.Count -eq 1) 'Runner success'
            Assert ($global:GenesisTestLaunches[0].Args -eq ('"' + $project + '"')) 'Runner exact quoted project'
            $global:GenesisTestRunning = $true
            & $runner -EditorPath $editor
            Assert ($LASTEXITCODE -eq 1 -and $global:GenesisTestLaunches.Count -eq 1) 'Running editor must block'
            $global:GenesisTestRunning = $false
            & $runner -EditorPath (Join-Path $temp 'missing.exe')
            Assert ($LASTEXITCODE -eq 1 -and $global:GenesisTestLaunches.Count -eq 1) 'Missing editor must block'
            $duplicate = Join-Path $docs 'duplicate'
            New-Item -ItemType Directory -Path $duplicate | Out-Null
            Set-Content -LiteralPath (Join-Path $duplicate 'FROG3D_v01.uproject') -Value '{}'
            & $runner -EditorPath $editor
            Assert ($LASTEXITCODE -eq 3 -and $global:GenesisTestLaunches.Count -eq 1) 'Stale success must not bypass duplicate block'
            Remove-Item -LiteralPath $project
            Remove-Item -LiteralPath $duplicate -Recurse
            Set-Content -LiteralPath (Join-Path $docs 'One.uproject') -Value '{}'
            Set-Content -LiteralPath (Join-Path $docs 'Two.uproject') -Value '{}'
            & $runner -EditorPath $editor
            Assert ($LASTEXITCODE -eq 4 -and $global:GenesisTestLaunches.Count -eq 1) 'Ambiguous runner must not launch'
            Write-Host 'PASS: 6 Windows runner scenarios with intercepted launch (not runtime proof).'
        } finally {
            $env:USERPROFILE = $oldProfile; $env:LOCALAPPDATA = $oldLocal
            Remove-Item Function:Get-Process, Function:Start-Process -ErrorAction SilentlyContinue
            Remove-Variable GenesisTestLaunches, GenesisTestRunning -Scope Global -ErrorAction SilentlyContinue
        }
    } else {
        Write-Host 'SKIPPED: Windows-only runner launch interception checks.'
    }
    Write-Host "PASS: syntax and $passed discovery scenarios. No local Windows/Unreal runtime proof claimed."
} finally {
    Remove-Item -LiteralPath $temp -Recurse -Force
}

# Expected negative cases must not leak their exit code to the CI host.
exit 0
