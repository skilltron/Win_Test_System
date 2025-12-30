@echo off
REM Copy project to UTM shared folder for testing
REM Assumes UTM shared folder is mapped to a drive letter

setlocal enabledelayedexpansion

if "%1"=="" (
    echo Usage: copy_to_utm.bat [project-path]
    echo   Example: copy_to_utm.bat projects\name-generator
    exit /b 1
)

set "PROJECT_PATH=%~1"
set "UTM_SHARE=Z:"

REM Try to find UTM share (common drive letters)
for %%d in (Z Y X W V) do (
    if exist "%%d:\" (
        set "UTM_SHARE=%%d:"
        goto :found
    )
)

:found
echo Using UTM share: %UTM_SHARE%
echo.

if not exist "%PROJECT_PATH%" (
    echo ERROR: Project path does not exist: %PROJECT_PATH%
    exit /b 1
)

set "PROJECT_NAME=%~nx1"
set "DEST_PATH=%UTM_SHARE%\%PROJECT_NAME%"

echo Copying project to UTM...
echo   From: %PROJECT_PATH%
echo   To: %DEST_PATH%
echo.

xcopy "%PROJECT_PATH%" "%DEST_PATH%\" /E /I /Y /Q
if errorlevel 1 (
    echo ERROR: Failed to copy project
    exit /b 1
)

echo.
echo ========================================
echo   Copy Complete
echo ========================================
echo Project copied to: %DEST_PATH%
echo.
echo In Windows VM, navigate to:
echo   %DEST_PATH%
echo.
echo Then run:
echo   test_project.bat .
echo.

pause
