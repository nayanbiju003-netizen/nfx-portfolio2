@echo off
cd /d "%~dp0"
echo ========================================================
echo   NFX Studios - Sync to GitHub (nfx-portfolio2)
echo ========================================================
echo.

set GIT_CMD=git
where git >nul 2>nul
if %errorlevel% neq 0 (
    if exist "D:\GIT\Git\cmd\git.exe" (
        set GIT_CMD="D:\GIT\Git\cmd\git.exe"
    ) else if exist "C:\Program Files\Git\cmd\git.exe" (
        set GIT_CMD="C:\Program Files\Git\cmd\git.exe"
    )
)

%GIT_CMD% status
echo.
echo Staging and committing changes...
%GIT_CMD% add .
set /p commit_msg="Enter commit message (or press ENTER for default): "
if "%commit_msg%"=="" set commit_msg=Update portfolio website
%GIT_CMD% commit -m "%commit_msg%"
echo.
echo Pushing to GitHub repository...
%GIT_CMD% push -u origin main
echo.
echo ========================================================
echo   Finished!
echo ========================================================
pause
