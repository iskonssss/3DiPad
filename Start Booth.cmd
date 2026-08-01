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

rem A cloud-synced folder is a bad place to RUN from: the sync client copies
rem node_modules and .git file by file and locks them mid-write. Drive's
rem "Other computers" area is a read-only backup of a different machine, where
rem npm and git fail outright. Say so before anything confusing happens.
echo %CD% | findstr /I /C:"\Other computers\" >nul
if not errorlevel 1 (
  echo.
  echo  ** This folder is Google Drive ^> Other computers. **
  echo  That is a read-only backup of another machine, so the booth cannot run here.
  echo  Copy the project to a local folder, e.g. C:\Users\%USERNAME%\3DiPad, and run it there.
  echo.
  pause
  exit /b 1
)
echo %CD% | findstr /I /R /C:"\\Google Drive\\" /C:"\\My Drive\\" /C:"\\OneDrive" /C:"\\Dropbox\\" >nul
if not errorlevel 1 (
  echo.
  echo  ** Warning: this folder is inside a cloud-synced drive. **
  echo  It syncs every file as it changes, including node_modules and .git, which
  echo  makes the booth slow and can corrupt it mid-fair.
  echo  Better: copy the project to C:\Users\%USERNAME%\3DiPad and set output.dir
  echo  and output.leadsDir in config.json to a folder in your Drive instead.
  echo.
  pause
)

where node >nul 2>nul
if errorlevel 1 (
  echo Node.js is not installed on this laptop.
  echo Install it from https://nodejs.org  ^(the LTS version^), then run this again.
  echo.
  pause
  exit /b 1
)

rem Explorer and cloud-sync clients drop desktop.ini into folders they touch.
rem One inside .git\refs is read as a branch pointer and kills every fetch with
rem "fatal: bad object refs/desktop.ini". Clear them before pulling.
if exist .git (
  del /s /q /f /a .git\desktop.ini >nul 2>nul
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
