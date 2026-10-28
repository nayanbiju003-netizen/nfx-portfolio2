@echo off
cd /d "%~dp0"
echo ========================================================
echo   NFX Studios - Sync to GitHub (nfx-portfolio2)
echo ========================================================
echo.
"C:\Program Files\Git\cmd\git.exe" status
echo.
echo Staging and committing changes...
"C:\Program Files\Git\cmd\git.exe" add .
set /p commit_msg="Enter commit message (or press ENTER for default): "
if "%commit_msg%"=="" set commit_msg=Update portfolio website
"C:\Program Files\Git\cmd\git.exe" commit -m "%commit_msg%"
echo.
echo Pushing to GitHub repository...
"C:\Program Files\Git\cmd\git.exe" push -u origin main
echo.
echo ========================================================
echo   Finished!
echo ========================================================
pause
