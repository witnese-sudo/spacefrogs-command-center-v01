@echo off
setlocal
title SpaceFrogs Master Unreal Installer v05

echo.
echo SPACEFROGS MASTER HANDOFF v05
echo.
echo Example:
echo C:\Users\x\Documents\Unreal Projects\FROG3D_v01
echo.
set /p PROJECT_DIR=Paste Unreal project folder path here: 

if "%PROJECT_DIR%"=="" (
  echo No path entered.
  pause
  exit /b 1
)

if not exist "%PROJECT_DIR%" (
  echo Folder does not exist:
  echo %PROJECT_DIR%
  pause
  exit /b 1
)

if not exist "%PROJECT_DIR%\Content" mkdir "%PROJECT_DIR%\Content"
xcopy /E /I /Y "Content\FROG_GAME" "%PROJECT_DIR%\Content\FROG_GAME"

echo.
echo DONE.
echo Installed to:
echo %PROJECT_DIR%\Content\FROG_GAME
echo.
echo In Unreal: Refresh Content Browser, then open Content/FROG_GAME/Sector7F.
pause
