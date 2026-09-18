# Phase 0 통합 테스트 스크립트
# 2026-01-04 EST

Write-Host "=== Phase 0 Integration Test Start ===" -ForegroundColor Cyan

$testsPassed = 0
$testsFailed = 0

# 1. Directory Structure Check
Write-Host "`n[1] Checking directory structure..." -ForegroundColor Yellow
$dirs = @(
    "backend\app\api\routes",
    "backend\app\core",
    "backend\data",
    "deployment\docker",
    "shared\docs"
)

foreach ($dir in $dirs) {
    if (Test-Path $dir) {
        Write-Host "  OK: $dir" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  FAIL: $dir missing" -ForegroundColor Red
        $testsFailed++
    }
}

# 2. Backend Files Check
Write-Host "`n[2] Checking backend files..." -ForegroundColor Yellow
$files = @(
    "backend\requirements.txt",
    "backend\.env.example",
    "backend\pyproject.toml",
    "backend\.gitignore",
    "backend\README.md"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "  OK: $file" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  FAIL: $file missing" -ForegroundColor Red
        $testsFailed++
    }
}

# 3. Docker Files Check
Write-Host "`n[3] Checking Docker files..." -ForegroundColor Yellow
$dockerFiles = @(
    "deployment\docker\docker-compose.yml",
    "deployment\docker\init-db.sql"
)

foreach ($file in $dockerFiles) {
    if (Test-Path $file) {
        Write-Host "  OK: $file" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  FAIL: $file missing" -ForegroundColor Red
        $testsFailed++
    }
}

# 4. Git Repository Check
Write-Host "`n[4] Checking Git repository..." -ForegroundColor Yellow
if (Test-Path ".git") {
    Write-Host "  OK: Git repository initialized" -ForegroundColor Green
    $testsPassed++
    
    $branches = git branch
    if ($branches -match "develop") {
        Write-Host "  OK: develop branch exists" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  FAIL: develop branch missing" -ForegroundColor Red
        $testsFailed++
    }
} else {
    Write-Host "  FAIL: Git not initialized" -ForegroundColor Red
    $testsFailed += 2
}

# 5. Python __init__.py Files Check
Write-Host "`n[5] Checking __init__.py files..." -ForegroundColor Yellow
$initDirs = @(
    "backend\app",
    "backend\app\api",
    "backend\app\core",
    "backend\app\db"
)

foreach ($dir in $initDirs) {
    $initFile = Join-Path $dir "__init__.py"
    if (Test-Path $initFile) {
        Write-Host "  OK: $initFile" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  FAIL: $initFile missing" -ForegroundColor Red
        $testsFailed++
    }
}

# 6. Docker Compose Validation
Write-Host "`n[6] Validating docker-compose.yml..." -ForegroundColor Yellow
$dockerCompose = Get-Content "deployment\docker\docker-compose.yml" -Raw
if ($dockerCompose -match "postgres" -and $dockerCompose -match "redis") {
    Write-Host "  OK: docker-compose.yml contains required services" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  FAIL: docker-compose.yml missing required services" -ForegroundColor Red
    $testsFailed++
}

# Summary
Write-Host "`n=== Test Summary ===" -ForegroundColor Cyan
Write-Host "Passed: $testsPassed" -ForegroundColor Green
Write-Host "Failed: $testsFailed" -ForegroundColor Red

if ($testsFailed -eq 0) {
    Write-Host "`nAll tests passed! Phase 0 completed successfully." -ForegroundColor Green
    Write-Host "You can proceed to Phase 1." -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "`nSome tests failed. Please check the issues above." -ForegroundColor Red
    exit 1
}

