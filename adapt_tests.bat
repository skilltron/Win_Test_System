@echo off
REM Adapt existing tests from projects to Win_Test_System format
REM Scans for test files and adapts them

setlocal enabledelayedexpansion

echo ========================================
echo   Adapting Tests from Projects
echo ========================================
echo.

set "PROJECTS_DIR=%~dp0projects"
set "ADAPTED_DIR=%~dp0adapted_tests"

if not exist "%ADAPTED_DIR%" mkdir "%ADAPTED_DIR%"

REM Look for test files in projects
echo Scanning for test files...
echo.

for /d %%p in ("%PROJECTS_DIR%\*") do (
    set "PROJECT_NAME=%%~nxp"
    echo Processing: !PROJECT_NAME!
    
    REM Look for test scripts
    if exist "%%p\test_windows_build.ps1" (
        echo   Found: test_windows_build.ps1
        copy "%%p\test_windows_build.ps1" "%ADAPTED_DIR%\!PROJECT_NAME!_test.ps1" >nul
    )
    
    if exist "%%p\test_windows_build.bat" (
        echo   Found: test_windows_build.bat
        copy "%%p\test_windows_build.bat" "%ADAPTED_DIR%\!PROJECT_NAME!_test.bat" >nul
    )
    
    if exist "%%p\build_and_test_windows.ps1" (
        echo   Found: build_and_test_windows.ps1
        copy "%%p\build_and_test_windows.ps1" "%ADAPTED_DIR%\!PROJECT_NAME!_build_test.ps1" >nul
    )
    
    echo.
)

echo ========================================
echo   Adaptation Complete
echo ========================================
echo Adapted tests saved to: %ADAPTED_DIR%
echo.

pause
