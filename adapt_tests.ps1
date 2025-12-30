# Adapt existing tests from projects to Win_Test_System format
# PowerShell version with enhanced features

$ErrorActionPreference = "Stop"

$ProjectsDir = Join-Path $PSScriptRoot "projects"
$AdaptedDir = Join-Path $PSScriptRoot "adapted_tests"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Adapting Tests from Projects" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $ProjectsDir)) {
    Write-Host "No projects directory found. Run test_project first." -ForegroundColor Yellow
    exit 0
}

if (-not (Test-Path $AdaptedDir)) {
    New-Item -ItemType Directory -Path $AdaptedDir | Out-Null
}

Write-Host "Scanning for test files..." -ForegroundColor Yellow
Write-Host ""

$foundTests = @()

Get-ChildItem -Path $ProjectsDir -Directory | ForEach-Object {
    $projectName = $_.Name
    $projectPath = $_.FullName
    
    Write-Host "Processing: $projectName" -ForegroundColor Cyan
    
    $tests = @()
    
    # Look for test scripts
    if (Test-Path "$projectPath\test_windows_build.ps1") {
        Write-Host "  Found: test_windows_build.ps1" -ForegroundColor Green
        $tests += @{
            Source = "$projectPath\test_windows_build.ps1"
            Dest = "$AdaptedDir\${projectName}_test.ps1"
            Type = "test"
        }
    }
    
    if (Test-Path "$projectPath\test_windows_build.bat") {
        Write-Host "  Found: test_windows_build.bat" -ForegroundColor Green
        $tests += @{
            Source = "$projectPath\test_windows_build.bat"
            Dest = "$AdaptedDir\${projectName}_test.bat"
            Type = "test"
        }
    }
    
    if (Test-Path "$projectPath\build_and_test_windows.ps1") {
        Write-Host "  Found: build_and_test_windows.ps1" -ForegroundColor Green
        $tests += @{
            Source = "$projectPath\build_and_test_windows.ps1"
            Dest = "$AdaptedDir\${projectName}_build_test.ps1"
            Type = "build_test"
        }
    }
    
    # Copy and adapt tests
    foreach ($test in $tests) {
        Copy-Item -Path $test.Source -Destination $test.Dest -Force
        $foundTests += $test.Dest
        
        # Adapt the test file to work from any location
        $content = Get-Content $test.Dest -Raw
        
        # Replace hardcoded paths with relative paths
        $content = $content -replace 'dist\\NameGenerator\.exe', '$PSScriptRoot\..\dist\*.exe'
        $content = $content -replace 'dist\NameGenerator\.exe', '$PSScriptRoot\..\dist\*.exe'
        
        # Add project detection
        if ($content -notmatch 'ProjectType|project.*type') {
            $header = @"

# Adapted test for $projectName
# Original from: $($test.Source)
# Auto-adapted by Win_Test_System

"@
            $content = $header + $content
        }
        
        Set-Content -Path $test.Dest -Value $content -NoNewline
    }
    
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Adaptation Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($foundTests.Count -gt 0) {
    Write-Host "Adapted $($foundTests.Count) test file(s):" -ForegroundColor Green
    foreach ($test in $foundTests) {
        Write-Host "  - $test" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "Adapted tests saved to: $AdaptedDir" -ForegroundColor Cyan
} else {
    Write-Host "No test files found to adapt." -ForegroundColor Yellow
    Write-Host "Run test_project first to clone/copy projects." -ForegroundColor Yellow
}

Write-Host ""
