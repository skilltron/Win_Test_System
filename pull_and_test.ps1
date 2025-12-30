# Pull project from GitHub and test it
# PowerShell version

param(
    [Parameter(Mandatory=$true)]
    [string]$RepoUrl
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Pull and Test Project" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Pull the project
& ".\test_project.ps1" -ProjectSource $RepoUrl

# Get project name
$projectName = [System.IO.Path]::GetFileNameWithoutExtension($RepoUrl -replace '\.git$', '')

# Adapt tests if they exist
$projectPath = Join-Path "projects" $projectName
if (Test-Path "$projectPath\test_windows_build.ps1" -or Test-Path "$projectPath\test_windows_build.bat") {
    Write-Host ""
    Write-Host "Adapting tests..." -ForegroundColor Yellow
    & ".\adapt_tests.ps1"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Project pulled and tested: $projectName" -ForegroundColor Green
Write-Host ""
