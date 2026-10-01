@echo off
setlocal
title SPACEFROGS Genesis Runtime Discovery
echo.
echo ==========================================
echo   SPACEFROGS - GENESIS RUNTIME DISCOVERY
echo ==========================================
echo.

set "SCRIPT=%~dp0GENESIS_DISCOVER_RUNTIME_v01.ps1"

if not exist "%SCRIPT%" (
  echo [GENESIS] ERROR: Could not find:
  echo %SCRIPT%
  echo.
  pause
  exit /b 1
)

echo [GENESIS] Running safe Unreal project discovery...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
set "RC=%ERRORLEVEL%"

echo.
if "%RC%"=="0" (
  echo [GENESIS] Discovery completed.
  echo [GENESIS] Look for genesis_runtime_bridge.generated.json beside the selected .uproject.
) else (
  echo [GENESIS] Discovery stopped with code %RC%.
  echo [GENESIS] No project was changed.
)

echo.
pause
exit /b %RC%
