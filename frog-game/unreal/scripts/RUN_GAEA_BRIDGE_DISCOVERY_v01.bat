@echo off
setlocal
cd /d "%~dp0"

echo [GAEA-BRIDGE] Running safe GAEA export discovery...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0GAEA_BRIDGE_DISCOVER_v01.ps1"

echo.
echo [GAEA-BRIDGE] Finished.
pause
