@echo off
REM Pull project from GitHub and test it
REM Works with CMD/Terminal

if "%1"=="" (
    echo Usage: pull_and_test.bat [github-url]
    echo   Example: pull_and_test.bat https://github.com/user/repo.git
    exit /b 1
)

set "REPO_URL=%~1"

echo ========================================
echo   Pull and Test Project
echo ========================================
echo.

REM Pull the project
call test_project.bat "%REPO_URL%"

REM Find the project name
for /f "tokens=*" %%a in ('echo %REPO_URL%') do set "REPO_NAME=%%~nxa"
set "REPO_NAME=!REPO_NAME:.git=!"

REM Adapt tests if they exist
if exist "projects\!REPO_NAME!\test_windows_build.ps1" (
    echo.
    echo Adapting tests...
    call adapt_tests.bat
)

echo.
echo ========================================
echo   Complete
echo ========================================
echo Project pulled and tested: !REPO_NAME!
echo.

pause
