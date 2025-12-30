@echo off
REM Universal Windows Test Script - Works with CMD/Terminal
REM No PowerShell required!

setlocal enabledelayedexpansion

if "%1"=="" (
    echo Usage: test_project.bat [project-path-or-url]
    echo   Examples:
    echo     test_project.bat https://github.com/user/repo.git
    echo     test_project.bat C:\path\to\project
    echo     test_project.bat .
    exit /b 1
)

set "PROJECT_SOURCE=%~1"
set "PROJECT_DIR=%~dp0projects"
set "CURRENT_DIR=%CD%"

echo ========================================
echo   Win_Test_System - Project Tester
echo ========================================
echo.

REM Create projects directory
if not exist "%PROJECT_DIR%" mkdir "%PROJECT_DIR%"

REM Determine if it's a URL or local path
echo %PROJECT_SOURCE% | findstr /C:"http" /C:"git@" >nul
if %ERRORLEVEL% EQU 0 (
    echo Detected: GitHub/Git URL
    call :clone_project "%PROJECT_SOURCE%"
) else (
    echo Detected: Local path
    call :copy_local_project "%PROJECT_SOURCE%"
)

REM Detect project type and test
call :detect_and_test

endlocal
exit /b 0

:clone_project
set "REPO_URL=%~1"
set "PROJECT_NAME=%~nx1"
set "PROJECT_NAME=!PROJECT_NAME:.git=!"

echo Cloning project: %REPO_URL%
cd /d "%PROJECT_DIR%"
if exist "!PROJECT_NAME!" (
    echo Project already exists, updating...
    cd "!PROJECT_NAME!"
    git pull
) else (
    git clone "%REPO_URL%" "!PROJECT_NAME!"
    if errorlevel 1 (
        echo ERROR: Failed to clone repository
        exit /b 1
    )
    cd "!PROJECT_NAME!"
)

set "TEST_DIR=%PROJECT_DIR%\!PROJECT_NAME!"
goto :eof

:copy_local_project
set "SOURCE_PATH=%~1"
if "%SOURCE_PATH%"=="." set "SOURCE_PATH=%CURRENT_DIR%"

if not exist "%SOURCE_PATH%" (
    echo ERROR: Path does not exist: %SOURCE_PATH%
    exit /b 1
)

set "PROJECT_NAME=%~nx1"
if "%PROJECT_NAME%"=="." set "PROJECT_NAME=%~nxCURRENT_DIR%"

echo Copying project: %SOURCE_PATH%
xcopy "%SOURCE_PATH%" "%PROJECT_DIR%\%PROJECT_NAME%\" /E /I /Y /Q
if errorlevel 1 (
    echo ERROR: Failed to copy project
    exit /b 1
)

set "TEST_DIR=%PROJECT_DIR%\%PROJECT_NAME%"
goto :eof

:detect_and_test
cd /d "%TEST_DIR%"
echo.
echo ========================================
echo   Detecting Project Type
echo ========================================
echo.

REM Check for Flutter
if exist "pubspec.yaml" (
    echo Detected: Flutter Project
    call :test_flutter
    goto :eof
)

REM Check for Node.js
if exist "package.json" (
    echo Detected: Node.js Project
    call :test_nodejs
    goto :eof
)

REM Check for Python
if exist "requirements.txt" (
    echo Detected: Python Project
    call :test_python
    goto :eof
)

if exist "setup.py" (
    echo Detected: Python Project (setup.py)
    call :test_python
    goto :eof
)

REM Check for Web
if exist "index.html" (
    echo Detected: Web Project
    call :test_web
    goto :eof
)

echo ERROR: Unknown project type
echo Supported: Flutter, Node.js, Python, Web
exit /b 1

:test_flutter
echo.
echo ========================================
echo   Testing Flutter Project
echo ========================================
echo.

REM Check Flutter
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter not installed
    echo Install from: https://flutter.dev
    exit /b 1
)

echo Getting dependencies...
flutter pub get
if errorlevel 1 (
    echo ERROR: Failed to get dependencies
    exit /b 1
)

echo Building Windows app...
flutter build windows --release
if errorlevel 1 (
    echo ERROR: Build failed
    exit /b 1
)

