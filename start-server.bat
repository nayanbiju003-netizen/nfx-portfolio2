@echo off
cd /d "%~dp0"
title NFX Portfolio Live Server (Port 5500)
echo ========================================================
echo   NFX Studios - Live Preview Server
echo   http://localhost:5500/
echo ========================================================
echo.
echo Server is running. Keep this window minimized while editing.
echo To stop the server, simply close this window.
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1" -Directory "%~dp0"
pause
