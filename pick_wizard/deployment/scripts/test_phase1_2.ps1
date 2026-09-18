# Phase 1 & 2 통합 테스트 스크립트
# 2026-01-04 EST - 생성

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Phase 1 & 2 Integration Test" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$ErrorActionPreference = "Continue"
$testsPassed = 0
$testsFailed = 0

# === 1. Docker Compose 상태 확인 ===
Write-Host "[1/5] Docker Compose Status Check..." -ForegroundColor Yellow
try {
    $dockerStatus = docker-compose -f deployment\docker\docker-compose.yml ps
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Docker Compose: OK" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  Docker Compose: NOT RUNNING" -ForegroundColor Red
        Write-Host "  Run: cd deployment\docker; docker-compose up -d" -ForegroundColor Yellow
        $testsFailed++
    }
} catch {
    Write-Host "  Docker Compose: ERROR" -ForegroundColor Red
    $testsFailed++
}

# === 2. PostgreSQL 연결 확인 ===
Write-Host "`n[2/5] PostgreSQL Connection Test..." -ForegroundColor Yellow
try {
    $pgTest = docker exec lotto645_postgres pg_isready -U lotto_user
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  PostgreSQL: CONNECTED" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  PostgreSQL: NOT READY" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "  PostgreSQL: ERROR" -ForegroundColor Red
    $testsFailed++
}

# === 3. Redis 연결 확인 ===
Write-Host "`n[3/5] Redis Connection Test..." -ForegroundColor Yellow
try {
    $redisTest = docker exec lotto645_redis redis-cli ping
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Redis: CONNECTED" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  Redis: NOT READY" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "  Redis: ERROR" -ForegroundColor Red
    $testsFailed++
}

# === 4. Python 의존성 확인 ===
Write-Host "`n[4/5] Python Dependencies Check..." -ForegroundColor Yellow
try {
    Set-Location backend
    $pipList = pip list 2>&1 | Out-String
    
    $requiredPackages = @("fastapi", "sqlalchemy", "redis", "pandas", "aiohttp", "beautifulsoup4")
    $missingPackages = @()
    
    foreach ($pkg in $requiredPackages) {
        if ($pipList -notmatch $pkg) {
            $missingPackages += $pkg
        }
    }
    
    if ($missingPackages.Count -eq 0) {
        Write-Host "  All required packages: INSTALLED" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  Missing packages: $($missingPackages -join ', ')" -ForegroundColor Red
        Write-Host "  Run: pip install -r requirements.txt" -ForegroundColor Yellow
        $testsFailed++
    }
    
    Set-Location ..
} catch {
    Write-Host "  Python Dependencies: ERROR" -ForegroundColor Red
    Write-Host "  $_" -ForegroundColor Red
    $testsFailed++
    Set-Location ..
}

# === 5. Pytest 실행 ===
Write-Host "`n[5/5] Running Pytest..." -ForegroundColor Yellow
try {
    Set-Location backend
    
    # .env 파일 확인
    if (!(Test-Path ".env")) {
        Write-Host "  WARNING: .env file not found. Creating from .env.example..." -ForegroundColor Yellow
        Copy-Item .env.example .env
    }
    
    # Pytest 실행
    $pytestResult = pytest tests/test_phase1_phase2.py -v --tb=short
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n  All unit tests: PASSED" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "`n  Some unit tests: FAILED" -ForegroundColor Red
        Write-Host "  Check the output above for details" -ForegroundColor Yellow
        $testsFailed++
    }
    
    Set-Location ..
} catch {
    Write-Host "  Pytest: ERROR" -ForegroundColor Red
    Write-Host "  $_" -ForegroundColor Red
    $testsFailed++
    Set-Location ..
}

# === 결과 요약 ===
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Results" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Passed: $testsPassed / 5" -ForegroundColor Green
Write-Host "Failed: $testsFailed / 5" -ForegroundColor Red

if ($testsFailed -eq 0) {
    Write-Host "`nAll tests PASSED!" -ForegroundColor Green
    Write-Host "Phase 1 & 2 implementation is complete and ready!" -ForegroundColor Green
} else {
    Write-Host "`nSome tests FAILED!" -ForegroundColor Red
    Write-Host "Please fix the issues above before proceeding." -ForegroundColor Yellow
}

Write-Host "`n========================================`n" -ForegroundColor Cyan

