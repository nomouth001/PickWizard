# LuckyAI 645 프로젝트 구조 생성 스크립트
# 작성일: 2026-01-04 EST

Write-Host "LuckyAI 645 프로젝트 구조 생성 시작..." -ForegroundColor Green

# 루트 디렉토리 생성
$rootDir = "pick_wizard"
if (!(Test-Path $rootDir)) {
    New-Item -ItemType Directory -Path $rootDir
    Write-Host "루트 디렉토리 생성: $rootDir" -ForegroundColor Green
}

Set-Location $rootDir

# === 백엔드 디렉토리 구조 ===
$backendDirs = @(
    "backend",
    "backend/app",
    "backend/app/api",
    "backend/app/api/routes",
    "backend/app/core",
    "backend/app/algorithms",
    "backend/app/models",
    "backend/app/validation",
    "backend/app/db",
    "backend/app/db/models",
    "backend/app/db/repositories",
    "backend/app/services",
    "backend/app/schemas",
    "backend/app/utils",
    "backend/app/workers",
    "backend/data",
    "backend/data/raw",
    "backend/data/processed",
    "backend/data/models",
    "backend/results",
    "backend/results/validation",
    "backend/results/reports",
    "backend/results/logs",
    "backend/tests",
    "backend/tests/test_algorithms",
    "backend/tests/test_api",
    "backend/tests/test_validation",
    "backend/scripts"
)

foreach ($dir in $backendDirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}
$backendCount = $backendDirs.Count
Write-Host "백엔드 디렉토리 구조 생성 완료 ($backendCount 개)" -ForegroundColor Green

# __init__.py 파일 생성 (Python 패키지)
$initDirs = @(
    "backend/app",
    "backend/app/api",
    "backend/app/api/routes",
    "backend/app/core",
    "backend/app/algorithms",
    "backend/app/models",
    "backend/app/validation",
    "backend/app/db",
    "backend/app/db/models",
    "backend/app/db/repositories",
    "backend/app/services",
    "backend/app/schemas",
    "backend/app/utils",
    "backend/app/workers"
)

foreach ($dir in $initDirs) {
    $initFile = Join-Path $dir "__init__.py"
    if (!(Test-Path $initFile)) {
        New-Item -ItemType File -Path $initFile -Force | Out-Null
    }
}
Write-Host "Python __init__.py 파일 생성 완료" -ForegroundColor Green

# === 공유 리소스 디렉토리 ===
$sharedDirs = @(
    "shared",
    "shared/docs",
    "shared/api_specs",
    "shared/assets"
)

foreach ($dir in $sharedDirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}
Write-Host "공유 리소스 디렉토리 생성 완료" -ForegroundColor Green

# === 배포 디렉토리 ===
$deployDirs = @(
    "deployment",
    "deployment/docker",
    "deployment/k8s",
    "deployment/scripts"
)

foreach ($dir in $deployDirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}
Write-Host "배포 디렉토리 생성 완료" -ForegroundColor Green

# === CI/CD 디렉토리 ===
$cicdDirs = @(
    ".github",
    ".github/workflows"
)

foreach ($dir in $cicdDirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}
Write-Host "CI/CD 디렉토리 생성 완료" -ForegroundColor Green

# .gitkeep 파일 생성 (빈 디렉토리 추적)
$keepDirs = @(
    "backend/data/raw",
    "backend/data/processed",
    "backend/data/models",
    "backend/results/validation",
    "backend/results/reports",
    "backend/results/logs"
)

foreach ($dir in $keepDirs) {
    $keepFile = Join-Path $dir ".gitkeep"
    if (!(Test-Path $keepFile)) {
        New-Item -ItemType File -Path $keepFile -Force | Out-Null
    }
}

Write-Host ""
Write-Host "프로젝트 구조 생성 완료!" -ForegroundColor Green
Write-Host "다음 단계: Flutter 프로젝트 생성 (flutter create mobile_app)" -ForegroundColor Yellow
