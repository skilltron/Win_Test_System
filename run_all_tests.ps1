# Run all adapted tests
# PowerShell version

$AdaptedDir = Join-Path $PSScriptRoot "adapted_tests"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Running All Adapted Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $AdaptedDir)) {
    Write-Host "No adapted tests found." -ForegroundColor Yellow
    Write-Host "Run adapt_tests.ps1 first to adapt tests from projects." -ForegroundColor Yellow
    exit 0
}

$testFiles = Get-ChildItem -Path $AdaptedDir -Filter "*_test.*"
if ($testFiles.Count -eq 0) {
    Write-Host "No test files found in adapted_tests/" -ForegroundColor Yellow
    exit 0
}

$passed = 0
$failed = 0

foreach ($testFile in $testFiles) {
    Write-Host "Running: $($testFile.Name)" -ForegroundColor Cyan
    
    try {
        if ($testFile.Extension -eq ".ps1") {
            & $testFile.FullName
        } elseif ($testFile.Extension -eq ".bat") {
            & cmd /c $testFile.FullName
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ PASSED" -ForegroundColor Green
            $passed++
        } else {
            Write-Host "  ❌ FAILED" -ForegroundColor Red
            $failed++
        }
    } catch {
        Write-Host "  ❌ FAILED: $_" -ForegroundColor Red
        $failed++
    }
    
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Passed: $passed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host ""
