# Universal Windows Test Script - PowerShell Version
# Enhanced version with more features

param(
    [string]$ProjectSource = "",
    [switch]$SkipBuild = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"
$ProjectsDir = Join-Path $PSScriptRoot "projects"

function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

Write-Info "========================================"
Write-Info "  Win_Test_System - Project Tester"
Write-Info "========================================"
Write-Host ""

# Determine project source
if (-not $ProjectSource) {
    $ProjectSource = "."
}

# Create projects directory
if (-not (Test-Path $ProjectsDir)) {
    New-Item -ItemType Directory -Path $ProjectsDir | Out-Null
}

# Determine if it's a URL or local path
$isUrl = $ProjectSource -match "^https?://|^git@"
$TestDir = ""

if ($isUrl) {
    Write-Info "Detected: GitHub/Git URL"
    $projectName = [System.IO.Path]::GetFileNameWithoutExtension($ProjectSource -replace '\.git$', '')
    $TestDir = Join-Path $ProjectsDir $projectName
    
    if (Test-Path $TestDir) {
        Write-Warning "Project already exists, updating..."
        Push-Location $TestDir
        git pull
        Pop-Location
    } else {
        Write-Info "Cloning project: $ProjectSource"
        Push-Location $ProjectsDir
        git clone $ProjectSource $projectName
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to clone repository"
            exit 1
        }
        Pop-Location
    }
} else {
    Write-Info "Detected: Local path"
    if ($ProjectSource -eq ".") {
        $ProjectSource = $PWD
    }
    
    if (-not (Test-Path $ProjectSource)) {
        Write-Error "Path does not exist: $ProjectSource"
        exit 1
    }
    
    $projectName = Split-Path -Leaf $ProjectSource
    $TestDir = Join-Path $ProjectsDir $projectName
    
    Write-Info "Copying project: $ProjectSource"
    Copy-Item -Path $ProjectSource -Destination $TestDir -Recurse -Force
}

Push-Location $TestDir

# Detect project type
Write-Info ""
Write-Info "========================================"
Write-Info "  Detecting Project Type"
Write-Info "========================================"
Write-Host ""

$projectType = "unknown"

if (Test-Path "pubspec.yaml") {
    $projectType = "flutter"
    Write-Info "Detected: Flutter Project"
} elseif (Test-Path "package.json") {
    $projectType = "nodejs"
    Write-Info "Detected: Node.js Project"
} elseif (Test-Path "requirements.txt" -or (Test-Path "setup.py")) {
    $projectType = "python"
    Write-Info "Detected: Python Project"
} elseif (Test-Path "index.html") {
    $projectType = "web"
    Write-Info "Detected: Web Project"
} else {
    Write-Error "Unknown project type"
    Write-Info "Supported: Flutter, Node.js, Python, Web"
    exit 1
}

# Run appropriate tests
switch ($projectType) {
    "flutter" { Test-FlutterProject }
    "nodejs" { Test-NodeJsProject }
    "python" { Test-PythonProject }
    "web" { Test-WebProject }
}

Pop-Location

function Test-FlutterProject {
    Write-Info ""
    Write-Info "========================================"
    Write-Info "  Testing Flutter Project"
    Write-Info "========================================"
    Write-Host ""
    
    # Check Flutter
    try {
        flutter --version | Out-Null
        Write-Success "Flutter found"
    } catch {
        Write-Error "Flutter not installed. Install from: https://flutter.dev"
        exit 1
    }
    
    Write-Info "Getting dependencies..."
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to get dependencies"
        exit 1
    }
    
    if (-not $SkipBuild) {
        Write-Info "Building Windows app..."
        flutter build windows --release
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Build failed"
            exit 1
        }
    }
    
    # Find executable
    $exe = Get-ChildItem -Path "build\windows" -Filter "*.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($exe) {
        Write-Success "Found executable: $($exe.FullName)"
        Test-Executable $exe.FullName
    } else {
        Write-Warning "Executable not found"
    }
}

