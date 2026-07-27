@echo off
setlocal
cd /d "%~dp0api"
where node >nul 2>nul
if errorlevel 1 (
  echo Node.js is not installed.
  echo Local and AI matches still work by opening index.html directly.
  echo Install Node.js 18+ to use the online API.
  pause
  exit /b 1
)
start "Yutnori API" cmd /k "npm start"
timeout /t 3 /nobreak >nul
start "" "%~dp0index.html"
endlocal
