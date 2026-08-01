@echo off
rem ===================================================================
rem  3DiPad booth — double-click this to run the booth.
rem  Updates to the latest version, then starts the server and opens
rem  the dashboard. No PowerShell, no typing.
rem  Leave this window open while the booth is running; closing it
rem  stops the server.
rem ===================================================================
title 3DiPad Booth
cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
  echo Node.js is not installed on this laptop.
  echo Install it from https://nodejs.org  ^(the LTS version^), then run this again.
  echo.
  pause
  exit /b 1
)

echo Updating to the latest version...
git pull origin main 2>nul
if errorlevel 1 echo   ^(no update — carrying on with the version already here^)

if not exist node_modules (
  echo Installing what the booth needs. This happens once and takes a minute...
  call npm install --no-audit --no-fund
  if errorlevel 1 goto failed
)

echo Building the tablet app...
call npm run build
if errorlevel 1 goto failed

echo.
echo Opening the dashboard in your browser...
start "" http://localhost:3000/dashboard/
echo.
echo ===================================================================
echo  Leave this window open. Close it to stop the booth.
echo  The address the iPads should open is printed just below.
echo ===================================================================
echo.
call npm start
goto :eof

:failed
echo.
echo Something went wrong above. Take a photo of this window.
echo.
pause
