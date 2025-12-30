@echo off
REM Setup and Test Script - Works with CMD/Terminal
REM Sets up Win_Test_System and runs initial tests

echo ========================================
echo   Win_Test_System Setup
echo ========================================
echo.

REM Check Git
git --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git not installed
    echo Install from: https://git-scm.com
    pause
    exit /b 1
)
echo Git found

REM Check if we're in the right directory
if not exist "test_project.bat" (
    echo ERROR: test_project.bat not found
    echo Please run this script from Win_Test_System directory
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Testing System
echo ========================================
echo.

REM Test with a known project (name-generator)
echo Testing with name-generator project...
echo.

call test_project.bat https://github.com/BiochemIQGenomics/Name_Generator.git

echo.
echo ========================================
echo   Setup Complete
echo ========================================
echo.
echo You can now test any project:
echo   test_project.bat [project-url-or-path]
echo.
pause