function Test-NodeJsProject {
    Write-Info ""
    Write-Info "========================================"
    Write-Info "  Testing Node.js Project"
    Write-Info "========================================"
    Write-Host ""
    
    # Check Node.js
    try {
        node --version | Out-Null
        Write-Success "Node.js found"
    } catch {
        Write-Error "Node.js not installed. Install from: https://nodejs.org"
        exit 1
    }
    
    Write-Info "Installing dependencies..."
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install dependencies"
        exit 1
    }
    
    # Check if Electron
    $packageJson = Get-Content "package.json" | ConvertFrom-Json
    $isElectron = ($packageJson.dependencies.electron -or $packageJson.devDependencies.electron)
    
    if ($isElectron) {
        Write-Info "Detected Electron app"
        if (-not $SkipBuild) {
            Write-Info "Building Electron app..."
            npm run build
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Build failed"
                exit 1
            }
        }
        
        # Find executable
        $exe = Get-ChildItem -Path "dist" -Filter "*.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($exe) {
            Write-Success "Found executable: $($exe.FullName)"
            Test-Executable $exe.FullName
        }
    } else {
        Write-Info "Regular Node.js project"
        if ($packageJson.scripts.test) {
            Write-Info "Running tests..."
            npm test
        }
    }
}

function Test-PythonProject {
    Write-Info ""
    Write-Info "========================================"
    Write-Info "  Testing Python Project"
    Write-Info "========================================"
    Write-Host ""
    
    # Check Python
    try {
        python --version | Out-Null
        Write-Success "Python found"
    } catch {
        Write-Error "Python not installed. Install from: https://www.python.org"
        exit 1
    }
    
    # Check for build script
    if (Test-Path "build_windows_exe_automated.py") {
        Write-Info "Found build script: build_windows_exe_automated.py"
        if (-not $SkipBuild) {
            python build_windows_exe_automated.py
        }
    } elseif (Test-Path "build_windows_exe.py") {
        Write-Info "Found build script: build_windows_exe.py"
        if (-not $SkipBuild) {
            python build_windows_exe.py
        }
    } else {
        Write-Warning "No build script found"
    }
    
    # Find executable
    $exe = Get-ChildItem -Path "dist" -Filter "*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($exe) {
        Write-Success "Found executable: $($exe.FullName)"
        Test-Executable $exe.FullName
    }
}

function Test-WebProject {
    Write-Info ""
    Write-Info "========================================"
    Write-Info "  Testing Web Project"
    Write-Info "========================================"
    Write-Host ""
    
    if (Test-Path "server.py") {
        Write-Info "Found Python web server"
        Test-PythonProject
    } else {
        Write-Info "Static web project"
        if (Test-Path "index.html") {
            Write-Success "Found: index.html"
            Write-Success "Web project appears valid"
        }
    }
}

function Test-Executable {
    param([string]$ExePath)
    
    Write-Info ""
    Write-Info "========================================"
    Write-Info "  Testing Executable"
    Write-Info "========================================"
    Write-Host ""
    
    if (-not (Test-Path $ExePath)) {
        Write-Error "Executable not found: $ExePath"
        return
    }
    
    $fileInfo = Get-Item $ExePath
    $sizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
    
    Write-Info "File: $ExePath"
    Write-Info "Size: $sizeMB MB"
    Write-Host ""
    
    # Basic tests
    Write-Success "File exists"
    
    if ($fileInfo.Extension -eq ".exe") {
        Write-Success "File type (.exe)"
    } else {
        Write-Error "File type (.exe)"
    }
    
    if ($sizeMB -gt 0 -and $sizeMB -lt 100) {
        Write-Success "File size (reasonable)"
    } else {
        Write-Warning "File size (unusual: $sizeMB MB)"
    }
    
    # Try to start
    Write-Info "Testing executable startup..."
    try {
        $process = Start-Process -FilePath $ExePath -PassThru -WindowStyle Hidden
        Start-Sleep -Seconds 3
        
        if ($process -and -not $process.HasExited) {
            Write-Success "Executable can start (PID: $($process.Id))"
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        } else {
            Write-Warning "Executable started but exited quickly"
        }
    } catch {
        Write-Error "Failed to start executable: $_"
    }
    
    Write-Host ""
    Write-Info "========================================"
    Write-Info "  Test Summary"
    Write-Info "========================================"
    Write-Success "Basic tests completed"
    Write-Info "Executable: $ExePath"
    Write-Host ""
}
