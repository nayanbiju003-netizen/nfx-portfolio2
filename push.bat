@echo off
cd /d "%~dp0"
echo ========================================================
echo   NFX Studios - Sync to GitHub (nayanbiju003-netizen)
echo ========================================================
echo.
"C:\Program Files\Git\cmd\git.exe" status
echo.
echo Staging and committing changes...
"C:\Program Files\Git\cmd\git.exe" add .
set /p commit_msg="Enter commit message (or press ENTER for default): "
if "%commit_msg%"=="" set commit_msg=Update website
"C:\Program Files\Git\cmd\git.exe" commit -m "%commit_msg%"
echo.
echo Pushing to GitHub...
"C:\Program Files\Git\cmd\git.exe" push -u origin main
echo.
echo ========================================================
echo   Done! Press any key to exit.
echo ========================================================
pause
