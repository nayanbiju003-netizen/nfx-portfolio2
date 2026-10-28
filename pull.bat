@echo off
cd /d "%~dp0"
echo ========================================================
echo   NFX Studios - Pull Latest Changes from GitHub
echo ========================================================
echo.

where git >nul 2>nul
if %errorlevel% equ 0 (
    git pull origin main
) else if exist "D:\GIT\Git\cmd\git.exe" (
    "D:\GIT\Git\cmd\git.exe" pull origin main
) else (
    "C:\Program Files\Git\cmd\git.exe" pull origin main
)

echo.
echo ========================================================
echo   Your local files are now updated!
echo ========================================================
pause
