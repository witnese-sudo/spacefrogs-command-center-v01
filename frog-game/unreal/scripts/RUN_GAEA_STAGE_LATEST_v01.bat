@echo off
setlocal
cd /d "%~dp0"

echo [GAEA-BRIDGE] Staging latest GEN_SWAMP_P0 GAEA build safely...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0GAEA_BRIDGE_STAGE_LATEST_v01.ps1"

echo.
echo [GAEA-BRIDGE] Finished.
pause
