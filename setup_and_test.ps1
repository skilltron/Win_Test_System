# Setup and Test Script - PowerShell Version

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Win_Test_System Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Git
try {
    git --version | Out-Null
    Write-Host "✅ Git found" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR: Git not installed" -ForegroundColor Red
    Write-Host "Install from: https://git-scm.com" -ForegroundColor Yellow
    exit 1
}

# Check if we're in the right directory
if (-not (Test-Path "test_project.ps1")) {
    Write-Host "❌ ERROR: test_project.ps1 not found" -ForegroundColor Red
    Write-Host "Please run this script from Win_Test_System directory" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Testing System" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test with a known project
Write-Host "Testing with name-generator project..." -ForegroundColor Yellow
Write-Host ""

& ".\test_project.ps1" -ProjectSource "https://github.com/BiochemIQGenomics/Name_Generator.git"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now test any project:" -ForegroundColor Green
Write-Host "  .\test_project.ps1 [project-url-or-path]" -ForegroundColor White
Write-Host ""