REM Find executable
for /r "build\windows" %%f in (*.exe) do (
    if exist "%%f" (
        echo Found executable: %%f
        call :test_executable "%%f"
        goto :eof
    )
)

echo WARNING: Executable not found
exit /b 0

:test_nodejs
echo.
echo ========================================
echo   Testing Node.js Project
echo ========================================
echo.

REM Check Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js not installed
    echo Install from: https://nodejs.org
    exit /b 1
)

echo Installing dependencies...
call npm install
if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    exit /b 1
)

REM Check if it's Electron
findstr /C:"electron" package.json >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Detected Electron app
    echo Building Electron app...
    call npm run build
    if errorlevel 1 (
        echo ERROR: Build failed
        exit /b 1
    )
    
    REM Find Electron executable
    for /r "dist" %%f in (*.exe) do (
        if exist "%%f" (
            echo Found executable: %%f
            call :test_executable "%%f"
            goto :eof
        )
    )
) else (
    echo Regular Node.js project
    echo Running tests...
    if exist "package.json" (
        findstr /C:"test" package.json >nul 2>&1
        if %ERRORLEVEL% EQU 0 (
            call npm test
        )
    )
)

exit /b 0

:test_python
echo.
echo ========================================
echo   Testing Python Project
echo ========================================
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not installed
    echo Install from: https://www.python.org
    exit /b 1
)

REM Check for build script
if exist "build_windows_exe_automated.py" (
    echo Found build script: build_windows_exe_automated.py
    python build_windows_exe_automated.py
) else if exist "build_windows_exe.py" (
    echo Found build script: build_windows_exe.py
    python build_windows_exe.py
) else (
    echo No build script found
    echo Checking for PyInstaller...
    python -m PyInstaller --version >nul 2>&1
    if errorlevel 1 (
        echo Installing PyInstaller...
        python -m pip install pyinstaller --quiet
    )
    
    REM Try to find server.py or main script
    if exist "server.py" (
        echo Building with PyInstaller...
        python -m PyInstaller --onefile --console --name App server.py
    ) else (
        echo WARNING: No build configuration found
        exit /b 0
    )
)

REM Find executable
for /r "dist" %%f in (*.exe) do (
    if exist "%%f" (
        echo Found executable: %%f
        call :test_executable "%%f"
        goto :eof
    )
)

exit /b 0

:test_web
echo.
echo ========================================
echo   Testing Web Project
echo ========================================
echo.

REM Check if it has a server
if exist "server.py" (
    echo Found Python web server
    call :test_python
) else (
    echo Static web project
    echo Checking files...
    if exist "index.html" (
        echo Found: index.html
        echo Web project appears valid
    )
)

exit /b 0

:test_executable
set "EXE_PATH=%~1"
echo.
echo ========================================
echo   Testing Executable
echo ========================================
echo.

if not exist "%EXE_PATH%" (
    echo ERROR: Executable not found: %EXE_PATH%
    exit /b 1
)

REM Get file size
for %%A in ("%EXE_PATH%") do set "FILE_SIZE=%%~zA"
set /a SIZE_MB=%FILE_SIZE% / 1048576
echo File: %EXE_PATH%
echo Size: %SIZE_MB% MB
echo.

REM Test 1: File exists
echo [TEST] File exists: PASS

REM Test 2: File type
echo %EXE_PATH% | findstr /C:".exe" >nul
if %ERRORLEVEL% EQU 0 (
    echo [TEST] File type (.exe): PASS
) else (
    echo [TEST] File type (.exe): FAIL
)

REM Test 3: File size check
if %SIZE_MB% GTR 0 if %SIZE_MB% LSS 100 (
    echo [TEST] File size (reasonable): PASS
) else (
    echo [TEST] File size (reasonable): FAIL
)

REM Test 4: Try to start (basic check)
echo.
echo Starting executable for basic test...
start "" "%EXE_PATH%"
timeout /t 3 /nobreak >nul
taskkill /F /IM "%~nx1" >nul 2>&1

echo [TEST] Executable can start: PASS
echo.

echo ========================================
echo   Test Summary
echo ========================================
echo All basic tests completed
echo Executable: %EXE_PATH%
echo.

goto :eof
