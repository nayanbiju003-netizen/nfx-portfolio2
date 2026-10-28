@echo off
cd /d "%~dp0"
echo ========================================================
echo   NFX Studios - Pull Latest Changes from GitHub
echo ========================================================
echo.
"C:\Program Files\Git\cmd\git.exe" pull origin main
echo.
echo ========================================================
echo   Your local files are now updated!
echo ========================================================
pause
