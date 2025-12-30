@echo off
REM Run all adapted tests
REM Works with CMD/Terminal

setlocal enabledelayedexpansion

echo ========================================
echo   Running All Adapted Tests
echo ========================================
echo.

set "ADAPTED_DIR=%~dp0adapted_tests"
set "PASSED=0"
set "FAILED=0"

if not exist "%ADAPTED_DIR%" (
    echo No adapted tests found.
    echo Run adapt_tests.bat first to adapt tests from projects.
    pause
    exit /b 0
)

REM Run all .bat test files
for %%f in ("%ADAPTED_DIR%\*_test.bat") do (
    if exist "%%f" (
        echo Running: %%~nxf
        call "%%f"
        if errorlevel 1 (
            set /a FAILED+=1
            echo [FAILED] %%~nxf
        ) else (
            set /a PASSED+=1
            echo [PASSED] %%~nxf
        )
        echo.
    )
)

REM Try to run PowerShell tests if PowerShell is available
where powershell >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    for %%f in ("%ADAPTED_DIR%\*_test.ps1") do (
        if exist "%%f" (
            echo Running: %%~nxf
            powershell -ExecutionPolicy Bypass -File "%%f"
            if errorlevel 1 (
                set /a FAILED+=1
                echo [FAILED] %%~nxf
            ) else (
                set /a PASSED+=1
                echo [PASSED] %%~nxf
            )
            echo.
        )
    )
)

echo ========================================
echo   Test Summary
echo ========================================
echo Passed: !PASSED!
echo Failed: !FAILED!
echo.

pause
